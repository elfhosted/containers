FROM curlimages/curl AS download

WORKDIR /home/curl_user

RUN mkdir nextpvr && \
    curl -fL -o nextpvr.zip https://nextpvr.com/stable/linux/NPVR.zip && \
    unzip nextpvr.zip -d nextpvr
    

FROM mcr.microsoft.com/dotnet/aspnet:7.0.5

RUN apt-get update && apt-get install -y \
        dtv-scan-tables \
        dvb-tools \
        ffmpeg \
        fuse3 \
        libc6  \
        libc6-dev \
        libdvbv5-0 \
        libgdiplus \
        libmediainfo-dev \
        mediainfo \
        python3 \
        python3-magic \
    && rm -rf /var/lib/apt/lists/*

RUN addgroup elfie --gid 568 && \
    adduser elfie \
        --uid 568 \
        --ingroup elfie \
        --system \
        --disabled-password

COPY --from=download --chown=nextpvr:nextpvr /home/curl_user/nextpvr /nextpvr

WORKDIR /nextpvr

ENV NEXTPVR_DATADIR_USERDATA=/config/

RUN chmod 755 /nextpvr/DeviceHost/x64/DeviceHostLinux && \
   mkdir /config && \
   chown elfie /config && \
   mkdir /recordings && \
   chown elfie /recordings && \
   mkdir /buffer && \
   chown elfie /buffer 

EXPOSE 8866

USER 568

ENV COMPlus_EnableDiagnostics=0

ENTRYPOINT ["/bin/bash", "-c", "dotnet NextPVRServer.dll"]
