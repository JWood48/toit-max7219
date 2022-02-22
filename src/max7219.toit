import math
import serial.protocols.spi as spi
import .font
import .utils
import .icons

RIGHT ::= 0
DOWN ::= 1
LEFT ::= 2
UP ::= 3

/**
Driver for the MAX7219 8x8 matrix display: https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf
*/
class Max7219:

  static MAX7219_TEST ::= 0x0f 
  static MAX7219_BRIGHTNESS ::= 0x0a
  static MAX7219_SCAN_LIMIT ::= 0x0b
  static MAX7219_DECODE_MODE ::= 0x09
  static MAX7219_SHUTDOWN ::= 0x0C

  panelIndex_/List ::= ?
  panels_/int ::= ?
  device_/spi.Device ::= ?
  spidata_/ByteArray ::= ?
  rotate_/int ::=?
  reverse_/bool ::=?

  /**
  Construct the driver with the given spi device and x panels chained.
  --rotate can be used to rotate the 8x8 Byte matrix by x
  --reverse reverses the panel ordering
  */
  constructor .device_ .panels_ --rotate/int=0 --reverse/bool=false:
    spidata_ = ByteArray (panels_ * 2)
    rotate_ = rotate
    reverse_ = reverse
    panelIndex_ = List panels_
    panels_.repeat:
      if reverse:
        panelIndex_[panels_ - 1 - it] = it
      else:
        panelIndex_[it] = it

  /**
    Start the MAX7219 device
  */  
  on:
    panels_.repeat:
      maxTransfer_ it MAX7219_TEST 0X00
      scanlimit it 7
      maxTransfer_ it MAX7219_DECODE_MODE 0X00
      shutdown it false
      clear it

  /**
    Stop the MAX7219 device
  */  
  off:
    panels_.repeat:
      shutdown it true

  checkAddr_ addr/int:
    return addr >= 0 and addr < panels_

  maxTransferAll_ opcode/int data/int :
    panels_.repeat:
      maxTransfer_ it opcode data

  maxTransfer_ addr/int opcode/int data/int :
    offset := panelIndex_[addr] * 2
    maxbytes := panels_ * 2
    spidata_.fill 0x0
    spidata_[offset]=opcode
    spidata_[offset+1]=data
    device_.transfer spidata_

  drawByteArray_ addr/int bytes/ByteArray:
    if not checkAddr_ addr:
       return
    if bytes.size != 8:
      throw "There must be 8 bytes!!"
    rotate_.repeat:
      bytes = rotate bytes
    8.repeat:
      maxTransfer_ addr it+1 bytes[it]

  /**
    Send shutdown signal to panel
  */
  shutdown addr/int b/bool:
    if checkAddr_ addr:  
      maxTransfer_ addr MAX7219_SHUTDOWN (b ? 0x0 : 0x1)

  /**
    Set scan limit on panel
  */
  scanlimit addr/int limit/int:
    if checkAddr_ addr and limit >= 0 and limit < 8:  
      maxTransfer_ addr MAX7219_SCAN_LIMIT limit

  /**
    Set brightness of a panel (0-15)
  */
  brightness addr/int brightness/int:
    if checkAddr_ addr and brightness >= 0 and brightness < 16:  
      maxTransfer_ addr MAX7219_BRIGHTNESS brightness

  /**
    Clear panel
  */
  clear addr/int:
    if checkAddr_ addr:  
      8.repeat:
        maxTransfer_ addr it+1 0x0

  /**
    Draw a character on a panel
  */
  drawChar addr/int char/int:
    if not checkAddr_ addr:
      return
    if char < 0 or char > CP437_FONT.size:
      throw "Char must be between 0 and $CP437_FONT.size, was $char"
    v/ByteArray := CP437_FONT[char]
    drawByteArray_ addr v

  /**
    Draw a 8x8 icon on a panel possibly rotated
  */
  drawIcon addr/int icon/ByteArray --direction/int = RIGHT:
    if not checkAddr_ addr: return
    if direction < 0 or direction > 3:
      throw "Direction must be RIGHT=0, DOWN=1, LEFT=2, UP=3"
    direction.repeat:
      icon = rotate icon
    drawByteArray_ addr icon 

  /**
  Draw an arrow on a panel, possibly rotated
  */
  drawArrow addr/int --direction/int = RIGHT :
    drawIcon addr ICON_ARROW --direction=direction

  /**
    Test all configured panels (Done by showing all pixels in full brightness)
  */
  test:
    maxTransferAll_ MAX7219_TEST 0X01
    sleep --ms=2000
    maxTransferAll_ MAX7219_TEST 0X00
