#!/bin/bash -e

(
    docker run \
        -v $(pwd)/src:/app/src \
        -v $(pwd)/.cargo-cache:/usr/local/cargo/registry \
        -v $(pwd)/target:/app/target \
        -v $(pwd)/Cargo.toml:/app/Cargo.toml \
        -v $(pwd)/Cargo.lock:/app/Cargo.lock \
        --entrypoint bash \
        rustlang/rust:nightly \
        -c "cd /app && cargo build --release"

    mv target/release/stovoy-tech target/stovoy-tech
    \cp -f resources/nginx-ssl.conf resources/nginx.conf
) &

(cd static && yarn build) &

wait

mkdir -p static/dist
docker build -t stovoy.tech .

docker tag stovoy.tech stovoy/stovoy.tech
docker push stovoy/stovoy.tech

ssh stovoy.tech 'docker pull stovoy/stovoy.tech &&
    ( docker rm -f stovoy.tech > /dev/null 2>&1 || true ) &&
    docker run \
        --publish 80:80 \
        --publish 443:443 \
        --name stovoy.tech \
        --link sandbox \
        --volume /etc/letsencrypt:/ssl \
        --log-opt max-size=500m \
        --log-opt max-file=5 \
        --detach \
        stovoy/stovoy.tech'
