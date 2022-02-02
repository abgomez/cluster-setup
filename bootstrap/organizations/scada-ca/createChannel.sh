#!/bin/bash

BIN=${PWD}/../bin
CONFIG=${PWD}/config

export FABRIC_LOGGING_SPEC=INFO
export FABRIC_CFG_PATH=$CONFIG


createChannelGenesisBlock() {
  GENESIS_BLOCK=$CONFIG=/oderer-genesis.block
  ORDERER_CHANNEL_ID=ordererchannel
  echo $FABRIC_CFG_PATH
  $BIN/configtxgen -profile RaftOrdererGenesis -outputBlock $GENESIS_BLOCK -channelID $ORDERER_CHANNEL_ID
}


# create GenesisBlock
createChannelGenesisBlock
