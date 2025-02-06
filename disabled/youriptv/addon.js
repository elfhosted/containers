const axios = require('axios').default;
const { handleChannelRequest, getEpgInfoBatch } = require('./tvGuide');

axios.defaults.headers.get["content-type"] = "application/json";
axios.defaults.timeout = 5000
axios.defaults.method = "GET"

function getUserData(userConf) {
    let retrievedData, url, obj = {}
    try {
        retrievedData = JSON.parse(Buffer.from(userConf, 'base64').toString())      
    } catch (error) {
        return "error while parsing url"
    }
    
    let domainName,baseURL,idPrefix

    if(typeof retrievedData === "object"){
        domainName = retrievedData.BaseURL.split("/")[2].split(":")[0] || "unknown"
        baseURL = retrievedData.BaseURL
        idPrefix = domainName.charAt(0) + domainName.substr(Math.ceil(domainName.length / 2 - 1), domainName.length % 2 === 0 ? 2 : 1) + domainName.charAt(domainName.length - 1) + ":";
        
        obj = {
            baseURL,
            domainName,
            idPrefix,
            username: retrievedData.username,
            password: retrievedData.password,
            timezone: retrievedData.timezone || 'UTC'
        }

    }else if(retrievedData.includes("http")){
        url = retrievedData
        
        const queryString = url.split('?')[1] || "unknown"
        baseURL = url.split('/')[0] + "//" + url.split('?')[0].split('/')[2] || "unknown"
        
        domainName = url.split("?")[0].split("/")[2].split(":")[0] || "unknown"
        idPrefix = domainName.charAt(0) + domainName.substr(Math.ceil(domainName.length / 2 - 1), domainName.length % 2 === 0 ? 2 : 1) + domainName.charAt(domainName.length - 1) + ":";
        
        if(queryString === undefined){return {result:"URL does not have any queries!"}}
        if(baseURL === undefined){return {result:"URL does not seem like an url!"}}
        
        obj.baseURL = baseURL
        obj.domainName = domainName
        obj.idPrefix = idPrefix
        
        const urlParams = new URLSearchParams(queryString);
        const entries = urlParams.entries();
        
        for(const entry of entries) {
            obj[entry[0]] = entry[1]
        }
        
        obj.timezone = obj.timezone || 'UTC';
    }

    if(obj.username && obj.password && obj.baseURL){
        return obj
    }else{
        return {}
    }
}

