constants = import_module("./constants.star")
sanity_check = import_module("./sanity_check.star")


DEFAULT_EL_IMAGES = {
    constants.EL_TYPE.bor: "maticnetwork/bor:v0.2.17",
    constants.EL_TYPE.erigon: "erigontech/erigon:v2.60.10",
}

DEFAULT_CL_IMAGES = {
    constants.CL_TYPE.heimdall: "maticnetwork/heimdall:v1.0.3",
}

DEFAULT_ETHEREUM_PACKAGE_ARGS = {
    "network_params": {
        "preset": "minimal",
    }
}

DEFAULT_POLYGON_POS_PACKAGE_ARGS = {
    "participants": [
        {
            "el_type": constants.EL_TYPE.bor,
            "el_image": DEFAULT_EL_IMAGES[constants.EL_TYPE.bor],
            "el_log_level": "info",
            "cl_type": constants.CL_TYPE.heimdall,
            "cl_image": DEFAULT_CL_IMAGES[constants.CL_TYPE.heimdall],
            "cl_log_level": "info",
            "count": 1,
        }
    ],
    "network_params": {
        "network": "kurtosis",
        "network_id": "123456",
    },
    "additional_services": [],
}


def input_parser(plan, input_args):
    plan.print("Parsing the L1 input args")
    ethereum_input_args = input_args.get("ethereum_package", {})
    ethereum_args = _parse_ethereum_args(plan, ethereum_input_args)
    plan.print("L1 input args parsed: {}".format(str(ethereum_args)))

    plan.print("Parsing the L2 input args")
    polygon_pos_input_args = input_args.get("polygon_pos_package", {})
    polygon_pos_args = _parse_polygon_pos_args(plan, polygon_pos_input_args)
    plan.print("L2 input args parsed: {}".format(str(polygon_pos_args)))
    return {
        "ethereum_package": ethereum_args,
        "polygon_pos_package": polygon_pos_args,
    }


def _parse_ethereum_args(plan, ethereum_input_args):
    # Set default params if not provided.
    if "network_params" not in ethereum_input_args:
        ethereum_input_args = DEFAULT_ETHEREUM_PACKAGE_ARGS

    for k, v in DEFAULT_ETHEREUM_PACKAGE_ARGS["network_params"].items():
        ethereum_input_args["network_params"].setdefault(k, v)

    # Sort the dict and return the result.
    return _sort_dict_by_values(ethereum_input_args)


def _parse_polygon_pos_args(plan, polygon_pos_input_args):
    sanity_check.sanity_check(plan, polygon_pos_input_args)

    # Parse the polygon pos input args and set defaults if needed.
    result = {}

    participants = polygon_pos_input_args.get("participants", [])
    result["participants"] = _parse_participants(participants)

    network_params = polygon_pos_input_args.get("network_params", {})
    result["network_params"] = _parse_network_params(network_params)

    additional_services = polygon_pos_input_args.get("additional_services", [])
    result["additional_services"] = _parse_additional_services(additional_services)

    # Sort the dict and return the result.
    return _sort_dict_by_values(result)


def _parse_participants(participants):
    # Set default participant if not provided.
    if len(participants) == 0:
        participants = DEFAULT_POLYGON_POS_PACKAGE_ARGS["participants"]

    default_participant = DEFAULT_POLYGON_POS_PACKAGE_ARGS["participants"][0]
    for p in participants:
        # Set default EL image based on `el_type` if provided.
        el_type = p.get("el_type", "")
        el_image = p.get("el_image", "")
        if el_type and not el_image:
            if el_type == constants.EL_TYPE.bor:
                p["el_image"] = DEFAULT_EL_IMAGES[constants.EL_TYPE.bor]
            elif el_type == constants.EL_TYPE.erigon:
                p["el_image"] = DEFAULT_EL_IMAGES[constants.EL_TYPE.erigon]

        # Set default CL image based on `cl_type` if provided
        cl_type = p.get("cl_type", "")
        cl_image = p.get("cl_image", "")
        if cl_type and not cl_image:
            if cl_type == constants.CL_TYPE.heimdall:
                p["cl_image"] = DEFAULT_CL_IMAGES[constants.CL_TYPE.heimdall]

        # Fill in any missing fields with default values.
        for k, v in default_participant.items():
            p.setdefault(k, v)

    # Sort each participant dictionary and return the result
    return [_sort_dict_by_values(p) for p in participants]


def _parse_network_params(network_params):
    # Set default network params if not provided.
    if not network_params:
        network_params = DEFAULT_POLYGON_POS_PACKAGE_ARGS["network_params"]

    for k, v in DEFAULT_POLYGON_POS_PACKAGE_ARGS["network_params"].items():
        network_params.setdefault(k, v)

    # Sort the dict and return the result.
    return _sort_dict_by_values(network_params)


def _parse_additional_services(additional_services):
    # Set default additional services if not provided.
    if len(additional_services) == 0:
        additional_services = DEFAULT_POLYGON_POS_PACKAGE_ARGS["additional_services"]
    return additional_services


def _sort_dict_by_values(d):
    sorted_items = sorted(d.items(), key=lambda x: x[0])
    return {k: v for k, v in sorted_items}
