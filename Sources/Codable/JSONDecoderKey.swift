//
//  JSONDecoderKey.swift
//  Networking
//
//  Created by Connor Black on 04/07/2024.
//

import Foundation
import Dependencies

enum JSONDecoderKey: DependencyKey {
    public static let liveValue: JSONDecoder = JSONDecoder()
}

extension DependencyValues {
    public var jsonDecoder: JSONDecoder {
      get { self[JSONDecoderKey.self] }
      set { self[JSONDecoderKey.self] = newValue }
    }
}