async function getManifest(url) {
    const obj = getUserData(url)

    let vod
    try {
        vod = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_vod_categories`})
    } catch (error) {
        return {error}
    }
    const vodJSON = vod.data

    let movieCatalog = []
    if (vod.status === 200){    
        vodJSON.forEach(i => {
            let name = i.category_name
            movieCatalog.push(name)
        });
    }
    
    let series
    try {
        series = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_series_categories`})
    } catch (error) {
        return {error}
    }
    const seriesJSON = series.data

    let seriesCatalog = []
    if(series.status === 200){    
        seriesJSON.forEach(i => {
            let name = i.category_name
            seriesCatalog.push(name)
        });
    }

    let live
    try {
        live = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_live_categories`})
    } catch (error) {
        return {error}
    }
    const liveJSON = live.data

    let liveCatalog = []
    if(series.status === 200){    
        liveJSON.forEach(i => {
            let name = i.category_name
            liveCatalog.push(name)
        });
    }
    
    const manifest = {
        id:`org.community.${obj.domainName}` || "org.community.youriptv",
        version:"1.0.0",
        name:obj.domainName + " IPTV" || "Your IPTV",
        description:`You will use username ${obj.username} and password ${obj.password} to access to your ${obj.domainName} IPTV with this addon!`,
        idPrefixes:[obj.idPrefix],
        catalogs:[
            {
                id:`${obj.idPrefix}movie`,
                name: obj.domainName || "Your IPTV",
                type:"movie",
                extra:[{name:"genre",options:movieCatalog,isRequired:true}],
                isRequired: true
            },
            {
                id:`${obj.idPrefix}series`,
                name:obj.domainName || "Your IPTV",
                type:"series",
                extra:[{name:"genre",options:seriesCatalog,isRequired:true}],
                isRequired: true
            },
            {
                id:`${obj.idPrefix}tv`,
                name: obj.domainName || "Your IPTV",
                type:"tv",
                extra:[{name:"genre",options:liveCatalog,isRequired:true}],
            }
        ],
        resources:["catalog","meta","stream"],
        types:["movie","series","tv"],
        behaviorHints:{
            configurable: true,
            configurationRequired: false,
            epgSupported: true
        },
    }

    return manifest
}

function getValidUrl(url) {
    try {
        const urlObj = new URL(url);
        return urlObj.protocol.startsWith('http') ? url : '';
    } catch {
        return '';
    }
}

async function getCatalog(url,type,genre) {
    const obj = getUserData(url)

    let getCategoryID

    try { 
        if(type === "movie"){
            getCategoryID = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_vod_categories`})    
        } 
        else if(type ==="series"){
            getCategoryID = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_series_categories`})    
        } 
        else if(type ==="tv"){
            getCategoryID = await axios({url:`${obj.baseURL}/player_api.php?username=${obj.username}&password=${obj.password}&action=get_live_categories`})    
        }
    }catch (error) {
        return []
    }
   
    let catID
    
    getCategoryID.data.forEach(i => {
        if(i.category_name === genre){
            catID = i.category_id
        }
    });

    let action = type === "movie" ? "get_vod_streams" : type === "series" ? "get_series": type ==="tv" ? "get_live_streams" : "error"

    let paramsCat = {
        username: obj.username,
        password: obj.password,
        action,
        category_id: catID
    }

    let getCatalogs
    try {
        getCatalogs = await axios({url:`${obj.baseURL}/player_api.php`,method:"GET",params:paramsCat})
    } catch (error) {
        return []
    }

    let metas = []

    if (type === "tv") {
        const channelIds = getCatalogs.data
            .filter(i => i.epg_channel_id)
            .map(i => ({
                stream_id: i.stream_id,
                epg_channel_id: i.epg_channel_id
            }));
        let epgInfo;
        try {
            epgInfo = await getEpgInfoBatch(channelIds, obj.baseURL, obj.username, obj.password, obj.timezone);
        } catch (error) {
            // Error handling
        }

        getCatalogs.data.forEach(i => {
            let id = obj.idPrefix + i.stream_id || "";
            let name = i.name;
            let poster = getValidUrl(i.stream_icon);
            let posterShape = "square";

            let meta = { id, type, name, poster, posterShape };

            if (epgInfo && epgInfo[i.stream_id]) {
                const currentProgram = epgInfo[i.stream_id].currentProgram;
                const nextProgram = epgInfo[i.stream_id].nextProgram;

                let description = '';
                if (currentProgram) {
                    description += `Now: ${currentProgram.title}\n${currentProgram.start} - ${currentProgram.description}\n`;
                }
                if (nextProgram) {
                    description += `\nNext: ${nextProgram.title}\n${nextProgram.start} - ${nextProgram.description}`;
                }

                meta.description = description;
            } else {
                meta.description = "No program information available";
            }

            metas.push(meta);
        });
    } else {
        getCatalogs.data.forEach(i => {
            let id, name = i.name, poster, posterShape, imdbRating

            if(type === "series"){
                id = obj.idPrefix + i.series_id || ""
                poster = getValidUrl(i.cover)
                imdbRating = i.rating || ""
                posterShape = "poster"
            }else if(type === "movie"){
                id = obj.idPrefix + i.stream_id || ""
                poster = getValidUrl(i.stream_icon)
                imdbRating = i.rating || ""
                posterShape = "poster"
            }

            metas.push({id,type,name,poster,posterShape,imdbRating})
        });
    }

    return metas
}   

async function getMeta(url,type,id) {
    const streamID = id.split(":")[1]
    const obj = getUserData(url)

    let action = type === "movie" ? "get_vod_info" : type === "series" ? "get_series_info": type ==="tv" ? "get_live_streams" : "error"
    let requestID = type === "movie" ? "vod_id" : type === "series" ? "series_id": type ==="tv" ? "stream_id" : "error"

    let params = {
        username: obj.username,
        password: obj.password,
        action,
        [requestID]:streamID
    }

    if(type === "tv"){
        delete params[requestID]
    }

    let getMeta

    try {
        getMeta = await axios({url:`${obj.baseURL}/player_api.php`,params})
    } catch (error) {
        return {}
    }

    let meta = {}

    if(type === "movie"|| type === "series"){
        meta ={
            id: obj.idPrefix + streamID || "",
            type,
            name: getMeta.data.info.name === undefined ? "" : getMeta.data.info.name,
            poster: getMeta.data.info.cover_big || "",
            background: getMeta.data.info.backdrop_path[0] || "https://www.stremio.com/website/wallpapers/stremio-wallpaper-5.jpg",
            description: getMeta.data.info.description || "",
            releaseInfo: String(getMeta.data && getMeta.data.info && (getMeta.data.info.releaseDate || getMeta.data.info.releasedate).split("-")[0])
        }
    }
       
    if(type === "series"){
        let videos = []
       
        const seasons = Object.keys(getMeta.data.episodes)

        seasons.forEach(season => {
            getMeta.data.episodes[season].forEach(episode => {
                let id = obj.idPrefix + episode.id || ""
                let title = episode.title || ""
                let season = episode.season || null
                let episodeNo = episode.episode_num || null
                let overview = episode.plot || ""
                let thumbnail = episode.info.movie_image || null
                let released = episode.info.releasedate === undefined ? Date.now() : new Date(episode.info.releasedate)
                let container_extension = episode.container_extension || "mp4"

                let streams = [{
                    name:obj.domainName,
                    description: title,
                    url: `${obj.baseURL}/series/${obj.username}/${obj.password}/${episode.id}.${container_extension}`,
                }]

                videos.push({id,title,season,episode:episodeNo,overview,thumbnail,released,streams})
            });
        });

        meta.name = getMeta.data.info.name || "",
        meta.videos = videos

    }else if(type === "movie"){
        let imdbRating = getMeta.data.info.rating || ""
        meta.imdbRating = imdbRating
        
    }else if(type === "tv"){
        let metaTV = [];
        const channelInfo = getMeta.data.find(i => Number(i.stream_id) === Number(streamID));

        if (channelInfo) {
            let id = obj.idPrefix + channelInfo.stream_id;
            let name = channelInfo.name || "";
            let background = "https://www.stremio.com/website/wallpapers/stremio-wallpaper-5.jpg";
            let logo = channelInfo.stream_icon || null;

            try {
                const epgInfo = await handleChannelRequest(channelInfo.epg_channel_id, obj.baseURL, obj.username, obj.password, obj.timezone);
                
                if (epgInfo && epgInfo.currentProgram) {
                    let description = `Now: ${epgInfo.currentProgram.title}\n${epgInfo.currentProgram.start} - ${epgInfo.currentProgram.stop}\n${epgInfo.currentProgram.description || ''}\n\n`;
                    
                    if (epgInfo.nextProgram) {
                        description += `Next: ${epgInfo.nextProgram.title}\n${epgInfo.nextProgram.start} - ${epgInfo.nextProgram.stop}\n${epgInfo.nextProgram.description || ''}`;
                    }

                    metaTV.push({
                        id,
                        name,
                        type,
                        background,
                        logo,
                        poster: logo,
                        posterShape: "square",
                        description: description,
                        genres: ["Live TV"]
                    });
                } else {
                    metaTV.push({ 
                        id, 
                        name, 
                        type, 
                        background, 
                        logo, 
                        poster: logo,
                        posterShape: "square",
                        description: "No program information available",
                        genres: ["Live TV"] 
                    });
                }
            } catch (error) {
                metaTV.push({ 
                    id, 
                    name, 
                    type, 
                    background, 
                    logo, 
                    poster: logo,
                    posterShape: "square",
                    description: "Error fetching program information",
                    genres: ["Live TV"] 
                });
            }
        }

        return metaTV[0];
    }

    return meta
}

module.exports={getUserData,getManifest,getCatalog,getMeta}