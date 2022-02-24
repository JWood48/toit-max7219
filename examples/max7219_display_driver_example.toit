/* 
  Copyright 2022
  @Author Jakob Skov

  You may not use this file except in compliance with the License.
  Unless required by applicable law or agreed to in writing, software distributed under the License 
  is distrubuted on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*/

import gpio
import spi
import max7219 show *

import font show Font
import font_clock.three_by_five
import pixel_display show *
import pixel_display.texture show *
import pixel_display.two_color show *

/*
MAX7219 Pins:
VCC -> 3v3
GND -> GND
DIN -> 13 (MOSI)
CS -> 15
CLK -> 14 (CLOCK)
*/

main:
  bus ::= spi.Bus
      //--miso=gpio.Pin 12 // not neede for MAX7219
      --mosi=gpio.Pin 13   // MAX7219 - DIN
      --clock=gpio.Pin 14  // MAX7219 - CLK

  device ::= bus.device
      --cs=gpio.Pin 15     // MAX7219 - CS
      --frequency=10_000_000


  max7219 := Max7219
      device // The device the MAX7219 is attached to.
      3 // Number of chained panels.
      --reverse   // Reverse panel ordering.
      --rotate=1  // Rotate all displays by 1 * 90 degrees.


  // Add the max7219 as a driver for a TwoColorPixelDisplay
  display := TwoColorPixelDisplay max7219

  // Start device.
  max7219.on

  display.background = WHITE

  font := Font [three_by_five.ASCII,
                three_by_five.LATIN_1_SUPPLEMENT]

  context := display.context 
              //--inverted 
              --landscape
              --font=font
              --color=BLACK

  y := 6
  time := display.text context -1 7 "!\"#\$%&/~ .,:;-+° @ [] () {} Error 0123456789 abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ .,:;-+°"

  x := 16
  while true:
    time.move_to x 7
    x--
    display.draw
    sleep --ms=200
