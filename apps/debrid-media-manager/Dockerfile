# Get the elfhosted code
ARG VERSION
FROM debridmediamanager/debrid-media-manager:${VERSION}

# Switch to postgres
RUN sed -i -e 's/mysql/postgres/' prisma/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/schema.prisma && \
    sed -i -e 's/mysql/postgres/' node_modules/.prisma/client/index.js

# Apply ElfHosted branding (soon)