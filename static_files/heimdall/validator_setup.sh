#!/usr/bin/env bash
set -euxo pipefail

# Create Heimdall validator configurations.
# Unfortunately, the Heimdall node id can only be retrieved using `heimdall init`.
# Thus, we need to generate the configs of each validator and aggregate all the node identifiers
# to then be able to create the list of persistent peers.

# Checking environment variables.
if [[ -z "${HEIMDALL_ID}" ]]; then
  echo "Error: HEIMDALL_ID environment variable is not set"
  exit 1
fi
if [[ -z "${HEIMDALL_CONFIG_PATH}" ]]; then
  echo "Error: HEIMDALL_CONFIG_PATH environment variable is not set"
  exit 1
fi
if [[ -z "${VALIDATOR_PRIVATE_KEYS}" ]]; then
  echo "Error: VALIDATOR_PRIVATE_KEYS environment variable is not set"
  exit 1
fi
# Note: VALIDATOR_PRIVATE_KEYS is expected to follow this exact pattern:
# "<private_key1>;<private_key2>;..."
echo "HEIMDALL_ID: ${HEIMDALL_ID}"
echo "HEIMDALL_CONFIG_PATH: ${HEIMDALL_CONFIG_PATH}"
echo "VALIDATOR_PRIVATE_KEYS: ${VALIDATOR_PRIVATE_KEYS}"

setup_validator() {
  local validator_id="${1}"
  local validator_private_key="${2}"

  local validator_config_path="${HEIMDALL_CONFIG_PATH}/${validator_id}"
  echo "Generating config for heimdall validator ${validator_id}..."

  # Create an initial dummy configuration. It is needed by `heimdallcli` to run.
  heimdalld init --home "${validator_config_path}" --chain-id "${HEIMDALL_ID}" --id "${validator_id}"

  # Create the validator key.
  local tmp_dir="$(mktemp -d)"
  pushd "${tmp_dir}"
  heimdallcli generate-validatorkey --home "${validator_config_path}" "${validator_private_key}"
  mv priv_validator_key.json "${validator_config_path}/config/"
  popd
  rm -rf "${tmp_dir}"

  # Drop the temporary genesis.
  rm "${validator_config_path}/config/genesis.json"

  # Retrive and store the node identifier.
  heimdalld init --home "${validator_config_path}" --chain-id "${HEIMDALL_ID}" --id "${validator_id}" 2> "${validator_config_path}/init.out"
  local node_id="$(jq -r '.node_id' ${validator_config_path}/init.out)"
  if [ -z "${node_ids}" ]; then
    node_ids="${node_id}"
  else
    node_ids+=",${node_id}"
  fi

  # Drop the unnecessary files.
  rm -rf "${validator_config_path}"/config/{app.toml,config.toml,heimdall-config.toml,genesis.json}
}

# Loop through validators and set them up.
node_ids=""
id=1
IFS=';' read -ra private_keys <<< "$VALIDATOR_PRIVATE_KEYS"
for private_key in "${private_keys[@]}"; do
  setup_validator "${id}" "${private_key}"
  ((id++))
done

# Store node identifiers.
echo "${node_ids}" > "${HEIMDALL_CONFIG_PATH}/node_ids.txt"
echo "Aggregated node_ids: ${node_ids}"
