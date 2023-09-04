//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import _CollectionsTestSupport
@testable import ARTreeModule

@available(macOS 13.3, iOS 16.4, watchOS 9.4, tvOS 16.4, *)
final class ARTreeInsertTests: CollectionTestCase {
  override func setUp() {
    Const.testCheckUnique = true
  }

  override func tearDown() {
    Const.testCheckUnique = false
  }

  func testInsertBasic() throws {
    var t = ARTree<[UInt8]>()
    t.insert(key: [10, 20, 30], value: [11, 21, 31])
    t.insert(key: [11, 21, 31], value: [12, 22, 32])
    t.insert(key: [12, 22, 32], value: [13, 23, 33])
    expectEqual(
      t.description,
      "○ Node4 {childs=3, partial=[]}\n" +
      "├──○ 10: 3[10, 20, 30] -> [11, 21, 31]\n" +
      "├──○ 11: 3[11, 21, 31] -> [12, 22, 32]\n" +
      "└──○ 12: 3[12, 22, 32] -> [13, 23, 33]")
  }

  func testInsertDeleteInsertOnEmptyTree() throws {
    var t = ARTree<[UInt8]>()
    t.insert(key: [10, 20, 30], value: [1])
    t.delete(key: [10, 20, 30])
    expectEqual(t.description, "<>")
    t.insert(key: [11, 21, 31], value: [2])
    expectEqual(
      t.description,
      "○ Node4 {childs=1, partial=[]}\n" +
        "└──○ 11: 3[11, 21, 31] -> [2]")

    t.insert(key: [10, 20, 30], value: [3])
    t.delete(key: [10, 20, 30])
    expectEqual(t._root?.type, .leaf, "root should shrink to leaf")

    t.insert(key: [10, 20, 30], value: [4])
    expectEqual(t._root?.type, .node4, "should be able to insert into root leaf node")
    expectEqual(
      t.description,
      "○ Node4 {childs=2, partial=[]}\n" +
        "├──○ 10: 3[10, 20, 30] -> [4]\n" +
        "└──○ 11: 3[11, 21, 31] -> [2]")
  }

  func testInsertSharedPrefix() throws {
    var t = ARTree<[UInt8]>()
    t.insert(key: [10, 20, 30], value: [11, 21, 31])
    t.insert(key: [11, 21, 31], value: [12, 22, 32])
    t.insert(key: [12, 22, 32], value: [13, 23, 33])
    t.insert(key: [10, 20, 32], value: [1])
    expectEqual(
      t.description,
      "○ Node4 {childs=3, partial=[]}\n" +
      "├──○ 10: Node4 {childs=2, partial=[20]}\n" +
      "│  ├──○ 30: 3[10, 20, 30] -> [11, 21, 31]\n" +
      "│  └──○ 32: 3[10, 20, 32] -> [1]\n" +
      "├──○ 11: 3[11, 21, 31] -> [12, 22, 32]\n" +
      "└──○ 12: 3[12, 22, 32] -> [13, 23, 33]")
  }

  func testInsertExpandTo16() throws {
    var t = ARTree<[UInt8]>()
    t.insert(key: [1], value: [1])
    t.insert(key: [2], value: [2])
    t.insert(key: [3], value: [3])
    t.insert(key: [4], value: [4])
    expectEqual(
      t.description,
      "○ Node4 {childs=4, partial=[]}\n" +
      "├──○ 1: 1[1] -> [1]\n" +
      "├──○ 2: 1[2] -> [2]\n" +
      "├──○ 3: 1[3] -> [3]\n" +
      "└──○ 4: 1[4] -> [4]")
    t.insert(key: [5], value: [5])
    expectEqual(
      t.description,
      "○ Node16 {childs=5, partial=[]}\n" +
      "├──○ 1: 1[1] -> [1]\n" +
      "├──○ 2: 1[2] -> [2]\n" +
      "├──○ 3: 1[3] -> [3]\n" +
      "├──○ 4: 1[4] -> [4]\n" +
      "└──○ 5: 1[5] -> [5]")
  }

