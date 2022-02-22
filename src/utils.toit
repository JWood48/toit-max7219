/* 
  Copyright 2022
  @Author Jakob Skov

  You may not use this file except in compliance with the License.
  Unless required by applicable law or agreed to in writing, software distributed under the License 
  is distrubuted on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*/

rotate arr/ByteArray -> ByteArray:
  if arr.size != 8:
    print "BAD ARGUMENT!!"
    throw "array size must be 8"
  out := #[0, 0, 0, 0, 0, 0, 0, 0]
  for i := 0; i < 8; i++:
    for j := 0; j < 8; j++:
      val := arr[i] >> j & 1
      out[7-j] |= val << i
  return out
