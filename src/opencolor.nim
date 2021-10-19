# Copyright (c) 2021 Double-oxygeN
# 
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import macros, strutils, tables

type
  Color* = distinct range[0x00_00_00'u32..0xFF_FF_FF'u32]

  RedValue* = uint8
  GreenValue* = uint8
  BlueValue* = uint8
  RGBValue* = tuple
    r: RedValue
    g: GreenValue
    b: BlueValue

  OpenColorNotFoundError* = object of CatchableError


macro buildOc(colorDefs: untyped): untyped =
  result = nnkStmtList.newNimNode()
  colorDefs.expectKind nnkStmtList

  var registeredColors = initCountTable[string]()

  # Colors as constants
  let colorDefConstSection = nnkConstSection.newNimNode()

  for colorNameDef in colorDefs:
    colorNameDef.expectKind nnkCall
    colorNameDef.expectLen 2
    colorNameDef[0].expectKind nnkIdent
    colorNameDef[1].expectKind nnkStmtList

    for colorCodeDef in colorNameDef[1]:
      colorCodeDef.expectKind { nnkIntLit, nnkCall }

      let
        colorConstDef =
          if colorCodeDef.kind == nnkIntLit:
            if registeredColors.hasKey($colorNameDef[0]):
              error("Already defined.", colorNameDef)

            let
              colorIdNode = ident("oc" & capitalizeAscii($colorNameDef[0])).postfix("*")
              colorExprNode = newCall("Color", colorCodeDef)

            registeredColors.inc($colorNameDef[0])

            nnkConstDef.newTree(colorIdNode, ident"Color", colorExprNode)

          else:
            colorCodeDef.expectLen 2
            colorCodeDef[0].expectKind nnkIntLit
            colorCodeDef[1].expectKind nnkStmtList
            colorCodeDef[1].expectLen 1
            colorCodeDef[1][0].expectKind nnkIntLit

            if registeredColors.getOrDefault($colorNameDef[0], 0) != colorCodeDef[0].intVal:
              error("Wrong numbering.", colorCodeDef[0])

            let
              colorIdNode = ident("oc" & capitalizeAscii($colorNameDef[0]) & $colorCodeDef[0].intVal).postfix("*")
              colorExprNode = newCall("Color", colorCodeDef[1][0])

            registeredColors.inc($colorNameDef[0])

            nnkConstDef.newTree(colorIdNode, ident"Color", colorExprNode)

      colorDefConstSection.add colorConstDef

  result.add colorDefConstSection

  # Convert a string as an ID to color, when a color exists
  let
    normalizedColorNameSym = genSym()
    parserStmt = nnkIfStmt.newNimNode()

  for colorName, count in registeredColors:
    let firstCond = newCall(ident"startsWith", normalizedColorNameSym, newStrLitNode(colorName))

    if count == 1:
      parserStmt.add nnkElifBranch.newTree(firstCond, nnkReturnStmt.newTree(ident("oc" & capitalizeAscii(colorName))))

    else:
      let firstResultBody = nnkIfStmt.newNimNode()

      for num in 0..<count:
        let secondCond = newCall(ident"endsWith", normalizedColorNameSym, newStrLitNode($num))

        firstResultBody.add nnkElifBranch.newTree(secondCond, nnkReturnStmt.newTree(ident("oc" & capitalizeAscii(colorName) & $num)))

      parserStmt.add nnkElifBranch.newTree(firstCond, firstResultBody)

  let converterProcBody = quote do:
    let `normalizedColorNameSym` = normalize(colorName)

    `parserStmt`

    raise OpenColorNotFoundError.newException("Color '" & colorName & "' is not found in Open color.")

  let converterProcDef = newProc(ident"oc".postfix("*"), @[ident"Color", newIdentDefs(ident"colorName", ident"string")], converterProcBody)
  result.add converterProcDef


# Open color, version 1.9.1
# See https://yeun.github.io/open-color/

