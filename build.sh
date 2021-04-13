#!/bin/bash

PLATFORM=rpi_spi0
CFG_SPI=native
FTDI_PID=6010

echo "Build based on $PLATFORM"

# Support for FTDI
git clone https://github.com/devttys0/libmpsse
pushd libmpsse/src
./configure --disable-python
make
make install
ldconfig
popd

# Build LoRa gateway app
git clone -b legacy https://github.com/TheThingsNetwork/lora_gateway.git
pushd lora_gateway
mv ../platforms/* ./libloragw/inc/
sed -i -e "s/PLATFORM= kerlink/PLATFORM= ${PLATFORM}/g" ./libloragw/library.cfg
sed -i -e "s/CFG_SPI= native/CFG_SPI= ${CFG_SPI}/g" ./libloragw/library.cfg
sed -i -e "s/ATTRS{idProduct}==\"6010\"/ATTRS{idProduct}==\"${FTDI_PID}\"/g" ./libloragw/99-libftdi.rules
make
popd

# Build packet forwarder
git clone -b legacy https://github.com/TheThingsNetwork/packet_forwarder.git
pushd packet_forwarder
sed -i -e "s/LIBS := /LIBS := -lm /g" ./basic_pkt_fwd/Makefile
sed -i -e "s/LIBS := /LIBS := -lm /g" ./beacon_pkt_fwd/Makefile
sed -i -e "s/LIBS := /LIBS := -lm /g" ./gps_pkt_fwd/Makefile
sed -i -e "s/LIBS := /LIBS := -lm /g" ./poly_pkt_fwd/Makefile
make
popd
