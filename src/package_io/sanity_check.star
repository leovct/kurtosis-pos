constants = import_module("./constants.star")

ALLOWED_PARAMS = {
    "participants": [
        "el_type",
        "el_image",
        "el_log_level",
        "cl_type",
        "cl_image",
        "cl_log_level",
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


def sanity_check(plan, input_args):
    # Validate top-level config.
    for param in input_args.keys():
        if param not in ALLOWED_PARAMS.keys():
            fail(
                'Invalid parameter: "{}". Allowed fields: {}.'.format(
                    param, ALLOWED_PARAMS.keys()
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


def _validate_list(input_args, category):
    allowed_values = ALLOWED_PARAMS[category]
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
    allowed_params = ALLOWED_PARAMS[category]
    if category in input_args:
        for param in input_args[category].keys():
            if param not in allowed_params:
                fail(
                    'Invalid key: "{}" in "{}" dict. Allowed keys: {}.'.format(
                        param, category, allowed_params
                    )
                )


def _validate_list_of_dict(input_args, category):
    allowed_keys = ALLOWED_PARAMS[category]
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
