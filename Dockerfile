ARG VERSION=latest
FROM nginx:${VERSION}
LABEL name=agarsoin<sagarlovekrsna@gmail.com>
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt-get install vim tree net-tools iputils-ping sudo git -y

RUN useradd -m -s /bin/bash sagar && \
    echo 'sagar:sagar123' | chpasswd && \
    usermod -aG sudo sagar && \
    echo "sagar ALL=(ALL) ALL" >> /etc/sudoers
COPY --chown=sagar:sagar index.html /usr/share/nginx/html/
RUN chown sagar:sagar /usr/share/nginx/html -R
RUN chown -R sagar:sagar /var/cache/nginx && \
    chown -R sagar:sagar /var/log/nginx
RUN mkdir -p /var/lib/nginx && \
    touch /var/run/nginx.pid && \
    chown -R sagar:sagar /var/run/nginx.pid && \
    chown -R sagar:sagar /var/lib/nginx

USER sagar
VOLUME ["/usr/share/nginx/html"]
EXPOSE 80
ENTRYPOINT  ["nginx", "-g", "daemon off;"]
HEALTHCHECK --interval=10s --timeout=5s --retries=3  CMD curl -f http://localhost:80 || exit 1