  func testInsertExpandTo48() throws {
    typealias T = ARTree<[UInt8]>
    var t = T()
    for ii: UInt8 in 0..<40 {
      t.insert(key: [ii
        + 1], value: [ii
        + 1])
      if ii < 4 {
        expectEqual(t._root?.type, .node4)
      } else if ii < 16 {
        expectEqual(t._root?.type, .node16)
      } else if ii < 48 {
        expectEqual(t._root?.type, .node48)
      }
    }

    let root: any InternalNode<T.Spec> = t._root!.toInternalNode()
    expectEqual(root.count, 40)
    expectEqual(
      t.description,
      "○ Node48 {childs=40, partial=[]}\n" +
      "├──○ 1: 1[1] -> [1]\n" +
      "├──○ 2: 1[2] -> [2]\n" +
      "├──○ 3: 1[3] -> [3]\n" +
      "├──○ 4: 1[4] -> [4]\n" +
      "├──○ 5: 1[5] -> [5]\n" +
      "├──○ 6: 1[6] -> [6]\n" +
      "├──○ 7: 1[7] -> [7]\n" +
      "├──○ 8: 1[8] -> [8]\n" +
      "├──○ 9: 1[9] -> [9]\n" +
      "├──○ 10: 1[10] -> [10]\n" +
      "├──○ 11: 1[11] -> [11]\n" +
      "├──○ 12: 1[12] -> [12]\n" +
      "├──○ 13: 1[13] -> [13]\n" +
      "├──○ 14: 1[14] -> [14]\n" +
      "├──○ 15: 1[15] -> [15]\n" +
      "├──○ 16: 1[16] -> [16]\n" +
      "├──○ 17: 1[17] -> [17]\n" +
      "├──○ 18: 1[18] -> [18]\n" +
      "├──○ 19: 1[19] -> [19]\n" +
      "├──○ 20: 1[20] -> [20]\n" +
      "├──○ 21: 1[21] -> [21]\n" +
      "├──○ 22: 1[22] -> [22]\n" +
      "├──○ 23: 1[23] -> [23]\n" +
      "├──○ 24: 1[24] -> [24]\n" +
      "├──○ 25: 1[25] -> [25]\n" +
      "├──○ 26: 1[26] -> [26]\n" +
      "├──○ 27: 1[27] -> [27]\n" +
      "├──○ 28: 1[28] -> [28]\n" +
      "├──○ 29: 1[29] -> [29]\n" +
      "├──○ 30: 1[30] -> [30]\n" +
      "├──○ 31: 1[31] -> [31]\n" +
      "├──○ 32: 1[32] -> [32]\n" +
      "├──○ 33: 1[33] -> [33]\n" +
      "├──○ 34: 1[34] -> [34]\n" +
      "├──○ 35: 1[35] -> [35]\n" +
      "├──○ 36: 1[36] -> [36]\n" +
      "├──○ 37: 1[37] -> [37]\n" +
      "├──○ 38: 1[38] -> [38]\n" +
      "├──○ 39: 1[39] -> [39]\n" +
      "└──○ 40: 1[40] -> [40]")
  }

