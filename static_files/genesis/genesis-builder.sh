#!/usr/bin/env bash
set -euxo pipefail

# Build MATIC child chain genesis.
# For reference: https://github.com/maticnetwork/genesis-contracts

# Checking environment variables.
if [[ -z "${BOR_ID}" ]]; then
  echo "Error: BOR_ID environment variable is not set"
  exit 1
fi
if [[ -z "${DEFAULT_BOR_ID}" ]]; then
  echo "Error: DEFAULT_BOR_ID environment variable is not set"
  exit 1
fi
echo "BOR_ID: ${BOR_ID}"
echo "DEFAULT_BOR_ID: ${DEFAULT_BOR_ID}"

if [[ -z "${HEIMDALL_ID}" ]]; then
  echo "Error: HEIMDALL_ID environment variable is not set"
  exit 1
fi
if [[ -z "${DEFAULT_HEIMDALL_ID}" ]]; then
  echo "Error: DEFAULT_HEIMDALL_ID environment variable is not set"
  exit 1
fi
echo "HEIMDALL_ID: ${HEIMDALL_ID}"
echo "DEFAULT_HEIMDALL_ID: ${DEFAULT_HEIMDALL_ID}"

# Regenerate the validator set if needed.
if [[ "${BOR_ID}" == "${DEFAULT_BOR_ID}" && "${HEIMDALL_ID}" == "${DEFAULT_HEIMDALL_ID}" ]]; then
  echo "There is no need to regenerate the validator set since BOR_ID and HEIMDALL_ID are already set to their default values."
else
  echo "Generating the validator set since BOR_ID and/or HEIMDALL_IR are different than the default values..."
  node generate-borvalidatorset.js --bor-chain-id "${BOR_ID}" --heimdall-chain-id "${HEIMDALL_ID}"

  echo "Re-compiling the genesis contracts..."
  truffle compile
fi

# Generate the genesis file.
echo "Generating the genesis file..."
cp /opt/data/validators.js validators.js
node generate-genesis.js --bor-chain-id "${BOR_ID}" --heimdall-chain-id "${HEIMDALL_ID}"
