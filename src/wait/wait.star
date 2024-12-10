def wait_for_startup(plan, l1_config_env_vars):
    plan.run_sh(
        name="wait-for-l1-startup",
        description="Wait for L1 to start up - it can take up to 2 minutes",
        image="mslipper/deployment-utils:latest",
        env_vars=l1_config_env_vars,
        run="while true; do sleep 5; echo 'L1 Chain is starting up'; if [ \"$(curl -s $CL_RPC_URL/eth/v1/beacon/headers/ | jq -r '.data[0].header.message.slot')\" != \"0\" ]; then echo 'L1 Chain has started!'; break; fi; done",
        wait="300s",
    )
