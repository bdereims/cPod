FROM mhart/alpine-node:latest
MAINTAINER Brice Dereims "bdereims@vmware.com"
COPY package.json /
RUN npm install
ADD ./app.js /app.js
CMD ["node", "./app.js"]
EXPOSE 5000
