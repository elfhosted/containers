ARG VERSION
FROM gotson/komga:${VERSION}


# The upstream image is at https://github.com/gotson/komga/blob/master/komga/Dockerfile, in this case
# we're simply using it, but ensuring that security-critical variables such as USER and ENTRYPOINT
# are under our control
USER 568
ENV KOMGA_CONFIGDIR="/config"
ENV LC_ALL=en_US.UTF-8
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher", "--spring.config.additional-location=file:/config/"]
EXPOSE 8080
LABEL org.opencontainers.image.source="https://github.com/gotson/komga"
