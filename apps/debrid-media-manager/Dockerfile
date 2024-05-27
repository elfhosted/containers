# Get the elfhosted code
ARG VERSION
FROM debridmediamanager/debrid-media-manager:${VERSION}

# Switch to postgres
RUN sed -i -e 's/mysql/postgres/' prisma/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/index.js \
    echo "downloading worlists" \
    wget https://raw.githubusercontent.com/debridmediamanager/debrid-media-manager/raw/main/wordlist.txt \
    wget https://raw.githubusercontent.com/debridmediamanager/debrid-media-manager/main/bannedwordlist.txt \
    wget https://raw.githubusercontent.com/debridmediamanager/debrid-media-manager/main/bannedwordlist2.txt

# Apply ElfHosted branding (soon)