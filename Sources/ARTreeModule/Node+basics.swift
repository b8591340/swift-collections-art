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

extension InternalNode {
  var partialLength: Int {
    get {
      storage.withHeaderPointer {
        Int($0.pointee.partialLength)
      }
    }
    set {
      assert(newValue <= Const.maxPartialLength)
      storage.withHeaderPointer {
        $0.pointee.partialLength = KeyPart(newValue)
      }
    }
  }

  var partialBytes: PartialBytes {
    get {
      storage.withHeaderPointer {
        $0.pointee.partialBytes
      }
    }
    set {
      storage.withHeaderPointer {
        $0.pointee.partialBytes = newValue
      }
    }
  }

  var count: Int {
    get {
      storage.withHeaderPointer {
        Int($0.pointee.count)
      }
    }
    set {
      storage.withHeaderPointer {
        $0.pointee.count = UInt16(newValue)
      }
    }
  }

  func child(forKey k: KeyPart) -> RawNode? {
    var ref = UnsafeMutablePointer<RawNode?>(nil)
    return child(forKey: k, ref: &ref)
  }

  mutating func addChild(forKey k: KeyPart, node: any ManagedNode) {
    let ref = UnsafeMutablePointer<RawNode?>(nil)
    addChild(forKey: k, node: node, ref: ref)
  }

  mutating func deleteChild(forKey k: KeyPart, ref: ChildSlotPtr?) {
    let index = index(forKey: k)
    assert(index != nil, "trying to delete key that doesn't exist")
    if index != nil {
      deleteChild(at: index!, ref: ref)
    }
  }

  mutating func deleteChild(forKey k: KeyPart) {
    var ptr: RawNode? = RawNode(from:self)
    return deleteChild(forKey: k, ref: &ptr)
  }

  mutating func deleteChild(at index: Index) {
    var ptr: RawNode? = RawNode(from: self)
    deleteChild(at: index, ref: &ptr)
  }

  mutating func copyHeader(from: any InternalNode) {
    self.storage.withHeaderPointer { header in
      header.pointee.count = UInt16(from.count)
      header.pointee.partialLength = UInt8(from.partialLength)
      header.pointee.partialBytes = from.partialBytes
    }
  }

  // Calculates the index at which prefix mismatches.
  func prefixMismatch(withKey key: Key, fromIndex depth: Int) -> Int {
    assert(partialLength <= Const.maxPartialLength, "partial length is always bounded")
    let maxComp = min(partialLength, key.count - depth)

    for index in 0..<maxComp {
      if partialBytes[index] != key[depth + index] {
        return index
      }
    }

    return maxComp
  }
}
