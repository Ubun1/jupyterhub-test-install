FROM continuumio/miniconda3
LABEL mainteiner="nikita@kretov.site"

RUN apt isntall nodejs-legacy npm

RUN npm install -g configurable-http-proxy

RUN /opt/conda/pip3 install jupyterhub \
                IPython \
                jupyter_client \
                dockerspawner \
                netifaces

ADD jupyterhub_config.py jupyterhub_config.py
EXPOSE 8000
ENTRYPOINT [ "jupyterhub" ]
