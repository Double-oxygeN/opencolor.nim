discard """
  exitcode: 0
  target: "c cpp js"
"""

import unittest
import opencolor

block:
  let (r, g, b) = ocTeal5.toRGB()

  check r == 32
  check g == 201
  check b == 151

block:
  let (r, g, b) = ocPink9.toRGB()

  check r == 166
  check g == 30
  check b == 77
