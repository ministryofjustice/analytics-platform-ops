FROM node:7.4.0-alpine

RUN mkdir /app
ADD package.json /app/
WORKDIR /app
RUN npm install
ADD . /app

CMD ["node", "bin/www"]
