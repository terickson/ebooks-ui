FROM node:8.9

RUN mkdir -p /usr/app

WORKDIR /usr/app

COPY . /usr/app/
RUN rm -rf node_modules
RUN npm install

RUN npm run build

CMD node_modules/.bin/serve --single --port=3000 .

EXPOSE 3000
