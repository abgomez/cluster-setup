#!/bin/bash

function createOrg1Identity() {
  # Enrolling the CA admin
  mkdir -p organizations/peerOrganizations/org1.scada.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/org1.scada.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-org1 --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-org1.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/config.yaml"

  # Registering peer0
  set -x
  fabric-ca-client register --caname ca-org1 --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  # Registering user
  set -x
  fabric-ca-client register --caname ca-org1 --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  # Registering the org admin
  set -x
  fabric-ca-client register --caname ca-org1 --id.name org1admin --id.secret org1adminpw --id.type admin --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  # Generating the peer0 msp
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/msp" --csr.hosts peer0.org1.scada.com --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/msp/config.yaml"

  # Generating the peer0-tls certificates
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls" --enrollment.profile tls --csr.hosts peer0.org1.scada.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.scada.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/tlsca/tlsca.org1.scada.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/org1.scada.com/ca"
  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/peers/peer0.org1.scada.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/org1.scada.com/ca/ca.org1.scada.com-cert.pem"

  # Generating the user msp
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.scada.com/users/User1@org1.scada.com/msp" --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.scada.com/users/User1@org1.scada.com/msp/config.yaml"

  # Generating the org admin msp
  set -x
  fabric-ca-client enroll -u https://org1admin:org1adminpw@localhost:7054 --caname ca-org1 -M "${PWD}/organizations/peerOrganizations/org1.scada.com/users/Admin@org1.scada.com/msp" --tls.certfiles "${PWD}/organizations/scada-ca/org1/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/org1.scada.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/org1.scada.com/users/Admin@org1.scada.com/msp/config.yaml"
}


function createOrdererIdentity() {
  # Enrolling the CA admin
  mkdir -p organizations/ordererOrganizations/scada.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/scada.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/scada.com/msp/config.yaml"

  # Registering orderer0 - bootstrap orderer
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer0 --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  # Registering the orderer admin
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  # Generating the orderer0 msp
  set -x
  fabric-ca-client enroll -u https://orderer0:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/msp" --csr.hosts orderer0.scada.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/scada.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/msp/config.yaml"

  # Generating the orderer0-tls certificates
  set -x
  fabric-ca-client enroll -u https://orderer0:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls" --enrollment.profile tls --csr.hosts orderer0.scada.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/msp/tlscacerts/tlsca.scada.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/scada.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/scada.com/orderers/orderer0.scada.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/scada.com/msp/tlscacerts/tlsca.scada.com-cert.pem"

  # Generating the admin msp
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/scada.com/users/Admin@scada.com/msp" --tls.certfiles "${PWD}/organizations/scada-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/scada.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/scada.com/users/Admin@scada.com/msp/config.yaml"
}
