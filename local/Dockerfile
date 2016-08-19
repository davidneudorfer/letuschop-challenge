# This allows us to not clutter up our local computer
# and ensure everyone has access to the development tools
# requires mounting the local folder to /etc/letuschop
# docker run -v $(pwd):/etc/letuschop letuschop
# to rebuild:
# docker build -t letuschop .

FROM ubuntu:16.04

ENV packer_version 0.10.1
ENV terraform_version 0.7.0
ENV PATH $PATH:/usr/local/bin

RUN apt-get update && \
    apt-get install --no-install-recommends -y \
      wget \
      git \
      unzip \
      openssl \
      libidn11 \
      libssl1.0.0 \
      ca-certificates \
      && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/packer.zip \
  https://releases.hashicorp.com/packer/${packer_version}/packer_${packer_version}_linux_amd64.zip && \
  unzip /tmp/packer.zip -d /usr/local/bin/

RUN wget -O /tmp/terraform.zip \
  https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip && \
  unzip /tmp/terraform.zip -d /usr/local/bin/

RUN mkdir /etc/letuschop

WORKDIR /etc/letuschop/local

ENTRYPOINT ["./build.sh"]
