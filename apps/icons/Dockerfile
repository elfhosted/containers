FROM nginxinc/nginx-unprivileged:alpine3.22-slim

WORKDIR /tmp
USER root
RUN wget https://github.com/walkxcode/dashboard-icons/archive/refs/heads/main.zip && \
	unzip main.zip && \
	mv dashboard-icons-main/png/* /usr/share/nginx/html/ && \
	rm main.zip && \
	rm -rf dashboard-icons-main

USER nginx
COPY ./apps/homer/png/*.png /usr/share/nginx/html/
