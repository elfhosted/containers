#!/usr/bin/env node

const axios = require("axios");
const landingTemplate = require("./landingTemplate.js");
const express = require("express");
const cors = require("cors");
const app = express();
const e = require("express");
const obo = false;

const { makeProviders, makeStandardFetcher, targets } = require('@movie-web/providers');
const myFetcher = makeStandardFetcher(fetch);
const providers = makeProviders({
  fetcher: myFetcher,
  target: targets.NATIVE
})

const port = process.env.PORT || 8001;
const manifest = {
  id: process.env.CUSTOM_ID_SUFFIX ? `community.shluflix-${process.env.CUSTOM_ID_SUFFIX}` : `community.shluflix`,
  version: "1.1.1",
  catalogs: [],
  resources: ["stream"],
  types: ["movie", "series"],
  name: process.env.CUSTOM_ID_SUFFIX ? `Shluflix - ${process.env.CUSTOM_ID_SUFFIX}` : `Shluflix | ElfHosted`,
  background:
    "https://unsplash.com/photos/gPm8h3DS1s4/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MTF8fGJhY2tncm91bmQlMjBkYXJrfGVufDB8fHx8MTcyMjg0MzcyMXww&force=true&w=1920",
  logo: "https://elfhosted.com/images/logo.svg",
  description: "Get a working http stream!",
  idPrefixes: ["tt"],
  behaviorHints: {
    configurable: false,
    configurationRequired: false,
  }
};

app.use(cors());

app.get("/", (_, res) => {
  res.redirect("/configure");
  res.end();
});

app.get("/:config?/manifest.json", (req, res) => {
  let manifestRespBuf = JSON.stringify(manifest);
  const { config } = req.params;
  if (
    config &&
    manifest.behaviorHints &&
    (manifest.behaviorHints.configurationRequired ||
      manifest.behaviorHints.configurable)
  ) {
    const manifestClone = manifest;
    delete manifestClone.behaviorHints.configurationRequired;
    //delete manifestClone.behaviorHints.configurable;
    manifestRespBuf = JSON.stringify(manifestClone);
  }
  res.setHeader("Content-Type", "application/json; charset=utf-8");
  res.end(manifestRespBuf);
});

app.get("/:config?/configure", (req, res) => {
  const { config } = req.params;
  const landingHTML = landingTemplate(manifest, config ? JSON.parse(config) : {});
  res.setHeader("content-type", "text/html");
  res.end(landingHTML);
});

app.get("/:config?/stream/:type/:id.json", async (req, res) => {
  try {
    let type = req.params.type;
    let id = req.params.id;
    let meta;
    let media;
    let tmdb_find = await axios.get(`https://api.themoviedb.org/3/find/${id.split(":")[0]}?api_key=8d6d91941230817f7807d643736e8a49&external_source=imdb_id`);
    if (type === "movie" && tmdb_find.data.movie_results.length > 0) {
      meta = tmdb_find.data.movie_results[0];
      media = {
        type: 'movie',
        title: meta.title,
        releaseYear: parseInt(meta.release_date.split("-")[0]),
        tmdbId: meta.id.toString()
      }
    } else if (type === "series" && tmdb_find.data.tv_results.length > 0) {
      meta = tmdb_find.data.tv_results[0];
      media = {
        type: 'show',
        title: meta.name,
        releaseYear: parseInt(meta.first_air_date.split("-")[0]),
        tmdbId: meta.id.toString(),
        season: {
          number: parseInt(id.split(":")[1]),
        },
        episode: {
          number: parseInt(id.split(":")[2]),
        }
      }
    } else {
      res.send({
        streams: []
      });
      res.end();
    }

    console.log(`Got request to play ${media.type}: ${media.title} (${media.releaseYear}) ${media.season ? `S${media.season.number}` : ""}${media.episode ? `E${media.episode.number}` : ""}`)

    let output = null;
    let stream = null;
    let end_provider;
    let breaker = false;
    if (obo) {
      for (let provider of ['showbox', 'vidsrc', 'zoechip', 'flixhq', 'vidsrcto', 'nepu', 'gomovies', 'ridomovies', 'smashystream', 'remotestream']) { //, 'goojara'
        try {
          output = await providers.runSourceScraper({
            id: provider,
            media: media,
          })
        } catch (err) {
          continue;
        }
        if (output) {
          for (let embed of output.embeds) {
            try {
              stream = await providers.runEmbedScraper({
                id: embed.embedId,
                url: embed.url,
              }) 
            } catch (err) {
                continue;
            }
            if (stream) {
              stream = stream.stream[0];
              end_provider = provider;
              breaker = true;
              break;
            }
          }
          if (breaker) {
            break;
          }
        }
      }
    } else {
      output = await providers.runAll({
        media: media
      })
      stream = output.stream;
      end_provider = output.sourceId;
    }

    if (stream == null) {
      res.send({
        streams: []
      });
      res.end();
    } 

    if (stream.type == "hls") {
      res.send({
        streams: [{
          name: `Shluflix`,
          description: `Source: ${end_provider}`,
          url: stream.playlist
        }]
      });
      res.end();
    }
    if (stream.type == "file") {
      let qualities = stream.qualities;
      res.send({
        streams: Object.keys(qualities).map(quality => {
          return {
            name: `Shluflix`,
            description: `${quality}p\nSource: ${end_provider}`,
            url: qualities[quality].url
          }
        })
      });
      res.end();
    }
  } catch (error) {
    res.status(400);
    //res.json({ error: "Illegal request" });
  }
});

app.listen(port, () => {
  console.log(`Stremio shluflix addon listening on port ${port}`);
  /*for (let provider of providers.listSources()) {
    console.log(provider.id);
  }*/
});