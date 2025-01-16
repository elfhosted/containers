module.exports = {
    id: "org.community.HYYourIPTV",
    version: "2.0",
    name: "Your EPG IPTV",
    logo: "https://hayd.uk/user_avatar/hayd.uk/hayduk/288/6_2.png",
    description: "This addon brings all the Live Streams, VOD streams and Series from your IPTV subscription to your Stremio using Xtream API.",
    types: ["movie", "series", "tv", "channel"],
    background: "https://unsplash.com/photos/lRwGMe1MFj4/download?ixid=M3wxMjA3fDB8MXxzZWFyY2h8MTh8fGZveHxlbnwwfHx8fDE3MzY5OTI0MTZ8MA&force=true&w=1920",
    resources: ["movie", "series", "tv"],
    catalogs: [],
    idPrefixes: ["yiptv:"],
    behaviorHints: { configurable: true, configurationRequired: true },
};