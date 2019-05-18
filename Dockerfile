FROM node:8-alpine AS build-stage
WORKDIR /app
COPY . .
RUN npm install && \
    npm run build --prod

FROM nginx:alpine
## Copy a new configuration file setting logs base dir to /var/logs/nginx
COPY ./docker/nginx-alpine-custom/nginx.conf /etc/nginx/
## Create the new /var/logs/nginx folder
RUN mkdir /var/logs
RUN mkdir /var/logs/nginx
## Copy a new configuration file setting listen port to 8080
COPY ./docker/nginx-alpine-custom/default.conf /etc/nginx/conf.d/
## Expose port 8080
EXPOSE 8080
## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*
## From 'build' stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=build-stage /app/dist/gcp-cloudrun-gke-angular /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]
