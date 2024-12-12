FROM node:16-bookworm
LABEL description="MATIC (Polygon PoS) contracts deployment image"
LABEL author="devtools@polygon.technology"

# Prepare MATIC smart contracts for deployment by compiling them.
# For reference: https://github.com/maticnetwork/contracts/tree/v0.3.11/deploy-migrations
WORKDIR /opt/contracts
RUN npm install --global truffle@5.11.5 \
  && git clone --branch mardizzone/node-16 https://github.com/maticnetwork/contracts.git . \
  && npm install \
  && npm run template:process -- --bor-chain-id 137 \
  && truffle compile
