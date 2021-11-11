FROM nginx:alpine as build

RUN apk add --update \
    wget
RUN apk add --update \
    git
RUN apk add --update \
    nodejs
RUN apk add --update \
    npm
    
ARG HUGO_VERSION="0.72.0"
RUN wget --quiet "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz" && \
    tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
    mv hugo /usr/bin

COPY ./ /site
WORKDIR /site

RUN hugo

#Copy static files to Nginx
FROM nginx:alpine
COPY --from=build /site/public /usr/share/nginx/html
RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx/nginx.conf /etc/nginx/conf.d/default.conf

RUN chgrp -R root /var/cache/nginx /var/run /var/log/nginx && \
    chmod -R 770 /var/cache/nginx /var/run /var/log/nginx

WORKDIR /usr/share/nginx/html
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]