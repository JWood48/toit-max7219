/* 
  Copyright 2022
  @Author Jakob Skov

  You may not use this file except in compliance with the License.
  Unless required by applicable law or agreed to in writing, software distributed under the License 
  is distrubuted on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*/

import math
import serial.protocols.spi as spi
import .font
import .utils
import .icons

import pixel_display.two_color show *
import pixel_display show *

export rotate

RIGHT ::= 0
DOWN ::= 1
LEFT ::= 2
UP ::= 3


/**
Driver for the MAX7219 8x8 matrix display.

https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf
*/
class Max7219 extends AbstractDriver:

  static MAX7219_TEST ::= 0x0f
  static MAX7219_BRIGHTNESS ::= 0x0a
  static MAX7219_SCAN_LIMIT ::= 0x0b
  static MAX7219_DECODE_MODE ::= 0x09
  static MAX7219_SHUTDOWN ::= 0x0C

  panelIndex_/List
  panels_/int
  device_/spi.Device
  spidata_/ByteArray
  rotate_/int
  reverse_/bool

  
  width/int
  height/int ::= 8
  flags/int ::= FLAG_2_COLOR


  /**
  Constructs the driver with the given spi device and $panel_count panels chained.
  The $rotate parameter is used to rotate 8x8 byte matrixes by the given number in
    clockwise direction before displaying them.
  $reverse reverses the panel ordering.
  */
  constructor .device_ panel_count/int --rotate/int=0 --reverse/bool=false:
    panels_ = panel_count
    spidata_ = ByteArray (panels_ * 2)
    rotate_ = rotate
    reverse_ = reverse
    panelIndex_ = List panels_
    panels_.repeat:
      if reverse:
        panelIndex_[panels_ - 1 - it] = it
      else:
        panelIndex_[it] = it
    width = panel_count * 8
    

  /**
  Starts the MAX7219 device.
  */
  on:
    panels_.repeat:
      max_transfer_ it MAX7219_TEST 0X00
      scanlimit it 7
      max_transfer_ it MAX7219_DECODE_MODE 0X00
      shutdown it false
      clear it

  /**
  Stops the MAX7219 device.
  */
  off:
    panels_.repeat:
      clear it
      shutdown it true

  check_addr_ addr/int:
    return addr >= 0 and addr < panels_

  max_transfer_all_ opcode/int data/int :
    panels_.repeat:
      max_transfer_ it opcode data

  max_transfer_ addr/int opcode/int data/int :
    offset := panelIndex_[addr] * 2
    maxbytes := panels_ * 2
    spidata_.fill 0x0
    spidata_[offset]=opcode
    spidata_[offset + 1]=data
    device_.transfer spidata_

  draw_byte_array_ addr/int bytes/ByteArray:
    if not check_addr_ addr:
      return
    if bytes.size != 8:
      throw "There must be 8 bytes!!"
    rotate_.repeat:
      bytes = rotate bytes
    8.repeat:
      max_transfer_ addr it+1 bytes[it]


  /**
  Sends a shutdown signal to all panels.
  */
  shutdown_all b/bool:
    panels_.repeat:
      shutdown it b
  /**
  Sends a shutdown signal to the panel with the given $address.
  */
  shutdown address/int b/bool:
    if check_addr_ address:
      max_transfer_ address MAX7219_SHUTDOWN (b ? 0x0 : 0x1)


  /**
  Sets a scan $limit on all panels.
  The $limit must satisfy 0 <= $limit < 8.
  */
  scanlimit_all limit/int:
    panels_.repeat:
      scanlimit it limit
  /**
  Sets a scan $limit on the panel with the given $address.
  The $limit must satisfy 0 <= $limit < 8.
  */
  scanlimit address/int limit/int:
    if check_addr_ address and 0 <= limit < 8:
      max_transfer_ address MAX7219_SCAN_LIMIT limit

   /**
  Set the $brightness of the panel with the given $address.
  The $brightness value must satisfy 0 <= $brightness <= 15.
  */
  brightness_all brightness_value/int:
    panels_.repeat:
      brightness it brightness_value
  /**
  Set the $brightness of the panel with the given $address.
  The $brightness value must satisfy 0 <= $brightness <= 15.
  */
  brightness address/int brightness/int:
    if check_addr_ address and 0 <= brightness < 16:
      max_transfer_ address MAX7219_BRIGHTNESS brightness


  /**
  Clears the panel with the given $address.
  */
  clear_all:
    panels_.repeat:
      clear it
  /**
  Clears the panel with the given $address.
  */
  clear address/int:
    if check_addr_ address:
      8.repeat:
        max_transfer_ address (it + 1) 0x0

  /**
  Draws the given character $char on the panel with the given $address.
  */
  draw_char address/int char/int:
    if not check_addr_ address:
      return
    if not 0 <= char <= CP437_FONT.size:
      throw "Char must be between 0 and $CP437_FONT.size, was $char"
    v/ByteArray := CP437_FONT[char]
    draw_byte_array_ address v

  /**
  Draws an 8x8 icon on the panel with the given $address.
  The icon can be rotated by setting the $direction to
    $RIGHT, $DOWN, $LEFT, or $UP.
  */
  draw_icon address/int icon/ByteArray --direction/int=RIGHT:
    if not check_addr_ address: return
    if not 0 <= direction <= 3:
      throw "Direction must be RIGHT=0, DOWN=1, LEFT=2, UP=3"
    direction.repeat:
      icon = rotate icon
    draw_byte_array_ address icon

  /**
  Draws an arrow on the panel with the given $address.
  The arrow can be rotated by setting the $direction to
    $RIGHT, $DOWN, $LEFT, or $UP.
  */
  draw_arrow address/int --direction/int=RIGHT :
    draw_icon address ICON_ARROW --direction=direction

  /**
  Tests all configured panels.
  The tests shows all pixels at full brightness.
  */
  test:
    max_transfer_all_ MAX7219_TEST 0X01
    sleep --ms=2000
    max_transfer_all_ MAX7219_TEST 0X00
  
  /**
  Identify current panels by writing the panel index on each panel.
  */
  identify:
    panels_.repeat:
      draw_char it "$it"[0]

  
  draw_two_color left/int top/int right/int bottom/int pixels/ByteArray -> none:
    // debug
    // print "left: $left, top: $top, right: $right, bottom: $bottom, pixels: $pixels"
    // pixels.size.repeat:
    //   b := pixels[it]
    //   s := ""
    //   8.repeat:
    //     s = "$((b >> it) & 0b1)$s"
    //   print "B $(s)"

    // for each panel write pixel segments
    panels_.repeat:
      draw_byte_array_ it pixels[it*8..it*8+8]
        

