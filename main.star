ethereum_package = import_module(
    "github.com/ethpandaops/ethereum-package/main.star@4.4.0"
)

contract_deployer = import_module("./src/contracts/contract_deployer.star")
el_genesis_generator = import_module(
    "./src/prelaunch_data_generator/el_genesis/el_genesis_generator.star"
)
genesis_constants = import_module(
    "./src/prelaunch_data_generator/genesis_constants/genesis_constants.star"
)
input_parser = import_module("./src/package_io/input_parser.star")
wait = import_module("./src/wait/wait.star")


def run(plan, args):
    # Parse L1, L2 and dev input args.
    args = input_parser.input_parser(plan, args)
    ethereum_args = args.get("ethereum_package", {})
    polygon_pos_args = args.get("polygon_pos_package", {})
    participants = polygon_pos_args["participants"]
    dev_args = args.get("dev", {})

    # Deploy local L1 if needed.
    should_deploy_l1 = dev_args["should_deploy_l1"]
    if should_deploy_l1 == True:
        plan.print(
            "Deploying a local L1 with the following input args: {}".format(
                ethereum_args
            )
        )

        l2_network_params = polygon_pos_args["network_params"]
        preregistered_validator_keys_mnemonic = l2_network_params[
            "preregistered_validator_keys_mnemonic"
        ]
        l1 = deploy_local_l1(plan, ethereum_args, preregistered_validator_keys_mnemonic)
        l1_context = struct(
            private_key=l1.pre_funded_accounts[
                12
            ].private_key,  # reserved for L2 contract deployers
            rpc_url=l1.all_participants[0].el_context.rpc_http_url,
        )
    else:
        plan.print("Using an external l1")
        l1_context = struct(
            private_key=dev_args["l1_private_key"],
            rpc_url=dev_args["l1_rpc_url"],
        )

    # Deploy MATIC contracts if needed.
    should_deploy_matic_contracts = dev_args["should_deploy_matic_contracts"]
    if should_deploy_matic_contracts == True:
        validator_accounts = get_validator_accounts(participants)
        plan.print("Number of validators: " + str(len(validator_accounts)))
        plan.print(validator_accounts)

        plan.print("Deploying MATIC contracts to L1 and staking for each validator")
        result = contract_deployer.deploy_contracts(
            plan, l1_context, polygon_pos_args, validator_accounts
        )
        validator_config_artifact = result.files_artifacts[1]

        result = el_genesis_generator.generate_el_genesis_data(
            plan, polygon_pos_args, validator_config_artifact
        )
        l2_el_genesis_artifact = result.files_artifacts[0]
    else:
        plan.print("Using L2 genesis provided")
        l2_el_genesis_file_content = read_file(src=dev_args["l2_genesis_filepath"])
        l2_el_genesis_artifact = plan.render_templates(
            name="l2-genesis",
            config={
                "genesis.json": struct(template=l2_el_genesis_file_content, data={})
            },
        )

    # Deploy network participants.
    plan.print(
        "Launching a Polygon PoS devnet with {} participants and the following network params: {}".format(
            len(participants), participants
        )
    )


def get_validator_accounts(participants):
    prefunded_accounts = genesis_constants.PRE_FUNDED_ACCOUNTS
    max_number_validators = len(prefunded_accounts)

    validator_accounts = []
    index = 0
    for participant in participants:
        if participant["is_validator"]:
            count = participant.get("count", 1)
            for _ in range(count):
                account = prefunded_accounts[index]
                validator_accounts.append(account)
                index += 1
                if index >= max_number_validators:
                    # TODO: Remove this limitation.
                    fail(
                        "Having more than {} validators is not supported for now.".format(
                            max_number_validators
                        )
                    )
    return validator_accounts


def deploy_local_l1(plan, ethereum_args, preregistered_validator_keys_mnemonic):
    # Sanity check the mnemonic used.
    # TODO: Remove this limitation.
    default_l2_mnemonic = input_parser.DEFAULT_POLYGON_POS_PACKAGE_ARGS[
        "network_params"
    ]["preregistered_validator_keys_mnemonic"]
    if preregistered_validator_keys_mnemonic != default_l2_mnemonic:
        fail("Using a different mnemonic is not supported for now.")

    # Merge the user-specified prefunded accounts and the validator prefunded accounts.
    prefunded_accounts = genesis_constants.to_ethereum_pkg_pre_funded_accounts(
        genesis_constants.PRE_FUNDED_ACCOUNTS
    )
    l1_network_params = ethereum_args.get("network_params", {})
    user_prefunded_accounts_str = l1_network_params.get("prefunded_accounts", "")
    if user_prefunded_accounts_str != "":
        user_prefunded_accounts = json.decode(user_prefunded_accounts_str)
        prefunded_accounts = prefunded_accounts | user_prefunded_accounts
    ethereum_args["network_params"] = l1_network_params | {
        "prefunded_accounts": prefunded_accounts
    }

    l1 = ethereum_package.run(plan, ethereum_args)
    plan.print(l1)

    l1_config_env_vars = {
        "CL_RPC_URL": str(l1.all_participants[0].cl_context.beacon_http_url),
    }
    wait.wait_for_startup(plan, l1_config_env_vars)
    return l1
