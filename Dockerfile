FROM ubuntu:latest AS build

ARG BRANCH="latest"

ENV DEBIAN_FRONTEND=noninteractive

RUN chmod 1777 /tmp && \
    apt-get update -q && \
    apt-get upgrade -qy && \
    apt-get install -qy --no-install-recommends \
      bc \
      ca-certificates \
      gcc \
      git \
      lsb-release \
      make \
      sudo \
      tzdata \
      wget && \
    git clone -b ${BRANCH} \
        https://github.com/Chia-Network/chia-blockchain.git && \
    cd /chia-blockchain && \
    git submodule update --init mozilla-ca && \
    /bin/bash install.sh

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 8555
EXPOSE 8444

ENV CHIA_ROOT=/root/.chia/mainnet
ENV keys="generate"
ENV harvester="false"
ENV farmer="false"
ENV plots_dir="/plots"
ENV farmer_address="null"
ENV farmer_port="null"
ENV testnet="false"
ENV upnp="true"
ENV log_level="WARNING"
ENV TZ="UTC"

COPY --from=build /chia-blockchain /chia-blockchain

RUN chmod 1777 /tmp && \
    apt-get update -q && \
    apt-get upgrade -qy && \
    apt-get install -qy --no-install-recommends \
      python3.8-venv \
      tzdata && \
    rm -rf /var/lib/apt/lists/*


ENV PATH=/chia-blockchain/venv/bin/:$PATH
WORKDIR /chia-blockchain
ADD ./entrypoint.sh entrypoint.sh

ENTRYPOINT ["bash", "./entrypoint.sh"]
