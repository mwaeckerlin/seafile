FROM mwaeckerlin/ubuntu-base
MAINTAINER mwaeckerlin

# Name of this Seafile server
# 3-15 characters, only English letters, digits and underscore ('_') are allowed
ENV NAME=Seafile

# The IP address or domain name used by this server
# Seafile client program will access the server with this address
ENV IP=127.0.0.1

# ui
EXPOSE 8082
# fileserver
EXPOSE 8000

ENV TARGET=/seafile
ENV DATA=${TARGET}/data
ENV DOWNLOAD=${TARGET}/download
ENV SERVER=${TARGET}/server

WORKDIR ${TARGET}

RUN apt-get update && apt-get install -y xml2 python2.7 libpython2.7 python-setuptools python-imaging python-ldap python-urllib3 sqlite3 ffmpeg python-pip
RUN pip install pillow moviepy

RUN mkdir -p ${TARGET} ${DATA} ${DOWNLOAD} ${SERVER}
RUN FILE=$(wget -qO- https://download.seadrive.org/ | xml2 | sed -n 's,.*=,,; /x86-64.tar.gz/p' | sort -h | tail -1); \
    VERSION=${FILE#*_}; VERSION=${VERSION%_*}; \
    echo $VERSION > /VERSION; \
    wget -qO${DOWNLOAD}/${FILE} https://download.seadrive.org/${FILE}; \
    tar xf ${DOWNLOAD}/${FILE}; \
    mv ${FILE%.t*} seafile-server

WORKDIR ${SERVER}/seafile-server
ADD start.sh /start.sh
CMD /start.sh

VOLUME ${DATA}
