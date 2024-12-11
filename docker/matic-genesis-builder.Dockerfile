FROM node:16-bookworm
LABEL description="MATIC (Polgon PoS) genesis builder image"
LABEL author="devtools@polygon.technology"

# Prepare environment to build MATIC genesis file.
WORKDIR /opt/genesis-contracts
RUN git clone https://github.com/maticnetwork/genesis-contracts.git . \
  && git checkout 96a19dd \
  && git submodule init \
  && git submodule update \
  && npm install
