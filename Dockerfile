# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter SciPy-PyODBC Project <fracking.analysis@gmail.com>"

USER root

# gnupg needed for curl, zip for nbzip
RUN apt-get update && \
    apt-get install -y apt-utils gnupg curl zip unixodbc-dev && \
    rm -rf /var/lib/apt/lists/*

# install Microsoft ODBC for SQL Server 17
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17

USER $NB_UID

# Install Python 3 packages psycopg2 and pyodbc
RUN conda install --quiet --yes \
    'psycopg2' \
    'pyodbc' \
    && \
    conda clean --all -f -y && \
    # Activate ipywidgets extension in the environment that runs the notebook server
    jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    pip install --upgrade jupyterlab-git && \
    jupyter labextension install @jupyterlab/github && \
    jupyter lab build -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    rm -rf /home/$NB_USER/.node-gyp && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

USER $NB_UID
