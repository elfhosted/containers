FROM alpine:latest as cloner

ARG CHANNEL
ARG VERSION

RUN apk update && apk upgrade && \
    apk add --no-cache git

# Pin to the exact upstream commit the patch in apps/toast-translator/patches/
# was generated against. Cloning a floating `main` would let `git apply` break
# silently the moment upstream pushes a commit touching anime/anime_mapping.py.
# Bump this SHA (and rebase the patch) in lockstep with upstream.
RUN git clone https://github.com/qwertyuiop8899/toast-translator.git /source && \
    git -C /source checkout 97e2d8baa4fd71c3f30ed658170bba51565f6c33

# Apply our patches. `|| exit 1` so a non-applying patch FAILS the build instead
# of silently shipping an image missing the fix.
COPY apps/toast-translator/patches/ /patches/
RUN for p in /patches/*.patch; do echo "applying $p"; git -C /source apply "$p" || exit 1; done

FROM python:3.10-slim-buster
WORKDIR /app
COPY --from=cloner /source/. /app
RUN pip install --no-cache-dir -r requirements.txt
EXPOSE 8080
CMD ["python", "main.py"]