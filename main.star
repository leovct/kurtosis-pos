input_parser = import_module("./src/package_io/input_parser.star")


def run(plan, args):
    plan.print("Deploying a Polygon PoS devnet")
    args = input_parser.input_parser(plan, args)
    plan.print("Input args parsed: {}".format(str(args)))
