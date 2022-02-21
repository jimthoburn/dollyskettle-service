# https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
# https://hub.docker.com/_/node/
# https://github.com/nodejs/docker-node/blob/50c2806d4af0b991ed853072741a30e5d0cb777a/16/bullseye/Dockerfile

FROM node:16-bullseye

RUN apt-get update && apt-get install -y git
RUN apt-get update && apt-get install -y git-lfs
RUN apt-get update && apt-get install -y alpine-pico
RUN apt-get update && apt-get install -y openssh-client
RUN apt-get update && apt-get install -y lftp

RUN npm install netlify-cli -g

COPY setup.sh /usr/local/bin/
COPY update-content.sh /usr/local/bin/

VOLUME /root

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# https://stackoverflow.com/questions/25775266/how-to-keep-docker-container-running-after-starting-services#answer-42873832
CMD ["sleep", "infinity"]
