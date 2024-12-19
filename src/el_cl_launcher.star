bor = import_module("./el/bor/bor_launcher.star")
constants = import_module("./package_io/constants.star")
erigon = import_module("./el/erigon/erigon_launcher.star")
genesis_constants = import_module(
    "./prelaunch_data_generator/genesis_constants/genesis_constants.star"
)
heimdall = import_module("./cl/heimdall/heimdall_launcher.star")


HEIMDALL_VALIDATOR_CONFIG_GENERATOR_FOLDER_PATH = "../static_files/heimdall"


def launch(
    plan,
    participants,
    validator_accounts,
    polygon_pos_args,
    el_genesis_artifact,
    cl_genesis_artifact,
    l1_rpc_url,
):
    network_params = polygon_pos_args["network_params"]
    matic_contracts_params = polygon_pos_args["matic_contracts_params"]

    el_launchers = {
        "bor": {
            "launch_method": bor.launch,
        },
        "erigon": {
            "launch_method": erigon.launch,
        },
    }

    cl_launchers = {
        "heimdall": {
            "launch_method": heimdall.launch,
        }
    }

    prefunded_accounts = genesis_constants.PRE_FUNDED_ACCOUNTS

    heimdall_config_generator_artifact = _generate_heimdall_config(
        plan, participants, prefunded_accounts, polygon_pos_args
    )
    plan.print(heimdall_config_generator_artifact)

    for i, participant in enumerate(participants):
        plan.print(
            "Launching participant {} with config {}".format(i, str(participant))
        )

        el_type = participant["el_type"]
        if el_type not in el_launchers:
            fail(
                "Unsupported EL launcher '{0}', need one of '{1}'".format(
                    el_type, ",".join(el_launchers.keys())
                )
            )

        cl_type = participant["cl_type"]
        if cl_type not in cl_launchers:
            fail(
                "Unsupported CL launcher '{0}', need one of '{1}'".format(
                    cl_type, ",".join(cl_launchers.keys())
                )
            )

        el_launch_method = el_launchers[el_type]["launch_method"]
        cl_launch_method = cl_launchers[cl_type]["launch_method"]

        el_node_name = "{}-{}".format(el_type, i)
        cl_node_name = "{}-{}".format(cl_type, i)
        prefunded_account = prefunded_accounts[i]
        # cl_context = cl_launch_method(
        #     plan,
        #     i,
        #     cl_node_name,
        #     el_node_name,
        #     participant,
        #     prefunded_account.private_key,
        #     network_params,
        #     cl_genesis_artifact,
        #     l1_rpc_url,
        # )


def _generate_heimdall_config(plan, participants, prefunded_accounts, polygon_pos_args):
    # Get Heimdall validator node and private keys.
    # Also generate the store spec that will be used to save such keys later.
    heimdall_validator_private_keys = []
    heimdall_validator_keys_store = []
    for i, participant in enumerate(participants):
        if participant["cl_type"] == constants.CL_TYPE.heimdall:
            heimdall_validator_private_keys.append(prefunded_accounts[i].private_key)
            heimdall_validator_keys_store.append(
                StoreSpec(
                    src="{}/{}/config/node_key.json".format(
                        constants.HEIMDALL_CONFIG_PATH, i
                    ),
                    name="heimdall-validator-{}-node-key".format(i),
                )
            )
            heimdall_validator_keys_store.append(
                StoreSpec(
                    src="{}/{}/config/priv_validator_key.json".format(
                        constants.HEIMDALL_CONFIG_PATH, i
                    ),
                    name="heimdall-validator-{}-private-key".format(i),
                )
            )
    heimdall_validator_private_keys = ";".join(heimdall_validator_private_keys)

    # Generate Heimdall validators configuration such as the public/private keys and node identifiers.
    heimdall_config_generator_artifact = plan.upload_files(
        src=HEIMDALL_VALIDATOR_CONFIG_GENERATOR_FOLDER_PATH,
        name="heimdall-config-generator-config",
    )

    matic_contracts_params = polygon_pos_args["matic_contracts_params"]
    heimdall_config_generator_image = matic_contracts_params[
        "heimdall_config_generator_image"
    ]

    network_params = polygon_pos_args["network_params"]
    heimdall_id = network_params["heimdall_id"]

    heimdall_config_generator_store = heimdall_validator_keys_store + [
        StoreSpec(
            src="{}/node_ids.txt".format(constants.HEIMDALL_CONFIG_PATH),
            name="heimdall-validators-node-ids",
        )
    ]
    plan.print(
        "DEBUG: heimdall_config_generator_store: {}".format(
            heimdall_config_generator_store
        )
    )
    result = plan.run_sh(
        name="heimdall-validators-config-generator",
        image=heimdall_config_generator_image,
        env_vars={
            "HEIMDALL_ID": heimdall_id,
            "HEIMDALL_CONFIG_PATH": constants.HEIMDALL_CONFIG_PATH,
            "VALIDATOR_PRIVATE_KEYS": heimdall_validator_private_keys,
        },
        files={
            "/opt/data": heimdall_config_generator_artifact,
        },
        store=heimdall_config_generator_store,
        run="bash /opt/data/validator_setup.sh",
    )
    heimdall_config_generator_artifact = result.files_artifacts[0]
    return heimdall_config_generator_artifact
