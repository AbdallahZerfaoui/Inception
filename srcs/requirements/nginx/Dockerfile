FROM debian:bullseye-slim

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    nginx \
    openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY config/default /etc/nginx/sites-available/default
COPY config/generate_certificate.sh .

RUN chmod +x generate_certificate.sh

RUN ./generate_certificate.sh && \
    rm generate_certificate.sh

CMD ["nginx", "-g", "daemon off;"]