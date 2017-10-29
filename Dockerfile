FROM jupyterhub/jupyterhub:latest

RUN pip install swarmspawner
ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

CMD ["jupyterhub"]