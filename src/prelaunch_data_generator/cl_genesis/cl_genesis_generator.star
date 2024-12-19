constants = import_module("../../package_io/constants.star")


CL_GENESIS_TEMPLATE_FILE_PATH = "../../../static_files/genesis/cl/genesis.json"


def generate_cl_genesis_data(plan, polygon_pos_args, validator_accounts):
    l2_network_params = polygon_pos_args["network_params"]
    validators_number = len(validator_accounts)

    validator_data = _get_validator_data(validator_accounts)
    accounts = validator_data.accounts
    dividends = validator_data.dividends
    signing_infos = validator_data.signing_infos
    validator_set = validator_data.validator_set
    proposer = []
    if validators_number > 0:
        proposer = validator_set[0]

    return plan.render_templates(
        config={
            "genesis.json": struct(
                template=read_file(CL_GENESIS_TEMPLATE_FILE_PATH),
                data={
                    # chain params
                    "heimdall_id": l2_network_params["heimdall_id"],
                    "bor_id": l2_network_params["bor_id"],
                    "bor_sprint_duration": l2_network_params["bor_sprint_duration"],
                    "bor_span_duration": l2_network_params["bor_span_duration"],
                    # # validator set, proposer, etc.
                    "accounts": json.indent(json.encode(accounts)),
                    "dividend_accounts": json.indent(json.encode(dividends)),
                    "signing_infos": json.indent(json.encode(signing_infos)),
                    "validators": json.indent(json.encode(validator_set)),
                    "proposer": json.indent(json.encode(proposer)),
                    # contract addresses
                    "matic_token_address": "0x0000000000000000000000000000000000000000",
                    "staking_manager_address": "0x0000000000000000000000000000000000000000",
                    "slash_manager_address": "0x0000000000000000000000000000000000000000",
                    "root_chain_address": "0x0000000000000000000000000000000000000000",
                    "staking_info_address": "0x0000000000000000000000000000000000000000",
                    "state_sender_address": "0x0000000000000000000000000000000000000000",
                },
            )
        },
        name="l2-cl-genesis",
    )


def _get_validator_data(validator_accounts):
    accounts = []
    dividends = []
    signing_infos = {}
    validator_set = []

    for i, account in enumerate(validator_accounts):
        validator_id = str(i + 1)

        # Accounts.
        accounts.append(
            {
                "address": account.address,
                "coins": [
                    {
                        "denom": "matic",
                        "amount": "{}000000000000000000".format(
                            constants.VALIDATORS_BALANCE_ETH
                        ),  # 18 zeros
                    }
                ],
                "sequence_number": "0",
                "account_number": "0",
                "module_name": "",
                "module_permissions": None,
            }
        )

        # Dividends.
        dividends.append(
            {
                "user": account.address,
                "feeAmount": "0",
            }
        )

        # Signing infos.
        signing_infos[validator_id] = {
            "valId": validator_id,
            "startHeight": "0",
            "indexOffset": "0",
        }

        # Validator set.
        validator_set.append(
            {
                "ID": validator_id,
                "accum": "0",
                "endEpoch": "0",
                "jailed": False,
                "last_updated": "",
                "nonce": "1",
                "power": str(constants.VALIDATORS_BALANCE_ETH),
                "pubKey": account.full_public_key,
                "signer": account.address,
                "startEpoch": "0",
            }
        )

    return struct(
        accounts=accounts,
        dividends=dividends,
        signing_infos=signing_infos,
        validator_set=validator_set,
    )
