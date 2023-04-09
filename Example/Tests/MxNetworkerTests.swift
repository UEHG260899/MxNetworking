//
//  MxNetworkerTests.swift
//  MxNetworking_Tests
//
//  Created by Uriel Hernandez Gonzalez on 08/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import MxNetworking

final class MxNetworkerTests: XCTestCase {

    var sut: MxNetworker!
    var mockSession: MockUrlSession!
    var globalExpectation: XCTestExpectation!
    var receivedError: APIError?

    override func setUp() {
        super.setUp()
        mockSession = MockUrlSession()
        sut = MxNetworker(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        globalExpectation = nil
        receivedError = nil
        super.tearDown()
    }

    // MARK: - Given functions

    private func givenExpectation(description: String) {
       globalExpectation = expectation(description: description)
    }

    private func getExpectedError(for value: Any) -> APIError {
        switch value {
        case let error as Error:
            return .unknown(description: "\(error)")
        case let response as URLResponse:
            return .invalidResponse(response: response)
        default:
            return .unknown(description: "")
        }
    }

    func test_onInit_sessionProperty_isSet() {
        XCTAssertNotNil(sut.session)
    }

    func test_closureFetchFunction_withEndpoint_callsDataTaskFunction_onSession() {
        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self, completion: {_ in })

        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.dataTask))
    }

    func test_closureFetchFunction_withEndpoint_sendsCorrectURLRequest_toSession() {
        // given
        let testUrl = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!
        var testRequest = URLRequest(url: testUrl)
        testRequest.httpMethod = HTTPMethod.get.rawValue

        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self, completion: {_ in})

        // then
        XCTAssertEqual(mockSession.receivedRequest?.url, testUrl)
        XCTAssertEqual(mockSession.receivedRequest?.httpMethod, HTTPMethod.get.rawValue.uppercased())
    }

    func test_closureFetchFunction_withEndpoint_completesWithError_whenResponseReturnsError() {
        // given
        givenExpectation(description: "Should receive error")
        let mockError = NSError(domain: "com.mxnetworking", code: 100)
        mockSession.expectedCompletionValues = (nil, nil, mockError)

        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: Pokemon.self) { [weak self] result in
            if case .failure(let error) = result {
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockError), receivedError)
    }

    func test_closureFetchFunction_withEndpoint_completesInvalidResponse_whenResponse_cantBeCastedToHTTPUrlResponse() {
        // given
        givenExpectation(description: "Should receive error")
        let mockInvalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, mockInvalidResponse, nil)

        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: Pokemon.self) { [weak self] result in
            if case .failure(let error) = result {
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockInvalidResponse), receivedError)
    }
}
