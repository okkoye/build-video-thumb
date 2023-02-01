FROM alpine:3.17 as build

RUN apk add --no-cache curl ffmpeg=5.0.1-r1
RUN mkdir nginx nginx-thumb-module

ENV NGINX_VERSION 1.18.0
ENV THUMB_MODULE_VERSION 0.9.0

RUN curl -sL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -C nginx --strip 1 -xz
RUN curl -sL https://github.com/wandenberg/nginx-video-thumbextractor-module/archive/${THUMB_MODULE_VERSION}.tar.gz | tar -C nginx-thumb-module --strip 1 -xz

WORKDIR /nginx
RUN ./configure --add-module=../nginx-thumb-module

RUN make
RUN make install

FROM alpine:3.17
RUN apk add --no-cache ffmpeg=5.0.1-r1
COPY --from=build /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN rm -rf /usr/local/nginx/html /usr/loca/nginx/conf/*.default
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]