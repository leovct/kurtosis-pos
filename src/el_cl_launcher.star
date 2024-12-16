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
