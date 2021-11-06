FROM node:12-alpine
RUN tar -xvf /_dependencies/hugo_0.64.1_Linux-32bit.tar.gz -C /usr/local/bin
RUN curl -fsSL https://deb.nodesource.com/setup_17.x
RUN sudo -E bash -apt-get install -y nodejs
RUN npm install
RUN npm run server


