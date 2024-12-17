# Port identifiers.
RABBITMQ_AMQP_PORT_ID = "amqp"
HEIMDALL_RPC_PORT_ID = "rpc"
HEIMDALL_REST_API_PORT_ID = "http"
HEIMDALL_GRPC_PORT_ID = "grpc"

# Port numbers.
RABBITMQ_AMQP_PORT_NUMBER = 5672
HEIMDALL_RPC_PORT_NUMBER = 26657
HEIMDALL_REST_API_PORT_NUMBER = 1317
HEIMDALL_GRPC_PORT_NUMBER = 3132


def launch(plan, name, participant, private_key):
    rabbitmq_service = plan.add_service(
        name="rabbitmq-{}".format(name),
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

    # TODO: Add the private key under /var/lib/heimdall/hexprivatekey.txt

    plan.add_service(
        name=name,
        config=ServiceConfig(
            image=participant["cl_image"],
            ports={
                HEIMDALL_RPC_PORT_ID: PortSpec(
                    number=HEIMDALL_RPC_PORT_NUMBER,
                    application_protocol="http",
                ),
                HEIMDALL_REST_API_PORT_ID: PortSpec(
                    number=HEIMDALL_REST_API_PORT_NUMBER,
                    application_protocol="http",
                ),
                HEIMDALL_GRPC_PORT_ID: PortSpec(
                    number=HEIMDALL_GRPC_PORT_NUMBER,
                    application_protocol="grpc",
                ),
            },
            files={},
            entrypoint=["sh", "-c"],
            cmd=[
                "heimdalld start --amqp_url {} --all --bridge --rest-server --rpc.laddr tcp://0.0.0.0:{}".format(
                    rabbitmq_url, HEIMDALL_RPC_PORT_NUMBER
                ),
            ],
        ),
    )
