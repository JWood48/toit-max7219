import gpio
import spi
import max7219 show *

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
                  --mosi=gpio.Pin 13 --output // MAX7219 - DIN
                  --clock=gpio.Pin 14 --output // MAX7219 - CLK

    device ::= bus.device
                   --cs=gpio.Pin 15 --output // MAX7219 - CS
                   --frequency=10_000_000


    max7219 := Max7219 
                    device // the device the MAX7219 is attached to
                    3 // number of chained panels
                    --reverse=true // reverse panel ordering
                    --rotate=1  // Rotate all displays by 1 * 90 degrees

    // start device
    max7219.on

    // draw arrows
    max7219.drawArrow 0
    max7219.drawArrow 1 --direction=DOWN
    max7219.drawArrow 2 --direction=UP
    sleep --ms=1000

    // create an icon showing an X by setting bits to 1 in a bytearray of size 8
    cross_icon := rotate #[
        0b10000001,
        0b01000010,
        0b00100100,
        0b00011000,
        0b00011000,
        0b00100100,
        0b01000010,
        0b10000001,
        ]

    max7219.drawIcon 0 cross_icon

    // draw characters
    100.repeat:
        max7219.drawChar 2 it
        sleep --ms=500

              