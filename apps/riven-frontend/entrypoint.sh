#!/bin/ash
if [[ -n "$ILIKEFRONTENDDANGER" ]]; then
    
    if [[ -d /tmp/riven-frontend ]]; then
        rm -rf /tmp/riven-frontend
    fi
    cd /tmp        
    git clone -b $ILIKEFRONTENDDANGER  https://github.com/rivenmedia/riven-frontend.git 
    cd riven-frontend

    HOME=/tmp
    mkdir -p ~/.npm-global
    npm config set prefix '~/.npm-global'
    export PATH=~/.npm-global/bin:$PATH

    npm install -g pnpm && pnpm install
    pnpm run build && pnpm prune --prod

    node /tmp/riven-frontend/build
else
    node /riven/build
fi
