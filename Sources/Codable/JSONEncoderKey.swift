//
//  JSONEncoderKey.swift
//  Networking
//
//  Created by Connor Black on 04/07/2024.
//

import Foundation
import Dependencies

enum JSONEncoderKey: DependencyKey {
    public static let liveValue: JSONEncoder = JSONEncoder()
}

extension DependencyValues {
    public var jsonEncoder: JSONEncoder {
      get { self[JSONEncoderKey.self] }
      set { self[JSONEncoderKey.self] = newValue }
    }
}
