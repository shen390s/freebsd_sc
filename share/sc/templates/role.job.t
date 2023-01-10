job "%%JOB%%" {
    region = "global"
    datacenters = ["%%DATACENTER%%"]
    type = "service"

    group "%%JOBGROUP%%" {
        count = %%JOB_REPLICAS%%

        network {
	   %%PORTS_ASSIGN%%
	}

	task "%%JOB_TASK%%" {
	    driver = "pot"

%%JOB_SERVICES%%

   	    config {
	        image = "%%IMAGE_LOCATION%%"
	        pot = "%%POT_NAME%%"
	        tag = "%%POT_TAG%%"
	        command = "%%POT_START_CMD%%"
	        args = [%%POT_START_ARGS%%]
%%POT_PORT_MAPS%%
  	        network_mode = "%%POT_NETWORK_MODE%%"
	        mount = [ %%POT_MOUNTS%% ]
	    }

	    resources {
	        cpu = %%POT_CPU_HZ%%
	        memory = %%POT_MEMORY_REQ%%
	    }
	}
    }
}
