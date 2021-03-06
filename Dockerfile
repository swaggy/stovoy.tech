FROM debian:stretch-slim

WORKDIR /app
EXPOSE 80 443
ENTRYPOINT ["/app/entrypoint.sh"]

RUN apt-get update && \
    apt-get install -y openssl nginx procps && \
    rm -rf /var/lib/apt/cache
ADD resources/entrypoint.sh /app/entrypoint.sh
ADD resources/nginx.conf /app/nginx.conf
ADD target/stovoy-tech /app/stovoy-tech
ADD static/dist /app/static
