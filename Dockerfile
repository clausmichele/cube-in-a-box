FROM andrejreznik/python-gdal:py3.10.0-gdal3.2.3

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      wget
      # For Psycopg2
      # libpq-dev python3-dev \
      # python3-pip \
     
    
COPY requirements.txt /conf/
COPY products.csv /conf/
RUN pip3 install --no-cache-dir --requirement /conf/requirements.txt
RUN pip3 install odc-apps-dc-tools==0.2.1
RUN pip3 install --extra-index-url="https://packages.dea.ga.gov.au" \
  odc-ui \
  odc-stac \
  odc-stats \
  odc-algo \
  odc-io \
  odc-cloud[ASYNC] \
  odc-dscache \
  odc-index
RUN pip3 install gunicorn
WORKDIR /notebooks

ENTRYPOINT ["/tini", "--"]

CMD ["jupyter", "notebook", "--allow-root", "--ip='0.0.0.0'", "--NotebookApp.token='ciabpassword'"]

CMD ["cubedash-gen", "--init", "--all"]

CMD ["gunicorn","-b 0.0.0.0:9000","-w 1","cubedash:app"]