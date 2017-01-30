FROM rocker/r-ver:3.3.2

ARG PANDOC_TEMPLATES_VERSION
ENV PANDOC_TEMPLATES_VERSION ${PANDOC_TEMPLATES_VERSION:-1.18}

## Add RStudio binaries to PATH
ENV PATH /usr/lib/rstudio-server/bin:$PATH

ENV USERS_PATH /etc/rstudio/users.txt

## Download and install RStudio server & dependencies
## Attempts to get detect latest version, otherwise falls back to version given in $VER
## Symlink pandoc, pandoc-citeproc so they are available system-wide
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    file \
    git \
    libapparmor1 \
    libcurl4-openssl-dev \
    libedit2 \
    libssl-dev \
    lsb-release \
    psmisc \
    python-setuptools \
    sudo \
    wget \
    rrdtool \
  && wget -q https://download2.rstudio.org/rstudio-server-pro-1.0.136-amd64.deb \
  && dpkg -i rstudio-server-pro-1.0.136-amd64.deb \
  && rm rstudio-server-pro-*-amd64.deb \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc /usr/local/bin \
  && ln -s /usr/lib/rstudio-server/bin/pandoc/pandoc-citeproc /usr/local/bin \
  && wget https://github.com/jgm/pandoc-templates/archive/${PANDOC_TEMPLATES_VERSION}.tar.gz \
  && mkdir -p /opt/pandoc/templates && tar zxf ${PANDOC_TEMPLATES_VERSION}.tar.gz \
  && cp -r pandoc-templates*/* /opt/pandoc/templates && rm -rf pandoc-templates* \
  && mkdir /root/.pandoc && ln -s /opt/pandoc/templates /root/.pandoc/templates \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  && mkdir -p /etc/R \
  && echo '\n\
    \n# Configure httr to perform out-of-band authentication if HTTR_LOCALHOST \
    \n# is not set since a redirect to localhost may not work depending upon \
    \n# where this Docker container is running. \
    \nif(is.na(Sys.getenv("HTTR_LOCALHOST", unset=NA))) { \
    \n  options(httr_oob_default = TRUE) \
    \n}' >> /usr/local/lib/R/etc/Rprofile.site \
  && echo "PATH=\"${PATH}\"" >> /usr/local/lib/R/etc/Renviron \
  && useradd rstudio \
  && echo "rstudio:rstudio" | chpasswd \
    && mkdir /home/rstudio \
    && chown rstudio:rstudio /home/rstudio \
    && addgroup rstudio staff \
  && git config --system credential.helper 'cache --timeout=3600' \
  && git config --system push.default simple
  # && wget -P /tmp/ https://github.com/just-containers/s6-overlay/releases/download/v1.11.0.1/s6-overlay-amd64.tar.gz \
  # && tar xzf /tmp/s6-overlay-amd64.tar.gz -C / \
  # && mkdir -p /etc/services.d/rstudio \
  # && echo '#!/bin/bash \
  #          \n exec /usr/lib/rstudio-server/bin/rserver --server-daemonize 0' \
  #          > /etc/services.d/rstudio/run \
  #  && echo '#!/bin/bash \
  #          \n rstudio-server stop' \
  #          > /etc/services.d/rstudio/finish

RUN echo "server-access-log=1" >> /etc/rstudio/rserver.conf
RUN echo "auth-proxy=1" >> /etc/rstudio/rserver.conf
RUN echo "auth-proxy-sign-in-url=https://r-studio-example.apps.analytics.kops.integration.dsd.io/login" >> /etc/rstudio/rserver.conf
# RUN echo "foo=bar" >> /etc/rstudio/rserver.conf

COPY userconf.sh /etc/cont-init.d/conf

# COPY createusers.sh /usr/local/bin/
COPY start.sh /usr/local/bin/
# RUN chmod +x /usr/local/bin/createusers.sh
RUN chmod +x /usr/local/bin/start.sh
# COPY users.txt .
# RUN chmod +x createusers.sh && ./createusers.sh

EXPOSE 8787

#CMD ["/usr/lib/rstudio-server/bin/rserver", "--server-daemonize", "0"]
CMD ["/usr/local/bin/start.sh", "${USERS_PATH}"]
