ethereum_package = import_module(
    "github.com/ethpandaops/ethereum-package/main.star@4.4.0"
)

contract_deployer = import_module("./src/contracts/contract_deployer.star")
genesis_constants = import_module(
    "./src/prelaunch_data_generator/genesis_constants/genesis_constants.star"
)
input_parser = import_module("./src/package_io/input_parser.star")
wait = import_module("./src/wait/wait.star")


def run(plan, args):
    # Parse L1 and L2 input args.
    args = input_parser.input_parser(plan, args)
    ethereum_args = args.get("ethereum_package")
    polygon_pos_args = args.get("polygon_pos_package")

    # Sanity check the number of validators.
    # TODO: Remove this limitation.
    participants = polygon_pos_args["participants"]
    number_validators = count_validators(participants)
    validator_prefunded_accounts = genesis_constants.PRE_FUNDED_ACCOUNTS
    max_number_validators = len(validator_prefunded_accounts)
    if number_validators > max_number_validators:
        fail(
            "Having more than {} validators is not supported for now.".format(
                max_number_validators
            )
        )

    # Sanity check the mnemonic used.
    # TODO: Remove this limitation.
    l2_network_params = polygon_pos_args["network_params"]
    preregistered_validator_keys_mnemonic = l2_network_params[
        "preregistered_validator_keys_mnemonic"
    ]
    default_l2_mnemonic = input_parser.DEFAULT_POLYGON_POS_PACKAGE_ARGS[
        "network_params"
    ]["preregistered_validator_keys_mnemonic"]
    if preregistered_validator_keys_mnemonic != default_l2_mnemonic:
        fail("Using a different mnemonic is not supported for now.")

    # Merge the user-specified prefunded accounts and the validator prefunded accounts.
    prefunded_accounts = genesis_constants.to_ethereum_pkg_pre_funded_accounts(
        validator_prefunded_accounts
    )
    l1_network_params = ethereum_args.get("network_params", {})
    user_prefunded_accounts_str = l1_network_params.get("prefunded_accounts", "")
    if user_prefunded_accounts_str != "":
        user_prefunded_accounts = json.decode(user_prefunded_accounts_str)
        prefunded_accounts = prefunded_accounts | user_prefunded_accounts
    ethereum_args["network_params"] = l1_network_params | {
        "prefunded_accounts": prefunded_accounts
    }

    plan.print(
        "Deploying a local L1 with the following input args: {}".format(ethereum_args)
    )
    l1 = ethereum_package.run(plan, ethereum_args)
    plan.print(l1)
    l1_config_env_vars = get_l1_config(
        l1.all_participants, l1.network_params, l1.network_id
    )

    wait.wait_for_startup(plan, l1_config_env_vars)
    contract_deployer.deploy_contracts(plan, l1, polygon_pos_args)

    number_participants = len(participants)
    plan.print(
        "Launching a Polygon PoS devnet with {} participants and the following network params: {}".format(
            number_participants, participants
        )
    )


def get_l1_config(all_l1_participants, l1_network_params, l1_network_id):
    env_vars = {}
    env_vars["CL_RPC_URL"] = str(all_l1_participants[0].cl_context.beacon_http_url)
    return env_vars


def count_validators(participants):
    return len([p for p in participants if p.get("is_validator", False)])
