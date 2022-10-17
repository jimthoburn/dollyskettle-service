# https://hub.docker.com/_/debian

# https://github.com/docker-library/php/blob/master/8.1/bullseye/apache/Dockerfile
FROM debian:bullseye-slim

RUN apt-get update && apt-get install -y curl
RUN apt-get update && apt-get install -y openssh-client

WORKDIR /root

COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# Set Bash to be the root login shell
RUN usermod -s /bin/bash root

# Ensure /root is owned by root
RUN chown root:root /root

CMD /bin/bash -c 'bash /usr/local/bin/start.sh'
