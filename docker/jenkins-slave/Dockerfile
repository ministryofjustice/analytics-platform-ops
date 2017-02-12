FROM jenkinsci/jnlp-slave:latest

USER root

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.5.1/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    &&  chmod +x /usr/local/bin/kubectl

USER jenkins
