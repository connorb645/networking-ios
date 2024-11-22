//
//  HTTPURLResponse+Extension.swift
//  Networking
//
//  Created by Connor Black on 04/07/2024.
//

import Foundation

public enum HTTPResponseError: Error {
    case badStatusCode(Int)
}

extension HTTPURLResponse {
    func checkOKStatus() throws {
        guard (200...299) ~= self.statusCode else { throw HTTPResponseError.badStatusCode(self.statusCode) }
    }
}
