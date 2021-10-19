discard """
  exitcode: 0
  target: "c cpp js"
"""

import unittest
import opencolor

check ocWhite == Color(0xFF_FF_FF)
check ocBlack == Color(0x00_00_00)
check ocGray0 == Color(0xF8_F9_FA)
check ocIndigo6 == Color(0x4C_6E_F5)
check ocOrange9 == Color(0xD9_48_0F)
