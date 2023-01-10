service {
    tags = ["pot-jail",
            "metrics",
	    "%%SERVICE_NAME%%",
	    "traefik.enable=true",
	    "traefik.%%SERVICE_TYPE%%.routers.%%SERVICE_NAME%%.entrypoints=%%SERVICE_NAME%%",
	    "traefik.%%SERVICE_TYPE%%.routers.%%SERVICE_NAME%%.rule=%%SERVICE_RULE%%"
	    ]

    name = "%%SERVICE_NAME%%"
    port = "%%SERVICE_NAME%%"

    check {
         type = "%%SERVICE_CHECK_TYPE%%"
	 name = "%%SERVICE_NAME%%"
	 interval = "%%SERVICE_CHECK_INTERVAL%%"
	 timeout = "%%SERVICE_CHECK_TIMEOUT%%"
    }
}