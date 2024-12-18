FROM maticnetwork/heimdall:v1.0.3 AS heimdall

FROM debian:bullseye-slim
LABEL description="Heimdall genesis builder image"
LABEL author="devtools@polygon.technology"

ENV DEFAULT_HEIMDALL_ID="heimdall-P5rXwg"
ENV HEIMDALL_CONFIG_PATH="/etc/heimdall"

COPY --from=heimdall /go/bin/heimdalld /go/bin/heimdallcli /usr/local/bin/

RUN apt-get update \
  && apt-get install --yes --no-install-recommends jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && heimdalld init --home "${HEIMDALL_CONFIG_PATH}" --chain-id "${DEFAULT_HEIMDALL_ID}"
