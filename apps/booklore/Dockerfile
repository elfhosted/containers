FROM alpine as cloner
ARG VERSION
RUN apk add --update --no-cache tmux ttyd git && \
    git clone -b $VERSION https://github.com/adityachandelgit/BookLore.git  /source

# Stage 1: Build the Angular app
FROM node:22-alpine AS angular-build

WORKDIR /angular-app

COPY --from=cloner /source/booklore-ui/package.json /source/booklore-ui/package-lock.json ./
RUN npm install --force
COPY --from=cloner /source/booklore-ui /angular-app/

RUN npm run build --configuration=production

# Stage 2: Build the Spring Boot app with Gradle
FROM gradle:8-jdk21-alpine AS springboot-build

WORKDIR /springboot-app

COPY --from=cloner /source/booklore-api/build.gradle /source/booklore-api/settings.gradle /springboot-app/
COPY --from=cloner /source/booklore-api/src /springboot-app/src

# Inject version into application.yaml using yq
RUN apk add --no-cache yq && \
    yq eval '.app.version = strenv(VERSION)' -i /springboot-app/src/main/resources/application.yaml

RUN gradle clean build

# Stage 3: Final image
FROM eclipse-temurin:21-jre-alpine

RUN apk update && apk add nginx gettext

COPY --from=cloner /source/nginx.conf /etc/nginx/nginx.conf
COPY --from=angular-build /angular-app/dist/booklore/browser /usr/share/nginx/html
COPY --from=springboot-build /springboot-app/build/libs/booklore-api-0.0.1-SNAPSHOT.jar /app/app.jar

# In ElfHosted, we can only mount a single config volume to the container, which presents a problem for 
# Booklore's bookdrop volumes. This is a dirty workaround to avoid surprising the user..
RUN rm -rf /bookdrop && \
    mkdir -p /app/data/bookdrop && \
    ln -s /app/data/bookdrop /

EXPOSE 8080 80

CMD /usr/sbin/nginx -g "daemon off;" & \
    java -jar /app/app.jar
