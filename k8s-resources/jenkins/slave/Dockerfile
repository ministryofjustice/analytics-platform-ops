FROM jenkinsci/jnlp-slave:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        gettext \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.5.1/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    &&  chmod +x /usr/local/bin/kubectl

USER jenkins
