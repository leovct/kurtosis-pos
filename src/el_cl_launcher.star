bor = import_module("./el/bor/bor_launcher.star")
erigon = import_module("./el/erigon/erigon_launcher.star")
heimdall = import_module("./cl/heimdall/heimdall_launcher.star")


def launch(plan, participants):
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

    for index, participant in enumerate(participants):
        plan.print(
            "Launching participant {} with config {}".format(index, str(participant))
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

        cl_node_name = "{}-{}".format(cl_type, index)
        cl_context = cl_launch_method(plan, cl_node_name, participant, "test")
