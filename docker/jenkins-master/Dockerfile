FROM jenkins:2.32.2
RUN /usr/local/bin/install-plugins.sh \
        kubernetes:0.10 \
        workflow-aggregator:2.5 \
        credentials-binding:1.10 \
        git:3.0.5 \
    && mkdir -p /usr/share/jenkins/ref/secrets/ \
    && echo "false" > /usr/share/jenkins/ref/secrets/slave-to-master-security-kill-switch

RUN /usr/local/bin/install-plugins.sh \
        blueocean:1.0.0-b22 \
        envinject:1.93.1 \
        github-organization-folder:1.6 \
        google-login:1.3
