APP_NAME = Gitea: Git with a cup of tea
RUN_USER = git
RUN_MODE = prod

[database]
DB_TYPE  = sqlite3
HOST     = 127.0.0.1:3306
NAME     = gitea
PASSWD   =
PATH     = %%DATA_DIR%%/gitea/gitea.db
SSL_MODE = disable
# USER     = root

[indexer]
ISSUE_INDEXER_PATH = %%DATA_DIR%%/gitea/indexers/issues.bleve

[log]
ROOT_PATH = /var/log/gitea
MODE      = file
LEVEL     = Info

[mailer]
ENABLED = false

[oauth2]
JWT_SECRET = D56bmu6xCtEKs9vKKgMKnsa4X9FDwo64HVyaS4fQ4mY

[picture]
AVATAR_UPLOAD_PATH      = %%DATA_DIR%%/gitea/data/avatars
DISABLE_GRAVATAR        = false
ENABLE_FEDERATED_AVATAR = false

[repository]
ROOT = %%DATA_DIR%%/gitea/gitea-repositories
# Gitea's default is 'bash', so if you have bash installed, you can comment
# this out.
SCRIPT_TYPE = sh

[repository.upload]
TEMP_PATH = %%DATA_DIR%%/gitea/data/tmp/uploads

[security]
INSTALL_LOCK = true
INTERNAL_TOKEN = 1FFhAklka01JhgJTRUrFujWYiv4ijqcTIfXJ9o4n1fWxz+XVQdXhrqDTlsnD7fvz7gugdhgkx0FY2Lx6IBdPQw==
SECRET_KEY   = ChangeMeBeforeRunning

[session]
PROVIDER = file
PROVIDER_CONFIG = %%DATA_DIR%%/gitea/data/sessions

[server]
DOMAIN       = gitea.%%DATACENTER%%.%%DOMAIN%%
HTTP_ADDR    = %%MY_IP%%
HTTP_PORT    = 3000
ROOT_URL     = http://gitea.%%DATACENTER%%.%%DOMAIN%%:8080/
# ROOT_URL = http://localhost:3000/
DISABLE_SSH  = false
# START_SSH_SERVER = true
SSH_DOMAIN   = gitea.%%DATACENTER%%.%%DOMAIN%%
SSH_PORT     = 3022
OFFLINE_MODE = false
APP_DATA_PATH = %%DATA_DIR%%/gitea/data

[service]
REGISTER_EMAIL_CONFIRM = false
ENABLE_NOTIFY_MAIL     = false
DISABLE_REGISTRATION   = false
ENABLE_CAPTCHA         = true
REQUIRE_SIGNIN_VIEW    = false
