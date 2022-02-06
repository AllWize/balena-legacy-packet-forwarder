**THIS PROJECT IS NO LONGER MAINTAINED. Use this one instead: https://github.com/RAKWireless/udp-packet-forwarder**

# LoRaWAN™ Legacy UDP PolyPacket Forwarder using balena.io with sx1301 LoRa concentrators

This project deploys a LoRaWAN gateway using the legacy UDP Packet Forwarder protocol with balena. It runs on a Raspberry Pi (3/4) or balenaFin with a SX1301-based concentrator.


## Introduction

Deploy a The Things Network (TTN), The Things Industries (TTI) or The Things Stack (TTS) LoRaWAN gateway running the legacy UDP Packet Forwarder protocol by Semtech.

The UDP Packet Forwarder protocol is NOT the recommended protocol nowadays due to its low reliability and security, still some LNS only support this protocol at the moment. If your LNS support LoRa Basics™ Station please refer to this other project: [LoRa Basics™ Station using balena.io with sx1301 and sx1302 LoRa concentrators](https://github.com/balenalabs/basicstation).

## Getting started

### Hardware

* Raspberry Pi 3/4
* SD card
* LoRa Concentrators (only SX1301-based):
  * [IMST iC880a](https://shop.imst.de/wireless-modules/lora-products/8/ic880a-spi-lorawan-concentrator-868-mhz)
  * [RAK 2245 pi hat](https://store.rakwireless.com/products/rak2245-pi-hat)
  * [RAK 2247 concentrator](https://store.rakwireless.com/products/rak2247-lpwan-gateway-concentrator-module) with a [RAK2247 pi hat](https://store.rakwireless.com/products/rak2247-pi-hat) or equivalent
* Antenna, power suppply,...


### Software

* A TTN or The Things Stack V3 account ([sign up here](https://console.thethingsnetwork.org)) or [here](https://ttc.eu1.cloud.thethings.industries/console/)
* A balenaCloud account ([sign up here](https://dashboard.balena-cloud.com/))
* [balenaEtcher](https://balena.io/etcher)

Once all of this is ready, you are able to deploy this repository following instructions below.


## Deploy the code

### Via [Balena Deploy](https://www.balena.io/docs/learn/deploy/deploy-with-balena-button/)

Running this project is as simple as deploying it to a balenaCloud application. You can do it in just one click by using the button below:

[![](https://www.balena.io/deploy.png)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/AllWize/balena-legacy-packet-forwarder)

Follow instructions, click Add a Device and flash an SD card with that OS image dowloaded from balenaCloud. Enjoy the magic 🌟Over-The-Air🌟!


### Via [Balena-Cli](https://www.balena.io/docs/reference/balena-cli/)

If you are a balena CLI expert, feel free to use balena CLI.

- Sign up on [balena.io](https://dashboard.balena.io/signup)
- Create a new application on balenaCloud.
- Clone this repository to your local workspace.
- Using [Balena CLI](https://www.balena.io/docs/reference/cli/), push the code with `balena push <application-name>`
- See the magic happening, your device is getting updated 🌟Over-The-Air🌟!


## Configure the Gateway

### Service variables

Once successfully registered:

1. Go to balenaCloud dashboard and get into your LoRa gateway device site.
2. Click "Device Variables" button on the left menu and add these variables.

Alternativelly, you can also set any of them at application level if you want it to apply to all devices in you application.

Variable Name | Value | Description | Default
------------ | ------------- | ------------- | -------------
**`GATEWAY_RESET_GPIO`** | `INT` | GPIO number that resets (Broadcom pin number) | 25
**`SERVERS`** | `STRING` | Servers to send UDP frames to (see section below) | ```router.eu.thethings.network:1700```
**`GATEWAY_EMAIL`** | `STRING` | Gateway manager email | ```yourname@yourdomain.com```
**`GATEWAY_NAME`** | `STRING` | Gateway identificator | ```my-gateway```
**`GATEWAY_GPS`** | `BOOL` | ```true``` if the gateway has a hardware GPS available | ```false```
**`GATEWAY_LAT`** | `FLOAT` | If no GPS, static latitude of the gateway location  | ```0```
**`GATEWAY_LON`** | `FLOAT` | If no GPS, static longitude of the gateway location  | ```0```
**`GATEWAY_ALT`** | `FLOAT` | If no GPS, static altitude of the gateway location  | ```0```


### About the SERVERS variables

This project uses the poly-packet-forwarder tool that allows you to send the UDP frames to several servers using the UDP Packet Forwarder protocol by Semtech. These servers can be easily configured at runtime using the `SERVERS` variable under the "Environment variables" at application level or under the "Device Variables" section at device level.

The `SERVERS` variable may contain several servers, comma separated, each one including the host and the port, like this:

```
server1:port1,server2:port2,server3:port3
```

Default value is ```router.eu.thethings.network:1700``` which is the TTNv2 server endpoint in Europe. If you want to also redirect messages to you own LNS server you can set this to: ```router.eu.thethings.network:1700,192.168.1.110:1700``` where ```192.168.1.110```is the machine IP (in the same network as the gateway) where you have a local LNS like ChirpStack, for instance.


### Configure your The Things Network gateway

1. Sign up at [The Things Network console](https://console.thethingsnetwork.org/).
2. Click Gateways button.
3. Click the "Register gateway" link.
4. Check “I’m using the legacy packet forwarder” checkbox.
5. Paste the EUI from the balenaCloud tag or the Ethernet mac address of the board (calculated above)
6. Complete the form and click Register gateway.


### Configure your The Things Stack gateway

1. Sign up at [The Things Stack console](https://ttc.eu1.cloud.thethings.industries/console/).
2. Click "Go to Gateways" icon.
3. Click the "Add gateway" button.
4. Introduce the data for the gateway.
5. Paste the EUI from the balenaCloud tags.
6. Complete the form and click Register gateway.



## TTNv2 to TTS migration

Initial state: one of more devices connected to TTNv2 stack (The Things Network).

Proposed procedure:

1. Create the gateways at TTS using the very same Gateway ID (Gateway EUI)
2. Set the `SERVERS` variable to ```eu1.cloud.thethings.network:1700```
3. The service will reboot and the gateway will start reporting to TTSv3

Note there is no need to point the gateway to both TTNv2 and TTSv3 since there is a forwarder from v2 to v3. TTN recommends to migrate the gateways the last thing (by the end of 2021) and keep them pointing to v2 in the meantime.

## Attribution

- This is an adaptation of the [ch2i's ic880a gateway repository](https://github.com/ch2i/ic880a-gateway).
- This project uses legacy code at the The Things Network's [lora_gateway](https://github.com/TheThingsNetwork/lora_gateway) and [packet_forwarder](https://github.com/TheThingsNetwork/packet_forwarder) repositories.

## License

Copyright 2021 by Xose Pérez <xose at allwize dot io>

This project is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This project is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with the project. If not, see http://www.gnu.org/licenses/.
