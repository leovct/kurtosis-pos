genesis_constants = import_module(
    "../prelaunch_data_generator/genesis_constants/genesis_constants.star"
)

CONTRACTS_CONFIG_FILE_PATH = "../../static_files/contracts"


def deploy_contracts(plan, l1, polygon_pos_args):
    l1_private_key = l1.pre_funded_accounts[
        12
    ].private_key  # reserved for L2 contract deployers
    l1_rpc_url = l1.all_participants[0].el_context.rpc_http_url

    participants = polygon_pos_args["participants"]
    validator_accounts = get_validator_accounts(participants)

    network_params = polygon_pos_args["network_params"]
    heimdall_id = network_params["heimdall_id"]
    validator_stake_amount = network_params["validator_stake_amount"]
    validator_top_up_fee_amount = network_params["validator_top_up_fee_amount"]

    matic_contracts_params = polygon_pos_args["matic_contracts_params"]
    contracts_deployer_image = matic_contracts_params["contracts_deployer_image"]

    contracts_config_artifact = plan.upload_files(
        src=CONTRACTS_CONFIG_FILE_PATH,
        name="matic-contracts-deployer-config",
    )

    contracts_deployer = plan.run_sh(
        name="matic-contracts-deployer",
        description="Deploying MATIC contracts to L1 and staking for each validator - it can take up to 2 minutes",
        image=contracts_deployer_image,
        env_vars={
            "PRIVATE_KEY": l1_private_key,
            "L1_RPC_URL": l1_rpc_url,
            "HEIMDALL_ID": heimdall_id,
            "VALIDATOR_ACCOUNTS": validator_accounts,
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
        ],
        run="bash /opt/data/setup.sh",
    )


def get_validator_accounts(participants):
    prefunded_accounts = genesis_constants.PRE_FUNDED_ACCOUNTS
    validators = []
    index = 0
    for participant in participants:
        if participant["is_validator"]:
            account = prefunded_accounts[index]
            validators.append("{} {}".format(account.address, account.full_public_key))
            index += 1
    return "\n".join(validators)
