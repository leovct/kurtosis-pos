# Port numbers.
AMQP_PORT_NUMBER = 5672
HEIMDALL_LISTEN_PORT_NUMBER = 26658

# Port identifiers.
AMQP_PORT_ID = "amqp"
HEIMDALL_LISTEN_PORT_ID = ""


def launch(plan, participant, private_key):
    rabbitmq_service = plan.add_service(
        name="rabbitmq-{}".format(participant["name"]),
        config=ServiceConfig(
            image=participant["cl_db_image"],
            ports={
                AMQP_PORT_NUMBER: PortSpec(
                    number=AMQP_PORT_ID,
                    application_protocol="amqp",
                )
            },
        ),
    )
    rabbitmq_amqp_port = rabbitmq_service.ports[AMQP_PORT_ID]
    amqp_url = "http://{}:{}".format(
        rabbitmq_service.ip_address, rabbitmq_amqp_port.number
    )

    # TODO: Add the private key under /var/lib/heimdall/hexprivatekey.txt

    plan.add_service(
        name=participant["name"],
        config=ServiceConfig(
            image=participant["image"],
            ports=[],
            files={},
            entrypoint=["sh", "-c"],
            cmd=[
                "heimdalld",
                "start",
                "--amqp_url",
                amqp_url,
                "--all",
                "--rest-server",
                "--bridge",
            ],
        ),
    )
