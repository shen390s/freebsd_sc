################################################################
#
# Configuration sample for Traefik v2.
#
# For Traefik v1: https://github.com/traefik/traefik/blob/v1.7/traefik.sample.toml
#
################################################################

################################################################
# Global configuration
################################################################
[global]
  checkNewVersion = true
  sendAnonymousUsage = true

################################################################
# Entrypoints configuration
################################################################

# Entrypoints definition
#
# Optional
# Default:
[entryPoints]
  [entryPoints.traefik]
    address = ":9002"

  [entryPoints.websecure]
    address = ":9443"

  [entryPoints.http]
    address = ":8080"

  %%ENTRY_POINTS%%
################################################################
# Traefik logs configuration
################################################################

# Traefik logs
# Enabled by default and log to stdout
#
# Optional
#
[log]

  # Log level
  #
  # Optional
  # Default: "ERROR"
  #
  level = "DEBUG"

  # Sets the filepath for the traefik log. If not specified, stdout will be used.
  # Intermediate directories are created if necessary.
  #
  # Optional
  # Default: os.Stdout
  #
  filePath = "/var/log/traefik.log"

  # Format is either "json" or "common".
  #
  # Optional
  # Default: "common"
  #
  # format = "json"

################################################################
# Access logs configuration
################################################################

# Enable access logs
# By default it will write to stdout and produce logs in the textual
# Common Log Format (CLF), extended with additional fields.
#
# Optional
#
[accessLog]

  # Sets the file path for the access log. If not specified, stdout will be used.
  # Intermediate directories are created if necessary.
  #
  # Optional
  # Default: os.Stdout
  #
  # filePath = "/path/to/log/log.txt"
  filePath = "/var/log/traefik-access.log"

  # Format is either "json" or "common".
  #
  # Optional
  # Default: "common"
  #
  # format = "json"

################################################################
# API and dashboard configuration
################################################################

# Enable API and dashboard
[api]

  # Enable the API in insecure mode
  #
  # Optional
  # Default: false
  #
  insecure = true

  # Enabled Dashboard
  #
  # Optional
  # Default: true
  #
  # dashboard = false

################################################################
# Ping configuration
################################################################

# Enable ping
[ping]

  # Name of the related entry point
  #
  # Optional
  # Default: "traefik"
  #
  # entryPoint = "traefik"

################################################################
# Docker configuration backend
################################################################

[providers]
  [providers.consulCatalog]
    exposedByDefault = true
    defaultRule = "Host(\`{{ .Name }}.%%DATACENTER%%.%%DOMAIN%%\`)"
    stale = false
    [providers.consulCatalog.endpoint]
    address = "http://%%MY_IP%%:8500"
