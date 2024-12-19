#!/usr/bin/env bash
set -euxo pipefail

# Deploy MATIC contracts to the root chain and stake for each validator.
# For reference: https://github.com/maticnetwork/contracts/tree/v0.3.11/deploy-migrations

# Setting bor chain id if needed.
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

if [[ "${BOR_ID}" == "${DEFAULT_BOR_ID}" ]]; then
  echo "There is no need to set Bor chain id set since BOR_ID is already set to the default value."
else
  echo "Setting Bor chain id since BOR_ID is different than the default value..."
  npm run template:process -- --bor-chain-id "${BOR_ID}"

  echo "Re-compiling the MATIC contracts..."
  truffle compile
fi

echo "Configuring truffle..."
# Copy the new truffle config.
cp /opt/data/truffle-config.js /opt/contracts/truffle-config.js
# Remove some of the test contracts from the migrations because they exceed the maximum contract code size.
sed -i 's|^.*await deployer.deploy(StakeManagerTestable.*$|// &|' /opt/contracts/migrations/2_deploy_root_contracts.js

# Run the 4 first steps of the migrations.
if [[ -z "${PRIVATE_KEY}" ]]; then
  echo "Error: PRIVATE_KEY environment variable is not set"
  exit 1
fi
if [[ -z "${L1_RPC_URL}" ]]; then
  echo "Error: L1_RPC_URL environment variable is not set"
  exit 1
fi
if [[ -z "${HEIMDALL_ID}" ]]; then
  echo "Error: HEIMDALL_ID environment variable is not set"
  exit 1
fi
echo "L1_RPC_URL: ${L1_RPC_URL}"
echo "HEIMDALL_ID: ${HEIMDALL_ID}"

echo "Running the 4 first steps of the truffle migration..."
truffle migrate --network development --f 1 --to 4 --compile-none

echo "MATIC contracts deployed to the root chain:"
cat /opt/contracts/contractAddresses.json
echo

# Stake for each validator.
if [[ -z "${VALIDATOR_ACCOUNTS}" ]]; then
  echo "Error: VALIDATOR_ACCOUNTS environment variable is not set"
  exit 1
fi
if [[ -z "${VALIDATOR_BALANCE}" ]]; then
  echo "Error: VALIDATOR_BALANCE environment variable is not set"
  exit 1
fi
if [[ -z "${VALIDATOR_STAKE_AMOUNT}" ]]; then
  echo "Error: VALIDATOR_STAKE_AMOUNT environment variable is not set"
  exit 1
fi
if [[ -z "${VALIDATOR_TOP_UP_FEE_AMOUNT}" ]]; then
  echo "Error: VALIDATOR_TOP_UP_FEE_AMOUNT environment variable is not set"
  exit 1
fi
echo "VALIDATOR_ACCOUNTS: ${VALIDATOR_ACCOUNTS}"
# Note: VALIDATOR_ACCOUNTS is expected to follow this exact pattern:
# "<address1>,<full_public_key1>;<address2>,<full_public_key2>;..."
echo "VALIDATOR_BALANCE: ${VALIDATOR_BALANCE}"
echo "VALIDATOR_STAKE_AMOUNT: ${VALIDATOR_STAKE_AMOUNT}"
echo "VALIDATOR_TOP_UP_FEE_AMOUNT: ${VALIDATOR_TOP_UP_FEE_AMOUNT}"

# Create the validator config file.
validator_config_file="validators.js"
jq -n '[]' > "${validator_config_file}"

echo "Staking for each validator node..."
IFS=';' read -ra validator_accounts <<< "$VALIDATOR_ACCOUNTS"
for account in "${validator_accounts[@]}"; do
  IFS=',' read -r address full_public_key <<< "$account"
  npm run truffle exec scripts/stake.js -- --network development "${address}" "${full_public_key}" "${VALIDATOR_STAKE_AMOUNT}" "${VALIDATOR_TOP_UP_FEE_AMOUNT}"
  
  # Update the validator config file.
  jq --arg address "${address}" --arg stake "${VALIDATOR_STAKE_AMOUNT}" --arg balance "${VALIDATOR_BALANCE}" \
     '. += [{"address": $address, "stake": ($stake | tonumber), "balance": ($balance | tonumber)}]' \
     "${validator_config_file}" > "${validator_config_file}.tmp"
     mv "${validator_config_file}.tmp" "${validator_config_file}"
done
echo "exports = module.exports = $(<${validator_config_file})" > "${validator_config_file}"
echo "Validators config created successfully."
