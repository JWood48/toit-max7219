# MAX7219
Driver for the MAX7219  8x8 matrix display

See https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf

It works over SPI, and up to 8 8x8 displays can be chained

Inspired by https://github.com/squix78/MAX7219LedMatrix

## Connection to esp32

MAX7219 Pins:
```
VCC -> 3v3
GND -> GND
DIN -> 13 (MOSI)
CS -> 15 
CLK -> 14 (CLOCK)
```


## Usage
A simple usage example.

``` toit
import gpio
import spi
import max7219 show *

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

    // draw characters
    100.repeat:
        max7219.drawChar 2 it
        sleep --ms=500
```

See the `examples` folder for more examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/JWood48/toit-max7219/issues

