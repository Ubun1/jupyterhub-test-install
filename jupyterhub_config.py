from IPython.utils.localinterfaces import public_ips
import netifaces
docker0 = netifaces.ifaddresses('docker0')
docker0_ipv4 = docker0[netifaces.AF_INET][0]

c.JupyterHub.confirm_no_ssl = True
c.JupyterHub.spawner_class = 'dockerspawner.SystemUserSpawner'
c.JupyterHub.hub_ip = docker0_ipv4['addr']
