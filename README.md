# MAX7219
Driver for the MAX7219 8x8 matrix display.

See https://datasheets.maximintegrated.com/en/ds/MAX7219-MAX7221.pdf

It works over SPI, and up to 8 panels can be chained.

Inspired by https://github.com/squix78/MAX7219LedMatrix

## Connection to esp32

A typical MAX7219 connection would look as follows:
```
VCC -> 3v3
GND -> GND
DIN -> 13 (MOSI)
CS -> 15
CLK -> 14 (CLOCK)
```


## Usage RAW
A simple usage example.

See the full example in the examples folder!
``` toit
main:
    bus ::= spi.Bus
        //--miso=gpio.Pin 12 // Not needed for MAX7219.
        --mosi=gpio.Pin 13  // MAX7219 - DIN
        --clock=gpio.Pin 14 // MAX7219 - CLK

    device ::= bus.device
        --cs=gpio.Pin 15 // MAX7219 - CS
        --frequency=10_000_000


    max7219 := Max7219
        device // The device the MAX7219 is attached to.
        3 // Number of chained panels.
        --reverse   // Reverse panel ordering.
        --rotate=1  // Rotate all displays by 1 * 90 degrees

    // Start device.
    max7219.on

    // Draw arrows.
    max7219.drawArrow 0
    max7219.drawArrow 1 --direction=DOWN
    max7219.drawArrow 2 --direction=UP
    sleep --ms=1000

    // Draw characters.
    100.repeat:
      max7219.drawChar 2 it
      sleep --ms=500
```

See the `examples` folder for more examples.

## Usage pixel display
Use the MAX7219 as a pixel display: https://docs.toit.io/language/sdk/display

See the full example in the examples folder!
```
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

  // Start device.
  
  display := TwoColorPixelDisplay max7219

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
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/JWood48/toit-max7219/issues

