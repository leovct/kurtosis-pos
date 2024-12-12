constants = import_module("../../package_io/constants.star")


GENESIS_CONFIG_FILE_PATH = "../../../static_files/genesis"


def generate_el_genesis_data(plan, polygon_pos_args, validator_config_artifact):
    matic_contracts_params = polygon_pos_args["matic_contracts_params"]
    genesis_builder_image = matic_contracts_params["genesis_builder_image"]

    network_params = polygon_pos_args["network_params"]
    bor_id = network_params["bor_id"]
    heimdall_id = network_params["heimdall_id"]

    genesis_config_artifact = plan.upload_files(
        src=GENESIS_CONFIG_FILE_PATH,
        name="matic-genesis-builder-config",
    )

    plan.add_service(
        name="el-genesis-generator",
        config=ServiceConfig(
            image=genesis_builder_image,
            env_vars={
                "BOR_ID": bor_id,
                "DEFAULT_BOR_ID": constants.DEFAULT_BOR_ID,
                "HEIMDALL_ID": heimdall_id,
                "DEFAULT_HEIMDALL_ID": constants.DEFAULT_HEIMDALL_ID,
            },
            files={
                "/opt/data": Directory(
                    artifact_names=[genesis_config_artifact, validator_config_artifact],
                ),
            },
            entrypoint=["bash", "-c"],
            cmd=["sleep infinity"],
        ),
    )
