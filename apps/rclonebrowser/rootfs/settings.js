export const guiVersion = "0.4.0";
export const rcloneSettings = {
    host: "https://pomnz.rclone.elfhosted.com:443",
    // null if --rc-no-auth, otherwise what is set in --rc-user
    user: null,
    // null if --rc-no-auth, otherwise what is set in --rc-pass
    pass: null,
    // null if there is no login_token in URL query parameters,
    // otherwise is set from there and takes over user/pass
    loginToken: null
};
export const asyncOperations = [
    "/sync/copy",
    "/sync/move",
    "/operations/purge",
    "/operations/copyfile",
    "/operations/movefile",
    "/operations/deletefile"
];
export const remotes = {
    "someExampleRemote": {
        "startingFolder": "path/to/some/path/there",
        "canQueryDisk": true,
        "pathToQueryDisk": ""
    }
};
export const userSettings = {
    timerRefreshEnabled: true,
    timerRefreshView: 2,
    timerRefreshViewInterval: undefined,
    timerProcessQueue: 5,
    timerProcessQueueInterval: undefined
};
