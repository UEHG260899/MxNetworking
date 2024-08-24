//
//  RequestTests.swift
//  MxNetworkingTests
//
//  Created by Uriel Hernandez Gonzalez on 05/08/24.
//

@testable import MxNetworking
import XCTest

final class RequestTests: XCTestCase {

    func testInitWithEmptyUrlString() {
        // When
        let request = Request(url: "")
        
        // Then
        XCTAssertNil(request.httpRequest())
    }

    func testInitWithValidUrlString() throws {
        // Given
        let request = Request(url: "www.google.com")
        
        // When
        let httpRequest = try XCTUnwrap(request.httpRequest())
        
        // Then
        XCTAssertEqual(httpRequest.url?.absoluteString, "www.google.com")
        XCTAssertEqual(httpRequest.httpMethod, HTTPMethod.GET.rawValue)
    }

    func testInitWithParametersSetsQueryParams() throws {
        // Given
        let parameters = ["foo": "bar", "bar": "foo"]
        let request = Request(url: "www.google.com", method: .GET, parameters: parameters)
        
        // When
        let httpRequest = try XCTUnwrap(request.httpRequest())
        let components = URLComponents(url: httpRequest.url!, resolvingAgainstBaseURL: true)
        let queryItems = try XCTUnwrap(components?.queryItems)

        // Then
        for item in queryItems {
            XCTAssertNotNil(parameters[item.name])
            XCTAssertEqual(item.value, parameters[item.name, default: ""])
        }
    }

    func testInitWithBodySetsData() throws {
        // Given
        let mockBody = MockModel(property: "Test")
        let request = Request(url: "www.google.com", method: .POST, body: mockBody)
        
        // When
        let httpRequest = try XCTUnwrap(request.httpRequest())
        
        // Then
        XCTAssertNotNil(httpRequest.httpBody)
    }

}
