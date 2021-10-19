discard """
  exitcode: 0
  target: "c cpp js"
"""

import unittest
from opencolor import oc, ocGrape7, `==`

const col = oc("grape-7")

check col == ocGrape7
