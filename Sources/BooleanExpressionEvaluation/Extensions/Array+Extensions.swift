//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Foundation

extension Array {
    mutating func popFirst() -> Self.Element? {
        guard let first = self.first else {
            return nil
        }
        removeFirst()
        return first
    }
}
