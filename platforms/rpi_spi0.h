/*
 * rpi_spi0.h
 *
 *  Created on: Apr 12, 2021
 *      Author: Xose Pérez
 */

#ifndef _RPI_SPI0_H_
#define _RPI_SPI0_H_

/* Human readable platform definition */
#define DISPLAY_PLATFORM "Raspberry Pi SPI0"

/* parameters for native spi */
#define SPI_SPEED		8000000
#define SPI_DEV_PATH	"/dev/spidev0.0"
#define SPI_CS_CHANGE   0

#endif /* _RPI_SPI0_H_ */
