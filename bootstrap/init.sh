#!/bin/bash

export PATH=${PWD}/../bin:$PATH

# clean up
if [ -d "organizations/peerOrganizations" ]; then
  rm -Rf organizations/peerOrganizations && rm -Rf organizations/ordererOrganizations
fi

# stop running ca containers
docker stop $(docker ps -aq) &> /dev/null
docker rm $(docker ps -aq) &> /dev/null
docker rmi $(docker images -q) &> /dev/null

docker ps

#exit 1

# launch ca{s}
docker-compose -f docker/docker-compose-ca.yaml up -d

. organizations/scada-ca/createIdentity.sh

# wait for the ca
while :
  do
    if [ ! -f "organizations/scada-ca/ordererOrg/tls-cert.pem" ]; then
      sleep 1
    else
      break
    fi
  done

# create org1 identities
createOrg1Identity

# create orderer identities
createOrdererIdentity

# create bootstrap channels/genesis-block
organizations/scada-ca/createChannel.sh

# launch bootstrap network
docker-compose -f docker/docker-compose-bootstrap.yaml up -d

docker ps

