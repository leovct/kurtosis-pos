FROM node:16-bookworm
LABEL description="MATIC (Polygon PoS) genesis builder image"
LABEL author="devtools@polygon.technology"

ENV DEFAULT_BOR_ID="137"
ENV DEFAULT_HEIMDALL_ID="heimdall-P5rXwg"

# Prepare environment to build MATIC genesis file.
WORKDIR /opt/genesis-contracts
RUN npm install --global truffle@5.11.5 \
  && git clone https://github.com/maticnetwork/genesis-contracts.git . \
  && git checkout 96a19dd \
  && git submodule init \
  && git submodule update \
  && npm install \
  && npm run truffle compile \
  && pushd matic-contracts \
  && git checkout mardizzone/node-16 \
  && npm install \
  && npm run template:process -- --bor-chain-id $DEFAULT_BOR_ID \
  && popd \
  && truffle compile \
  && node generate-borvalidatorset.js --bor-chain-id $DEFAULT_BOR_ID --heimdall-chain-id $DEFAULT_HEIMDALL_ID \
  && truffle compile
