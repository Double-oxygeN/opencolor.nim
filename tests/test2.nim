discard """
  exitcode: 0
  target: "c cpp js"
"""

import unittest
import opencolor

check oc"black" == ocBlack
check oc"White" == ocWhite
check oc"red-3" == ocRed3
check oc"violet8" == ocViolet8
check oc"Yellow 0" == ocYellow0
check oc"GREEN__9" == ocGreen9

expect OpenColorNotFoundError:
  discard oc"scarlet-3"

expect OpenColorNotFoundError:
  discard oc"red"
