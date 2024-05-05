# Get the elfhosted code
ARG VERSION
FROM debridmediamanager/debrid-media-manager:${VERSION}

# Switch to postgres
sed -i -e 's/mysql/postgres/' prisma/schema.prisma

# Apply ElfHosted branding (soon)