//
//  MockUrlSession.swift
//  MxNetworking_Example
//
//  Created by Uriel Hernandez Gonzalez on 08/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import MxNetworking

class MockUrlSession: URLSessionProtocol {

    struct CalledMethods: OptionSet {
        let rawValue: Int

        static let dataTask = CalledMethods(rawValue: 1 << 0)
        static let data = CalledMethods(rawValue: 2 << 0)
    }

    var calledMethods: CalledMethods = []
    var receivedRequest: URLRequest?
    var expectedCompletionValues: (data: Data?, response: URLResponse?, error: Error?)?
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        calledMethods.insert(.dataTask)
        receivedRequest = request
        
        completionHandler(expectedCompletionValues?.data, expectedCompletionValues?.response, expectedCompletionValues?.error)
        
        return URLSession.shared.dataTask(with: request)
    }
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        calledMethods.insert(.data)
        return await withCheckedContinuation { continuation in
            continuation.resume(returning: (Data(), URLResponse()))
        }
    }
    
    
}
