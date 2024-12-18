FROM debian:bullseye-slim AS soldity-builder
LABEL description="Solidity builder"
LABEL author="devtools@polygon.technology"

WORKDIR /opt/solidity
RUN apt-get update \
  && apt-get install --yes cmake libboost-all-dev z3 cvc4 git gcc g++ \
  && git clone --branch v0.5.17 https://github.com/ethereum/solidity.git . \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make


FROM node:16-bookworm
LABEL description="MATIC (Polygon PoS) genesis builder image"
LABEL author="devtools@polygon.technology"

ENV DEFAULT_BOR_ID="137"
ENV DEFAULT_HEIMDALL_ID="heimdall-P5rXwg"

COPY --from=soldity-builder /opt/solidity/build/solc /usr/local/bin/

# Prepare environment to build MATIC genesis file.
WORKDIR /opt/genesis-contracts
RUN npm install --global truffle@5.11.5 \
  && git clone https://github.com/maticnetwork/genesis-contracts.git . \
  && git checkout 96a19dd \
  && git submodule init \
  && git submodule update \
  && npm install \
  && cd matic-contracts \
  && git checkout mardizzone/node-16 \
  && npm install \
  && npm run template:process -- --bor-chain-id $DEFAULT_BOR_ID \
  && truffle compile \
  && cd .. \
  && node generate-borvalidatorset.js --bor-chain-id $DEFAULT_BOR_ID --heimdall-chain-id $DEFAULT_HEIMDALL_ID \
  && truffle compile
