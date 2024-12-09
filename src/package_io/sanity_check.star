constants = import_module("./constants.star")

ALLOWED_PARAMS = {
    "participants": [
        "el_type",
        "el_image",
        "el_log_level",
        "cl_type",
        "cl_image",
        "cl_log_level",
        "count",
    ],
    "network_params": [
        "network",
        "network_id",
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
    validate_list_of_dict(input_args, "participants")
    validate_dict(input_args, "network_params")
    validate_list(input_args, "additional_services")

    # Validate values.
    for p in input_args.get("participants", []):
        validate_participant(p)

    plan.print("Sanity check passed")


def validate_list(input_args, category):
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


def validate_dict(input_args, category):
    allowed_params = ALLOWED_PARAMS[category]
    if category in input_args:
        for param in input_args[category].keys():
            if param not in allowed_params:
                fail(
                    'Invalid key: "{}" in "{}" dict. Allowed keys: {}.'.format(
                        param, category, allowed_params
                    )
                )


def validate_list_of_dict(input_args, category):
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


def validate_participant(p):
    validate_str(p, "el_type", [constants.EL_TYPE.bor, constants.EL_TYPE.erigon])
    validate_str(p, "cl_type", [constants.CL_TYPE.heimdall])

    log_values = [constants.LOG_LEVEL.info, constants.LOG_LEVEL.debug]
    validate_str(p, "el_log_level", log_values)
    validate_str(p, "cl_log_level", log_values)
    validate_count(p)


def validate_str(input, attribute, allowed_values):
    value = input.get(attribute)
    if value and value not in allowed_values:
        fail(
            'Invalid "{}" attribute: "{}". Allowed value(s): {}.'.format(
                attribute, value, allowed_values
            )
        )


def validate_count(input):
    count = input.get("count")
    if count == 0:
        fail("Count must be strictly positive. Got: {}.".format(count))
