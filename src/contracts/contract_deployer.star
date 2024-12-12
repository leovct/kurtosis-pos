constants = import_module("../package_io/constants.star")
genesis_constants = import_module(
    "../prelaunch_data_generator/genesis_constants/genesis_constants.star"
)

CONTRACTS_CONFIG_FILE_PATH = "../../static_files/contracts"


def deploy_contracts(plan, l1, polygon_pos_args, validator_accounts):
    l1_private_key = l1.pre_funded_accounts[
        12
    ].private_key  # reserved for L2 contract deployers
    l1_rpc_url = l1.all_participants[0].el_context.rpc_http_url

    network_params = polygon_pos_args["network_params"]
    bor_id = network_params["bor_id"]
    heimdall_id = network_params["heimdall_id"]
    validator_stake_amount = network_params["validator_stake_amount"]
    validator_top_up_fee_amount = network_params["validator_top_up_fee_amount"]

    matic_contracts_params = polygon_pos_args["matic_contracts_params"]
    contracts_deployer_image = matic_contracts_params["contracts_deployer_image"]

    validator_accounts_formatted = _format_validator_accounts(validator_accounts)

    contracts_config_artifact = plan.upload_files(
        src=CONTRACTS_CONFIG_FILE_PATH,
        name="matic-contracts-deployer-config",
    )

    return plan.run_sh(
        name="matic-contracts-deployer",
        description="Deploying MATIC contracts to L1 and staking for each validator - it can take up to 2 minutes",
        image=contracts_deployer_image,
        env_vars={
            "PRIVATE_KEY": l1_private_key,
            "L1_RPC_URL": l1_rpc_url,
            "BOR_ID": bor_id,
            "DEFAULT_BOR_ID": constants.DEFAULT_BOR_ID,
            "HEIMDALL_ID": heimdall_id,
            "VALIDATOR_ACCOUNTS": validator_accounts_formatted,
            "VALIDATOR_BALANCE": constants.VALIDATORS_BALANCE_ETH,
            "VALIDATOR_STAKE_AMOUNT": validator_stake_amount,
            "VALIDATOR_TOP_UP_FEE_AMOUNT": validator_top_up_fee_amount,
        },
        files={
            "/opt/data": contracts_config_artifact,
        },
        store=[
            StoreSpec(
                src="/opt/contracts/contractAddresses.json",
                name="matic-contract-addresses",
            ),
            StoreSpec(
                src="/opt/contracts/validators.js",
                name="validators-config",
            ),
        ],
        run="bash /opt/data/setup.sh",
    )


def _format_validator_accounts(accounts):
    return ";".join(
        [
            "{},{}".format(account.address, account.full_public_key)
            for account in accounts
        ]
    )
