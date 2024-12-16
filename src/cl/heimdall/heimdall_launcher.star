# Port numbers.
AMQP_PORT_NUMBER = 5672
HEIMDALL_REST_API_PORT_NUMBER = 1317
HEIMDALL_DISCOVERY_PORT_NUMBER = 26657

# Port identifiers.
AMQP_PORT_ID = "amqp"
HEIMDALL_REST_API_PORT_ID = "http"
HEIMDALL_DISCOVERY_PORT_ID = "tcp-discovery"


def launch(plan, name, participant, private_key):
    rabbitmq_service = plan.add_service(
        name="rabbitmq-{}".format(name),
        config=ServiceConfig(
            image=participant["cl_db_image"],
            ports={
                AMQP_PORT_ID: PortSpec(
                    number=AMQP_PORT_NUMBER,
                    application_protocol="amqp",
                )
            },
        ),
    )
    rabbitmq_amqp_port = rabbitmq_service.ports[AMQP_PORT_ID]
    rabbitmq_url = "amqp://{}:{}".format(
        rabbitmq_service.ip_address, rabbitmq_amqp_port.number
    )

    # TODO: Add the private key under /var/lib/heimdall/hexprivatekey.txt

    plan.add_service(
        name=name,
        config=ServiceConfig(
            image=participant["cl_image"],
            ports={
                HEIMDALL_REST_API_PORT_ID: PortSpec(
                    number=HEIMDALL_REST_API_PORT_NUMBER,
                    application_protocol="http",
                ),
                HEIMDALL_DISCOVERY_PORT_ID: PortSpec(
                    number=HEIMDALL_DISCOVERY_PORT_NUMBER,
                    application_protocol="",
                ),
            },
            files={},
            entrypoint=["sh", "-c"],
            cmd=[
                "heimdalld start --amqp_url {} --all --rest-server --bridge".format(
                    rabbitmq_url
                ),
            ],
        ),
    )
