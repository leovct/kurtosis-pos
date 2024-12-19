constants = import_module("../../package_io/constants.star")


EL_GENESIS_CONFIG_FOLDER_PATH = "../../../static_files/genesis"


def generate_el_genesis_data(plan, polygon_pos_args, validator_config_artifact):
    matic_contracts_params = polygon_pos_args["matic_contracts_params"]
    genesis_builder_image = matic_contracts_params["genesis_builder_image"]

    network_params = polygon_pos_args["network_params"]
    bor_id = network_params["bor_id"]
    heimdall_id = network_params["heimdall_id"]

    genesis_config_artifact = plan.upload_files(
        src=EL_GENESIS_CONFIG_FOLDER_PATH,
        name="matic-genesis-builder-config",
    )

    return plan.run_sh(
        name="el-genesis-generator",
        description="Generating L2 EL genesis",
        image=genesis_builder_image,
        env_vars={
            "BOR_ID": bor_id,
            "DEFAULT_BOR_ID": constants.DEFAULT_BOR_ID,
            "HEIMDALL_ID": heimdall_id,
            "DEFAULT_HEIMDALL_ID": constants.DEFAULT_HEIMDALL_ID,
        },
        files={
            # TODO: Load the artefacts one by one instead of using a Directory because it is not
            # supported by Kurtosis when using plan.run_sh unfortunately.
            "/opt/data/genesis": genesis_config_artifact,
            "/opt/data/validator": validator_config_artifact,
        },
        store=[
            StoreSpec(
                src="/opt/genesis-contracts/genesis.json",
                name="l2-el-genesis",
            ),
        ],
        run="bash /opt/data/genesis/genesis-builder.sh",
    )
