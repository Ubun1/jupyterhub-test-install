# Configuration file for Jupyter Hub

c = get_config()

# spawn with Docker
c.JupyterHub.spawner_class = 'dockerspawner.DockerSpawner'
c.JupyterHub.authenticator_class = 'dummyauthenticator.DummyAuthenticator'
# The docker instances need access to the Hub, so the default loopback port doesn't work:
from jupyter_client.localinterfaces import public_ips
c.JupyterHub.hub_ip = public_ips()[0]