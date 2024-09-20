#!/bin/bash

echo "Press any key to drop to a shell, or wait 10 seconds for a normal start..."

# -t 5: Timeout of 5 seconds
read -s -n 1 -t 10

if [ $? -eq 0 ]; then
    echo "You pressed a key! Dropping to shell.."

    items=(1 "Run everything now!"
        2 "Resume latest run"
        3 "Run overlays now"
        4 "Run collections now"
        5 "Run operations now"
        6 "Run playlists now"
        7 "Run metadata now"
        8 "Run on schedule (12PM UTC)"
        )

    while choice=$(dialog --title "$TITLE" \
                    --menu "🦖 Welcome, Elfie, to Kometa ☄️! \nPick your Kometa task:" 20 40 8 "${items[@]}" \
                    2>&1 >/dev/tty)
        do
        case $choice in
            1) KOMETA_RUN=true python3 kometa.py ;;
            2) KOMETA_RESUME=true python3 kometa.py ;; 
            3) KOMETA_RUN=true KOMETA_OVERLAYS_ONLY=true python3 kometa.py ;;            
            4) KOMETA_RUN=true KOMETA_COLLECTIONS_ONLY=true python3 kometa.py ;;
            5) KOMETA_RUN=true KOMETA_OPERATIONS_ONLY=true python3 kometa.py ;; 
            6) KOMETA_RUN=true KOMETA_PLAYLISTS_ONLY=true python3 kometa.py ;; 
            7) KOMETA_RUN=true KOMETA_METADATA_ONLY=true python3 kometa.py ;;           
            8) KOMETA_TIMES=12:00 python3 kometa.py ;;              
            *) ;; # some action on other
        esac
    done
    clear # clear after user pressed Cancel

else
    echo "Timeout reached, running KOMETA as on schedule (${KOMETA_TIMES:-12:00})..."
    KOMETA_TIMES=${KOMETA_TIMES:-12:00} python3 kometa.py
fi








# elfbot env plexmetamanager KOMETA_TIMES=05:00

# # To run Kometa immediately:

# elfbot env plexmetamanager KOMETA_RUN=true

# # To run only for metadata (not immediately, just when a run is triggered):

# elfbot env plexmetamanager KOMETA_METADATA_ONLY=true

# # To run only for overlays  (not immediately, just when a run is triggered):

# elfbot env plexmetamanager KOMETA_OVERLAYS_ONLY=true

# # To run only for collections (not immediately, just when a run is triggered):

# elfbot env plexmetamanager KOMETA_COLLECTIONS_ONLY=true
