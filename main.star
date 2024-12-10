input_parser = import_module("./src/package_io/input_parser.star")

ethereum_package = import_module(
    "github.com/ethpandaops/ethereum-package/main.star@4.4.0"
)


def run(plan, args):
    args = input_parser.input_parser(plan, args)
    ethereum_args = args.get("ethereum_package")
    polygon_pos_args = args.get("polygon_pos_package")

    plan.print("Deploying a local L1")
    l1 = ethereum_package.run(plan, ethereum_args)

    number_participants = len(polygon_pos_args["participants"])
    plan.print(
        "Launching a Polygon PoS devnet with {} participants and the following network params: {}".format(
            number_participants, polygon_pos_args["participants"]
        )
    )
