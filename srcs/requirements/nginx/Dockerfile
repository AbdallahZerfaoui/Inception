FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    nginx \
    && apt-get clean

COPY config/default /etc/nginx/sites-available/default

CMD ["nginx", "-g", "daemon off;"]