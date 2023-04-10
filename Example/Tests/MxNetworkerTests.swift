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
        case let httpResponse as HTTPURLResponse:
            return .requestFailed(errorCode: httpResponse.statusCode)
        case let response as URLResponse:
            return .invalidResponse(response: response)
        default:
            return .unknown(description: "No data received")
        }
    }

    private func givenMockHTTPResponse(code: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(url: URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!, statusCode: code, httpVersion: nil, headerFields: nil)
    }

    // MARK: - When functions

    private func whenClosureFetchCompletesWithError() {
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { [weak self] result in
            if case .failure(let error) = result {
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
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
        whenClosureFetchCompletesWithError()

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
        whenClosureFetchCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockInvalidResponse), receivedError)
    }

    func test_closureFetchFunction_withEndpoint_completesRequestFailed_whenResponseCode_isNotBetween_200and300() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosureFetchCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockResponse), receivedError)
    }

    func test_closureFetchFunction_withEndpoint_completesUnknown_whenNoData_wasReceived() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosureFetchCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: ""), receivedError)
    }

    func test_closureFetchFunction_withEndpoint_completesDeserializationFailure_whenDataDoesntCorresponds_toModel() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 200)
        let badData = Bundle.getDataFromFile("bad_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (badData, mockResponse, nil)

        // when
        whenClosureFetchCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(.failedDeserialization(type: String(describing: PokemonList.self)), receivedError)
    }

    func test_closureFetchFuncion_withEndpoint_completesWithDecodedData_whenResponseData_matchesModel() {
        // given
        givenExpectation(description: "Should return decoded data")
        let mockResponse = givenMockHTTPResponse(code: 200)
        let validData = Bundle.getDataFromFile("correct_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (validData, mockResponse, nil)
        var fetchedData: Any?

        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self) { [weak self] result in
            if case .success(let pokemonData) = result {
                fetchedData = pokemonData
                self?.globalExpectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue((fetchedData as AnyObject) is PokemonList)
    }
}
