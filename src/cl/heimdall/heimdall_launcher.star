# Port identifiers and numbers.
RABBITMQ_AMQP_PORT_ID = "amqp"
RABBITMQ_AMQP_PORT_NUMBER = 5672

HEIMDALL_REST_API_PORT_ID = "http"
HEIMDALL_REST_API_PORT_NUMBER = 1317

HEIMDALL_GRPC_PORT_ID = "grpc"
HEIMDALL_GRPC_PORT_NUMBER = 3132

HEIMDALL_OPENTELEMETRY_PORT_ID = "metrics"
HEIMDALL_OPENTELEMETRY_PORT_NUMBER = 4317

HEIMDALL_NODE_LISTEN_PORT_ID = "node-listen"
HEIMDALL_NODE_LISTEN_PORT_NUMBER = 26656

HEIMDALL_RPC_PORT_ID = "rpc"
HEIMDALL_RPC_PORT_NUMBER = 26657

HEIMDALL_LISTEN_PROXY_PORT_ID = "proxy-listen"
HEIMDALL_PROXY_LISTEN_PORT_NUMBER = 26658

# The folder where the heimdall templates are stored in the repository.
HEIMDALL_TEMPLATES_FOLDER_PATH = "../../../static_files/heimdall"

# The folder where the heimdall config is stored inside the service.
CONFIG_FOLDER_PATH = "/etc/heimdall"
# The folder where the heimdall app stores data inside the service.
APP_DATA_FOLDER_PATH = "/var/lib/heimdall"


def launch(
    plan,
    index,
    cl_node_name,
    el_node_name,
    participant,
    private_key,
    network_params,
    cl_genesis_artifact,
    l1_rpc_url,
):
    rabbitmq_service = plan.add_service(
        name="rabbitmq-{}".format(cl_node_name),
        config=ServiceConfig(
            image=participant["cl_db_image"],
            ports={
                RABBITMQ_AMQP_PORT_ID: PortSpec(
                    number=RABBITMQ_AMQP_PORT_NUMBER,
                    application_protocol="amqp",
                )
            },
        ),
    )
    rabbitmq_amqp_port = rabbitmq_service.ports[RABBITMQ_AMQP_PORT_ID]
    rabbitmq_url = "amqp://{}:{}".format(
        rabbitmq_service.ip_address, rabbitmq_amqp_port.number
    )

    heimdall_config = plan.render_templates(
        config={
            "app.toml": struct(
                template=read_file(
                    "{}/app.toml".format(HEIMDALL_TEMPLATES_FOLDER_PATH)
                ),
                data={},
            ),
            "config.toml": struct(
                template=read_file(
                    "{}/config.toml".format(HEIMDALL_TEMPLATES_FOLDER_PATH)
                ),
                data={
                    # Heimdall network params.
                    "moniker": cl_node_name,
                    "log_level": participant["cl_log_level"],
                    "span_poll_interval": network_params["heimdall_span_poll_interval"],
                    "checkpoint_poll_interval": network_params[
                        "heimdall_checkpoint_poll_interval"
                    ],
                    # Port numbers.
                    "proxy_app_port_number": HEIMDALL_PROXY_LISTEN_PORT_NUMBER,
                    "tendermint_rpc_port_number": HEIMDALL_RPC_PORT_NUMBER,
                    "p2p_listen_port_number": HEIMDALL_NODE_LISTEN_PORT_NUMBER,
                },
            ),
            "heimdall-config.toml": struct(
                template=read_file(
                    "{}/heimdall-config.toml".format(HEIMDALL_TEMPLATES_FOLDER_PATH)
                ),
                data={
                    # URLs.
                    "amqp_url": rabbitmq_url,
                    "bor_rpc_url": "http://{}:8545".format(el_node_name),
                    "l1_rpc_url": l1_rpc_url,
                    # Port numbers.
                    "rest_api_port_number": HEIMDALL_REST_API_PORT_NUMBER,
                    "tendermint_rpc_port_number": HEIMDALL_RPC_PORT_NUMBER,
                },
            ),
        },
        name="{}-config".format(cl_node_name),
    )

    plan.add_service(
        name=cl_node_name,
        config=ServiceConfig(
            image=participant["cl_image"],
            ports={
                HEIMDALL_REST_API_PORT_ID: PortSpec(
                    number=HEIMDALL_REST_API_PORT_NUMBER,
                    application_protocol="http",
                    wait="10s",
                ),
                HEIMDALL_GRPC_PORT_ID: PortSpec(
                    number=HEIMDALL_GRPC_PORT_NUMBER,
                    application_protocol="grpc",
                    wait="10s",
                ),
                HEIMDALL_NODE_LISTEN_PORT_ID: PortSpec(
                    number=HEIMDALL_NODE_LISTEN_PORT_NUMBER,
                    application_protocol="http",
                    wait="10s",
                ),
            },
            files={
                "{}/config".format(CONFIG_FOLDER_PATH): heimdall_config,
                "/opt/data": cl_genesis_artifact,
            },
            entrypoint=["sh", "-c"],
            cmd=[
                "&".join(
                    [
                        "cp /opt/data/genesis.json {}/config".format(
                            CONFIG_FOLDER_PATH
                        ),
                        "heimdalld start --all --bridge --rest-server",
                    ]
                )
            ],
        ),
    )
