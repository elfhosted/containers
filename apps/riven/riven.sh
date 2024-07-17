#!/bin/ash

cd /riven/backend

# Ensure plex is ready
/usr/local/bin/wait-for plex:32400 - echo "plex is up!"
/usr/local/bin/wait-for zurg:9999 - echo "zurg is up!"
echo "let's go!"


if [[ ! -z "$ILIKEDANGER" ]]; then
    echo "Press any key to continue to pull the latest $ILIKEDANGER branch, or wait 10 seconds for a stable start..."
    
    # -t 5: Timeout of 5 seconds
    read -s -n 1 -t 10
    
    if [ $? -eq 0 ]; then
        echo "You pressed a key! Let's go to the danger zone, cloning the $ILIKEDANGER branch!"
        cd /tmp
        if [[ -d /tmp/riven ]]; then
            rm -rf /tmp/riven
        fi
        git clone -b $ILIKEDANGER   https://github.com/rivenmedia/riven.git 
        cd riven
        VIRTUAL_ENV=/app/.venv
        PATH="/app/.venv/bin:$PATH"
        pip install poetry==1.4.2
        ln -s /riven/data/* /tmp/riven/data/
        cd backend
        cp /riven/backend/pyproject.toml ./
        cp /riven/backend/poetry.lock ./
        poetry run python3 main.py 
    else
        echo "Timeout reached. Continuing boring normal start..."
        poetry run python3 main.py 
    fi
fi
poetry run python3 main.py 