# Clockwork Pi uConsole

The [Clockwork Pi uConsole](https://www.clockworkpi.com/home-uconsole) is a handheld Linux computer, made by [Clockwork Pi](https://www.clockworkpi.com/).

## Useful Links

* [Clockwork Pi](https://clockworkpi.com/) - manufacturer of the uConsole
* [HackerGadgets](https://hackergadgets.com) - maker of several popular expansion kits for the uConsole
* [Clockwork Pi forums](https://forum.clockworkpi.com/) - discusson forum for users of the uConsole and other Clockwork Pi hardware
* [uConsole World](https://uconsole.net/) - blog site with articles and tutorials about the uConsole


## Hardware

The uConsole is sold as a kit, which includes ...

* a metal frame, that the parts mount into
* a 5-inch 1280x720 display
* a keyboard with a directional pad and "gaming" buttons (A/B/X/Y/Select/Start)
* a trackball with L/R mouse buttons
* a pair of small internal speakers
* a set of circuit boards to connect the various components together
* metal front and back covers
* an external wifi antenna, meant to be attached to the *outside* of the case

No soldering is required. All parts are secured to the frame using M4 hex-head screws, and the kit comes with a 2.5mm hex driver (aka "allen wrench"), which is the only tool needed to assemble the unit.

The main board has a single USB-A port (USB 2.0), a USB-C port (for power input only), a Micro-HDMI port, and a 3.5mm headphone jack. There is room inside the unit for an expansion board, which may have its own external connectors on the other side of the unit.

The kit can can be ordered with one of several "core" boards containing an ARM- or RISC-based CPU board, or with no "core" (for people who may already have a Raspberry Pi Compute Module 4/5). I ordered mine with a [Raspberry Pi Compute Module 4](https://www.raspberrypi.com/products/compute-module-4/) core.

It can also be ordered with a 4G Cellular/GPS expansion board, with its own antenna meant to be attached to the outside of the case.


### Open Source

The design is all open-source. The [uConsole repo](https://github.com/clockworkpi/uConsole) on Github contains schematics for the circuit boards, source code for the keyboard firmware, and information about how they built the kernel with the correct modules for the uConsole hardware.

Their web site *sorta* says that the design files for the frame and front/back covers should be there as well, but I don't see them in this repo (or in [any of their repos](https://github.com/orgs/clockworkpi/repositories?language=&q=sort%3Aname-asc&sort=name&type=all)) as of 2025-12-31.


## Batteries

**Batteries are NOT included with the kit.** This is due to safety regulations around shipping lithium batteries.

The uConsole is powered by a pair of 18650 rechargable Li-ion batteries, with charging circuitry included on the main board. The battery holder within the unit can hold either flat-top or button-top batteries.

&#x21D2; The [Batteries](batteries.md) page has more details, including notes about which batteries to order and **which ones to avoid**.


## Power Supply

**A power supply is NOT included with the kit.** This is probably because different parts of the world use different power connectors and voltages. It uses a standard 5V USB-C connector.

Most USB-C chargers for mobile phones or tablets should be usable with the uConsole, however you need to be careful when using "high power" adapters designed for laptops.

&#x21D2; The [Power Supply](power-supply.md) page has more details.
