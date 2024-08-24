//
//  Utils.swift
//  MxNetworkingTests
//
//  Created by Uriel Hernandez Gonzalez on 14/08/24.
//

@testable import MxNetworking
import Foundation

func ExpectedError(for value: Any) -> APIError {
    switch value {
    case let error as Error:
        return .unknown(description: "\(error)")
    case let httpResponse as HTTPURLResponse:
        return .requestFailed(errorCode: httpResponse.statusCode)
    case let response as URLResponse:
        return .invalidResponse(response: response)
    default:
        return .unknown(description: "No data received")
    }
}

func MockHTTPResponse(code: Int) -> HTTPURLResponse? {
    HTTPURLResponse(url: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!, statusCode: code, httpVersion: nil, headerFields: nil)
}
