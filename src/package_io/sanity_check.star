constants = import_module("./constants.star")

POLYGON_POS_PARAMS = {
    "participants": [
        "el_type",
        "el_image",
        "el_log_level",
        "cl_type",
        "cl_image",
        "cl_log_level",
        "cl_db_image",
        "is_validator",
        "count",
    ],
    "matic_contracts_params": [
        "contracts_deployer_image",
        "genesis_builder_image",
    ],
    "network_params": [
        "network",
        "bor_id",
        "heimdall_id",
        "preregistered_validator_keys_mnemonic",
        "validator_stake_amount",
        "validator_top_up_fee_amount",
    ],
    "additional_services": [
        "tx_spammer",
    ],
}

DEV_PARAMS = [
    "should_deploy_l1",  # boolean
    "l1_private_key",
    "l1_rpc_url",
]


def sanity_check_polygon_args(plan, input_args):
    # Validate top-level config.
    for param in input_args.keys():
        if param not in POLYGON_POS_PARAMS.keys():
            fail(
                'Invalid parameter: "{}". Allowed fields: {}.'.format(
                    param, POLYGON_POS_PARAMS.keys()
                )
            )

    # Validate keys.
    _validate_list_of_dict(input_args, "participants")
    _validate_dict(input_args, "matic_contracts_params")
    _validate_dict(input_args, "network_params")
    _validate_list(input_args, "additional_services")

    # Validate values.
    for p in input_args.get("participants", []):
        _validate_participant(p)

    plan.print("Sanity check passed")


def sanity_check_dev_args(plan, input_args):
    # Validate top-level config.
    for param in input_args.keys():
        if param not in DEV_PARAMS:
            fail(
                'Invalid parameter: "{}". Allowed fields: {}.'.format(
                    param, DEV_PARAMS.keys()
                )
            )

    # Validate values.
    deploy_l1 = input_args.get("should_deploy_l1", True)
    if not deploy_l1:
        l1_private_key = input_args.get("l1_private_key", "")
        if l1_private_key == "":
            fail(
                "`dev.l1_private_key` must be specified when `dev.should_deploy_l1` is set to false!"
            )

        l1_rpc_url = input_args.get("l1_rpc_url", "")
        if l1_rpc_url:
            fail(
                "`dev.l1_rpc_url` must be specified when `dev.should_deploy_l1` is set to false!"
            )


def _validate_list(input_args, category):
    allowed_values = POLYGON_POS_PARAMS[category]
    if category in input_args:
        for item in input_args[category]:
            if item not in allowed_values:
                fail(
                    'Invalid item: "{}" in "{}" list. Allowed items: {}.'.format(
                        item,
                        category,
                        allowed_values,
                    )
                )


def _validate_dict(input_args, category):
    allowed_params = POLYGON_POS_PARAMS[category]
    if category in input_args:
        for param in input_args[category].keys():
            if param not in allowed_params:
                fail(
                    'Invalid key: "{}" in "{}" dict. Allowed keys: {}.'.format(
                        param, category, allowed_params
                    )
                )


def _validate_list_of_dict(input_args, category):
    allowed_keys = POLYGON_POS_PARAMS[category]
    if category in input_args:
        for item in input_args[category]:
            for key in item.keys():
                if key not in allowed_keys:
                    fail(
                        'Invalid key: "{}" in "{}" list of dict. Allowed keys: {}.'.format(
                            key, category, allowed_keys
                        )
                    )


def _validate_participant(p):
    _validate_str(p, "el_type", [constants.EL_TYPE.bor, constants.EL_TYPE.erigon])
    _validate_str(p, "cl_type", [constants.CL_TYPE.heimdall])

    log_values = [constants.LOG_LEVEL.info, constants.LOG_LEVEL.debug]
    _validate_str(p, "el_log_level", log_values)
    _validate_str(p, "cl_log_level", log_values)
    _validate_strictly_positive_int(p, "count")


def _validate_str(input, attribute, allowed_values):
    value = input.get(attribute)
    if value and value not in allowed_values:
        fail(
            'Invalid "{}" attribute: "{}". Allowed value(s): {}.'.format(
                attribute, value, allowed_values
            )
        )


def _validate_strictly_positive_int(input, attribute):
    value = input.get(attribute)
    if value == 0:
        fail(
            'Invalid "{}": must be strictly positive, got: {}.'.format(attribute, value)
        )