  func testInsertExpandTo256() throws {
    typealias T = ARTree<[UInt8]>
    var t = T()
    for ii: UInt8 in 0..<70 {
      t.insert(key: [ii
        + 1], value: [ii
        + 1])
      if ii < 4 {
        expectEqual(t._root?.type, .node4)
      } else if ii < 16 {
        expectEqual(t._root?.type, .node16)
      } else if ii < 48 {
        expectEqual(t._root?.type, .node48)
      }
    }

    let root: any InternalNode<T.Spec> = t._root!.toInternalNode()
    expectEqual(root.count, 70)
    expectEqual(
      t.description,
      "○ Node256 {childs=70, partial=[]}\n" +
      "├──○ 1: 1[1] -> [1]\n" +
      "├──○ 2: 1[2] -> [2]\n" +
      "├──○ 3: 1[3] -> [3]\n" +
      "├──○ 4: 1[4] -> [4]\n" +
      "├──○ 5: 1[5] -> [5]\n" +
      "├──○ 6: 1[6] -> [6]\n" +
      "├──○ 7: 1[7] -> [7]\n" +
      "├──○ 8: 1[8] -> [8]\n" +
      "├──○ 9: 1[9] -> [9]\n" +
      "├──○ 10: 1[10] -> [10]\n" +
      "├──○ 11: 1[11] -> [11]\n" +
      "├──○ 12: 1[12] -> [12]\n" +
      "├──○ 13: 1[13] -> [13]\n" +
      "├──○ 14: 1[14] -> [14]\n" +
      "├──○ 15: 1[15] -> [15]\n" +
      "├──○ 16: 1[16] -> [16]\n" +
      "├──○ 17: 1[17] -> [17]\n" +
      "├──○ 18: 1[18] -> [18]\n" +
      "├──○ 19: 1[19] -> [19]\n" +
      "├──○ 20: 1[20] -> [20]\n" +
      "├──○ 21: 1[21] -> [21]\n" +
      "├──○ 22: 1[22] -> [22]\n" +
      "├──○ 23: 1[23] -> [23]\n" +
      "├──○ 24: 1[24] -> [24]\n" +
      "├──○ 25: 1[25] -> [25]\n" +
      "├──○ 26: 1[26] -> [26]\n" +
      "├──○ 27: 1[27] -> [27]\n" +
      "├──○ 28: 1[28] -> [28]\n" +
      "├──○ 29: 1[29] -> [29]\n" +
      "├──○ 30: 1[30] -> [30]\n" +
      "├──○ 31: 1[31] -> [31]\n" +
      "├──○ 32: 1[32] -> [32]\n" +
      "├──○ 33: 1[33] -> [33]\n" +
      "├──○ 34: 1[34] -> [34]\n" +
      "├──○ 35: 1[35] -> [35]\n" +
      "├──○ 36: 1[36] -> [36]\n" +
      "├──○ 37: 1[37] -> [37]\n" +
      "├──○ 38: 1[38] -> [38]\n" +
      "├──○ 39: 1[39] -> [39]\n" +
      "├──○ 40: 1[40] -> [40]\n" +
      "├──○ 41: 1[41] -> [41]\n" +
      "├──○ 42: 1[42] -> [42]\n" +
      "├──○ 43: 1[43] -> [43]\n" +
      "├──○ 44: 1[44] -> [44]\n" +
      "├──○ 45: 1[45] -> [45]\n" +
      "├──○ 46: 1[46] -> [46]\n" +
      "├──○ 47: 1[47] -> [47]\n" +
      "├──○ 48: 1[48] -> [48]\n" +
      "├──○ 49: 1[49] -> [49]\n" +
      "├──○ 50: 1[50] -> [50]\n" +
      "├──○ 51: 1[51] -> [51]\n" +
      "├──○ 52: 1[52] -> [52]\n" +
      "├──○ 53: 1[53] -> [53]\n" +
      "├──○ 54: 1[54] -> [54]\n" +
      "├──○ 55: 1[55] -> [55]\n" +
      "├──○ 56: 1[56] -> [56]\n" +
      "├──○ 57: 1[57] -> [57]\n" +
      "├──○ 58: 1[58] -> [58]\n" +
      "├──○ 59: 1[59] -> [59]\n" +
      "├──○ 60: 1[60] -> [60]\n" +
      "├──○ 61: 1[61] -> [61]\n" +
      "├──○ 62: 1[62] -> [62]\n" +
      "├──○ 63: 1[63] -> [63]\n" +
      "├──○ 64: 1[64] -> [64]\n" +
      "├──○ 65: 1[65] -> [65]\n" +
      "├──○ 66: 1[66] -> [66]\n" +
      "├──○ 67: 1[67] -> [67]\n" +
      "├──○ 68: 1[68] -> [68]\n" +
      "├──○ 69: 1[69] -> [69]\n" +
      "└──○ 70: 1[70] -> [70]")
  }

  func _testCommon(_ items: [[UInt8]],
                   expectedRootType: NodeType?,
                   reps: UInt = 1) throws {
    for iter in 0..<reps {
      if iter % 10 == 0 {
        print("testInsertAndGet: Iteration: \(iter)")
      }

      var tree = ARTree<Int>()
      for (index, key) in items.enumerated() {
        tree.insert(key: key, value: index + 10)
      }

      for (index, key) in items.enumerated().shuffled() {
        expectEqual(tree.getValue(key: key), index + 10)
      }
    }
  }

  func _testCommon(_ items: [([UInt8], [UInt8])],
                   expectedRootType: NodeType?,
                   reps: UInt = 1) throws {
    for iter in 0..<reps {
      if iter % 10 == 0 {
        print("testInsertAndGet: Iteration: \(iter)")
      }

      var tree = ARTree<[UInt8]>()
      for (key, value) in items {
        tree.insert(key: key, value: value)
      }

      for (key, value) in items.shuffled() {
        expectEqual(tree.getValue(key: key), value)
      }
    }
  }