buildOc:
  white: 0xFF_FF_FF
  black: 0x00_00_00

  gray:
    0: 0xF8_F9_FA
    1: 0xF1_F3_F5
    2: 0xE9_EC_EF
    3: 0xDE_E2_E6
    4: 0xCE_D4_DA
    5: 0xAD_B5_BD
    6: 0x86_8E_96
    7: 0x49_50_57
    8: 0x34_3A_40
    9: 0x21_25_29

  red:
    0: 0xFF_F5_F5
    1: 0xFF_E3_E3
    2: 0xFF_C9_C9
    3: 0xFF_A8_A8
    4: 0xFF_87_87
    5: 0xFF_6B_6B
    6: 0xFA_52_52
    7: 0xF0_3E_3E
    8: 0xE0_31_31
    9: 0xC9_2E_2E

  pink:
    0: 0xFF_F0_F6
    1: 0xFF_DE_EB
    2: 0xFC_C2_D7
    3: 0xFA_A2_C1
    4: 0xF7_83_AC
    5: 0xF0_65_95
    6: 0xE6_49_80
    7: 0xD6_33_6C
    8: 0xC2_25_5C
    9: 0xA6_1E_4D

  grape:
    0: 0xF8_F0_FC
    1: 0xF3_D9_FA
    2: 0xEE_BE_FA
    3: 0xE5_99_F7
    4: 0xDA_77_F2
    5: 0xCC_5D_E8
    6: 0xBE_4B_DB
    7: 0xAE_3E_C9
    8: 0x9C_36_B5
    9: 0x86_2E_9C

  violet:
    0: 0xF3_F0_FF
    1: 0xE5_DB_FF
    2: 0xD0_BF_FF
    3: 0xB1_97_FC
    4: 0x97_75_FA
    5: 0x84_5E_F7
    6: 0x79_50_F2
    7: 0x70_48_E8
    8: 0x67_41_D9
    9: 0x5F_3D_C4

  indigo:
    0: 0xED_F2_FF
    1: 0xDB_E4_FF
    2: 0xBA_C8_FF
    3: 0x91_A7_FF
    4: 0x74_8F_FC
    5: 0x5C_7C_FA
    6: 0x4C_6E_F5
    7: 0x42_63_EB
    8: 0x3B_5B_DB
    9: 0x36_4F_C7

  blue:
    0: 0xE7_F5_FF
    1: 0xD0_EB_FF
    2: 0xA5_D8_FF
    3: 0x74_C0_FC
    4: 0x4D_AB_F7
    5: 0x33_9A_F0
    6: 0x22_8B_E6
    7: 0x1C_7E_D6
    8: 0x19_71_C2
    9: 0x18_64_AB

  cyan:
    0: 0xE3_FA_FC
    1: 0xC5_F6_FA
    2: 0x99_E9_F2
    3: 0x66_D9_E8
    4: 0x3B_C9_DB
    5: 0x22_B8_CF
    6: 0x15_AA_BF
    7: 0x10_98_AD
    8: 0x0C_85_99
    9: 0x0B_72_85

  teal:
    0: 0xE6_FC_F5
    1: 0xC3_FA_E8
    2: 0x96_F2_D7
    3: 0x63_E6_BE
    4: 0x38_D9_A9
    5: 0x20_C9_97
    6: 0x12_B8_86
    7: 0x0C_A6_78
    8: 0x09_92_68
    9: 0x08_7F_5B

  green:
    0: 0xEB_FB_EE
    1: 0xD3_F9_D8
    2: 0xB2_F2_BB
    3: 0x8C_E9_9A
    4: 0x69_DB_7C
    5: 0x51_CF_66
    6: 0x40_C0_57
    7: 0x37_B2_4D
    8: 0x2F_9E_44
    9: 0x2B_8A_3E

  lime:
    0: 0xF4_FC_E3
    1: 0xE9_FA_C8
    2: 0xD8_F5_A2
    3: 0xC0_EB_75
    4: 0xA9_E3_4B
    5: 0x94_D8_2D
    6: 0x82_C9_1E
    7: 0x74_B8_16
    8: 0x66_A8_0F
    9: 0x5C_94_0D

  yellow:
    0: 0xFF_F9_DB
    1: 0xFF_F3_BF
    2: 0xFF_EC_99
    3: 0xFF_E0_66
    4: 0xFF_D4_3B
    5: 0xFC_C4_19
    6: 0xFA_B0_05
    7: 0xF5_9F_00
    8: 0xF0_8C_00
    9: 0xE6_77_00

  orange:
    0: 0xFF_F4_E6
    1: 0xFF_E8_CC
    2: 0xFF_D8_A8
    3: 0xFF_C0_78
    4: 0xFF_A9_4D
    5: 0xFF_92_2B
    6: 0xFD_7E_14
    7: 0xF7_67_07
    8: 0xE8_59_0C
    9: 0xD9_48_0F


func toRGB*(color: Color): RGBValue =
  result.r = RedValue((uint32(color) shr 16) and 0xFF)
  result.g = GreenValue((uint32(color) shr 8) and 0xFF)
  result.b = BlueValue(uint32(color) and 0xFF)


func toHexString*(color: Color): string =
  result = "#" & uint32(color).toHex(6)


func `$`*(color: Color): string =
  return color.toHexString()


func `==`*(x, y: Color): bool {.borrow.}
