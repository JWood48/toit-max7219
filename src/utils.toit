

rotate arr/ByteArray -> ByteArray:
    if arr.size != 8:
      print "BAD ARGUMENT!!"
      throw "array size must be 8"
    out := #[0,0,0,0,0,0,0,0]
    // out.fill 0x0
    for i := 0; i < 8; i += 1:
      for j := 0; j < 8; j += 1:
        val := arr[i] >> j & 1
        out[7-j] |= val << i
    return out