ethereum_package = import_module(
    "github.com/ethpandaops/ethereum-package/main.star@4.4.0"
)

input_parser = import_module("./src/package_io/input_parser.star")
wait = import_module("./src/wait/wait.star")


def run(plan, args):
    args = input_parser.input_parser(plan, args)
    ethereum_args = args.get("ethereum_package")
    polygon_pos_args = args.get("polygon_pos_package")

    plan.print("Deploying a local L1")
    l1 = ethereum_package.run(plan, ethereum_args)
    plan.print(l1.network_params)
    l1_config_env_vars = get_l1_config(
        l1.all_participants, l1.network_params, l1.network_id
    )

    plan.print("Waiting for L1 to start up")
    wait.wait_for_startup(plan, l1_config_env_vars)

    number_participants = len(polygon_pos_args["participants"])
    plan.print(
        "Launching a Polygon PoS devnet with {} participants and the following network params: {}".format(
            number_participants, polygon_pos_args["participants"]
        )
    )


def get_l1_config(all_l1_participants, l1_network_params, l1_network_id):
    env_vars = {}
    env_vars["CL_RPC_URL"] = str(all_l1_participants[0].cl_context.beacon_http_url)
    return env_vars
