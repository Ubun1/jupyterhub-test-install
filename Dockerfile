FROM jupyterhub/jupyterhub:latest

RUN pip install jupyter_client dockerspawner jupyterhub-dummyauthenticator
ADD jupyterhub_config.py /srv/jupyterhub/jupyterhub_config.py

CMD ["jupyterhub"]