  func testInsertPrefixSharedSmall() throws {
    let items: [[UInt8]] = [
      [1, 2, 3, 4, 5],
      [1, 2, 3, 4, 6],
      [1, 2, 3, 4, 7]
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertPrefixLongOnNodePrefixFull() throws {
    let items: [[UInt8]] = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 11],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 12]
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertPrefixLongMultiLayer1() throws {
    let items: [[UInt8]] = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 17],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 18]
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertPrefixLongMultiLayer2() throws {
    let items: [[UInt8]] = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 11, 12, 13, 14, 17],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 11, 12, 13, 14, 18]
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertPrefixLongMultiLayer3() throws {
    var items: [[UInt8]] = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 24]
    ]

    var tree = ARTree<Int>()
    for (index, key) in items.enumerated() {
      _ = tree.insert(key: key, value: index + 10)
    }

    expectEqual(
      tree.description,
      "○ Node4 {childs=1, partial=[]}\n" +
        "└──○ 1: Node4 {childs=1, partial=[2]}\n" +
        "│  └──○ 3: Node4 {childs=1, partial=[4, 5, 6, 7, 8, 9, 10, 11]}\n" +
        "│  │  └──○ 12: Node4 {childs=3, partial=[13, 14, 16, 17, 18, 19, 20, 21]}\n" +
        "│  │  │  ├──○ 22: 21[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 22] -> 10\n" +
        "│  │  │  ├──○ 23: 21[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23] -> 11\n" +
        "│  │  │  └──○ 24: 21[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 24] -> 12")

    items.append([1, 2, 3, 4, 5, 6, 7, 8, 10, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 21, 23])

    tree.insert(key:items.last!, value: 3 + 10)
    for (val, test) in items.enumerated() {
      expectEqual(tree.getValue(key: test), val + 10)
    }
  }

  func testInsertPrefixLongMultiLayer5() throws {
    let items: [[UInt8]] = [
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 99, 13, 14, 15, 17, 18, 19, 66, 21, 22, 77, 24, 25, 26, 27],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 88, 13, 14, 15, 17, 18, 19, 55, 21, 22, 66, 24, 25, 26, 27],
      [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 99, 13, 14, 15, 17, 18, 19, 66, 21, 22, 44, 24, 25, 26, 27],
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertAndGetSmallSetRepeat48() throws {
    let items: [([UInt8], [UInt8])] = [
      ([15, 118, 236, 37], [184, 222, 84, 178, 8, 42, 238, 20]),
      ([45, 142, 131, 183, 171, 108, 168], [153, 208, 8, 76, 71, 219]),
      ([132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([201, 251, 245, 67, 118, 215, 95], [232, 42, 102, 176, 41, 195, 118, 191]),
      ([101, 234, 198, 223, 121, 0], [239, 66, 245, 90, 33, 99, 232, 56, 70, 210]),
      ([172, 34, 70, 29, 249, 116, 239, 109], [209, 14, 239, 173, 182, 124, 148]),
      ([99, 136, 84, 183, 107], [151, 55, 124, 56, 254, 255, 106]),
      ([118, 20, 190, 173, 101, 67, 245], [161, 154, 111, 179, 216, 198, 248, 206, 164, 243]),
      ([57, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([83, 22, 7, 62, 40, 239], [137, 78, 27, 99, 66]),
    ]

    try _testCommon(items, expectedRootType: .node16, reps: 100)
  }

  func testInsertAndGetSmallSetRepeat256() throws {
    let items: [([UInt8], [UInt8])] = [
      ([15, 118, 236, 37], [184, 222, 84, 178, 8, 42, 238, 20]),
      ([15, 45, 142, 131, 183, 171, 108, 168], [153, 208, 8, 76, 71, 219]),
      ([15, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([15, 45, 201, 251, 245, 67, 118, 215, 95], [232, 42, 102, 176, 41, 195, 118, 191]),
      ([101, 234, 198, 223, 121, 0], [239, 66, 245, 90, 33, 99, 232, 56, 70, 210]),
      ([172, 34, 70, 29, 249, 116, 239, 109], [209, 14, 239, 173, 182, 124, 148]),
      ([99, 136, 84, 183, 107], [151, 55, 124, 56, 254, 255, 106]),
      ([118, 20, 190, 173, 101, 67, 245], [161, 154, 111, 179, 216, 198, 248, 206, 164, 243]),
      ([57, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([83, 22, 7, 62, 40, 239], [137, 78, 27, 99, 66]),
      ([15, 99, 136, 84, 183, 107], [151, 55, 124, 56, 254, 255, 106]),
      ([99, 118, 20, 190, 173, 101, 67, 245], [161, 154, 111, 179, 216, 198, 248, 206, 164, 243]),
      ([118, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([24, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([45, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([12, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([22, 9, 214, 179, 231, 31, 175, 125, 231, 83], [54, 4, 138, 111, 143, 121, 2]),
      ([15, 15, 99, 136, 84, 183, 107], [151, 55, 124, 56, 254, 255, 106]),
      ([57, 99, 118, 20, 190, 173, 101, 67, 245], [161, 154, 111, 179, 216, 198, 248, 206, 164, 243]),
      ([57, 83, 22, 7, 62, 40, 239], [137, 78, 27, 99, 66]),
      ([16, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([17, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([18, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([28, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([88, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([78, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
      ([19, 132, 29, 2, 67, 152, 3, 180, 115, 216, 202], [85, 13, 131, 117, 120]),
    ]

    try _testCommon(items, expectedRootType: .node48, reps: 100)
  }

  func testInsertPrefixSmallLong() throws {
    let items: [([UInt8], [UInt8])] = [
      ([1, 2, 1, 2, 3, 2, 3, 3, 1, 3, 1, 0, 0, 2, 0, 3, 0, 1, 1], [1, 1, 2, 0, 3, 1, 3, 1, 0, 1, 3, 3, 1, 2, 3, 1, 1, 0, 1]),
      ([1, 3, 2, 2, 1, 0, 0, 2, 3, 2, 0], [0, 0, 2, 0, 3, 3, 0, 3, 3, 0, 2, 3, 3, 1, 2, 3, 2]),
      ([2, 0, 1, 0, 1, 2, 2, 3], [3, 3, 1, 3, 2, 2, 2, 1, 2, 0, 2, 1, 0, 0, 0, 2, 0, 1, 1, 1]),
      ([3, 1, 2, 0, 3, 1, 0, 2, 1, 0, 0, 3, 3, 3, 3, 0, 2, 3], [1, 0, 1, 0, 3, 3, 2, 2, 2, 1, 2, 1, 0, 3, 1, 3, 3, 1, 3, 3]),
      ([2, 0, 2, 2, 0, 2, 2, 0, 3, 2, 2, 3, 1, 0, 1], [1, 1, 3, 2, 2, 1]),
      ([2, 1, 2, 3, 1, 2, 2, 1, 2, 1, 0, 2, 2, 1], [3, 2, 2, 3, 0, 1, 0, 3, 3, 0, 1, 2]),
    ]

    try _testCommon(items, expectedRootType: .node16)
  }

  func testInsertPrefixSmall2() throws {
    let items: [([UInt8], [UInt8])] = [
      ([3, 1, 3, 1, 1, 2, 0], [2, 4, 0]),
      ([2, 4, 4, 0], [4, 1, 0]),
      ([3, 2, 1, 3, 1, 1, 0], [4, 3, 0]),
      ([4, 4, 4, 4, 0], [4, 3, 0]),
      ([1, 1, 2, 2, 4, 0], [3, 2, 0]),
      ([3, 3, 1, 1, 3, 0], [4, 4, 4, 4, 0]),
      ([3, 4, 4, 4, 0], [1, 3, 3, 2, 2, 2, 2, 0]),
      ([3, 1, 3, 3, 0], [4, 3, 0]),
      ([3, 1, 0], [2, 2, 3, 3, 4, 0]),
    ]

    try _testCommon(items, expectedRootType: .node16)
  }

  func testInsertLongSharedPrefix1() throws {
    let items: [([UInt8], [UInt8])] = [
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], [1]),
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19], [2]),
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertLongSharedPrefix2() throws {
    let items: [([UInt8], [UInt8])] = [
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], [1]),
      ([1, 4, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], [4]),
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19], [2]),
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20], [3]),
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testInsertLongSharedPrefix3() throws {
    let items: [([UInt8], [UInt8])] = [
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], [1]),
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19], [2]),
      ([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 20], [3]),
    ]

    try _testCommon(items, expectedRootType: .node4)
  }

  func testReplace() throws {
    var t = ARTree<Int>()
    let items: [[UInt8]] = [
      [11, 21, 31],
      [12, 22, 32],
      [10, 20, 32]
    ]

    for (idx, test) in items.enumerated() {
      t.insert(key: test, value: idx)
    }

    for (idx, test) in items.enumerated() {
      t.insert(key: test, value: idx + 10)
    }

    for (idx, test) in items.enumerated() {
      expectEqual(t.getValue(key: test), idx + 10)
    }
  }
}
