#!/bin/bash

echo "Press any key to drop to a shell, or wait 10 seconds for a normal start..."

# -t 5: Timeout of 5 seconds
read -s -n 1 -t 10

if [ $? -eq 0 ]; then
    echo "You pressed a key! Dropping to shell.."

    items=(1 "Run everything now!"
        2 "Empty trash now"
        3 "Clean bundles now"
        4 "Optimize DB now"
        5 "Photo Transcoder now"
        6 "Run on schedule"
        )

    while choice=$(dialog --title "$TITLE" \
                    --menu "🦖 Welcome, Elfie, to Kometa ☄️! \nPick your Kometa task:" 20 40 8 "${items[@]}" \
                    2>&1 >/dev/tty)
        do
        case $choice in
            1) python3 /imagemaid.py ;;
            2) EMPTY_TRASH=true python3 /imagemaid.py ;; 
            3) CLEAN_BUNDLES=true python3 /imagemaid.py ;;            
            4) OPTIMIZE_DB=true python3 /imagemaid.py ;;
            5) PHOTO_TRANSCODER=true python3 /imagemaid.py ;;              
            *) SCHEDULE=${SCHEDULE:-'05:00|weekly(sunday)'} python3 /imagemaid.py ;; # some action on other
        esac
    done
    clear # clear after user pressed Cancel

else
    echo "Timeout reached, running ImageMaid on schedule (${SCHEDULE:-'05:00|weekly(sunday)'})..."
    SCHEDULE=${SCHEDULE:-'05:00|weekly(sunday)'} python3 /imagemaid.py
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
