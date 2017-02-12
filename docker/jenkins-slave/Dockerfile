FROM jenkinsci/jnlp-slave:latest

USER root

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.5.2/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        g++ \
        libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/

RUN wget https://github.com/AGWA/git-crypt/archive/debian/0.5.0-2.tar.gz \
    && tar xzf 0.5.0-2.tar.gz \
    && cd git-crypt-debian-0.5.0-2 \
    && make \
    && make install PREFIX=/usr/local

USER jenkins
