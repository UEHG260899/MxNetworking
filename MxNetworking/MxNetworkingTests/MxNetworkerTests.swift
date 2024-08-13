//
//  MxNetworkerTests.swift
//  MxNetworking_Tests
//
//  Created by Uriel Hernandez Gonzalez on 08/04/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import XCTest
@testable import MxNetworking
@testable import MxNetworkingDemo

final class MxNetworkerTests: XCTestCase {

    let mockURL = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0")!
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

    private func givenTestProduct() -> Product {
        return Product(id: nil, title: "", price: 0, description: "", image: "", category: "")
    }

    private func givenRequest(method: HTTPMethod = .GET, body: Encodable? = nil, headers: [String: String]? = nil) -> URLRequest {
        var request = URLRequest(url: mockURL)
        request.httpMethod = method.rawValue

        if let body  {
            request.httpBody = try? JSONEncoder().encode(body)
        }

        if let headers {
            headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        }

        return request
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

    private func whenClosureFetchWithUrlCompletesWithError() {
        sut.fetch(url: mockURL, decodingType: PokemonList.self) { [weak self] result in
            if case .failure(let error) = result {
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
        }
    }

    private func whenClosurePostWithEndpointCompletes() {
        sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct()) { [weak self] result in
            switch result {
            case .success:
                self?.globalExpectation.fulfill()
            case .failure(let error):
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
        }
    }

    private func whenClosurePostWithUrlCompletes() {
        sut.post(url: mockURL, body: givenTestProduct()) { [weak self] result in
            switch result {
            case .success:
                self?.globalExpectation.fulfill()
            case .failure(let error):
                self?.receivedError = error
                self?.globalExpectation.fulfill()
            }
        }
    }

    private func whenAsyncPostCompletesWithError() async {
        do {
            try await sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct())
            XCTFail()
        } catch {
            receivedError = error as? APIError
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
        // when
        sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self, completion: {_ in})

        // then
        XCTAssertEqual(mockSession.receivedRequest?.url, mockURL)
        XCTAssertEqual(mockSession.receivedRequest?.httpMethod, HTTPMethod.GET.rawValue.uppercased())
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

    func test_closureFetchFunction_withURL_callsDataTaskMethod_onSession() {
        // given
        let mockURL = URL(string: "about:blank")!

        // when
        sut.fetch(url: mockURL, decodingType: PokemonList.self, completion: {_ in })

        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.dataTask))
    }

    func test_closureFetchFunction_withURL_sendsCorrectURLRequest_toSession() {
        // when
        sut.fetch(url: mockURL, decodingType: PokemonList.self, completion: { _ in })

        // then
        XCTAssertEqual(mockSession.receivedRequest?.url, mockURL)
        XCTAssertEqual(mockSession.receivedRequest?.httpMethod, HTTPMethod.GET.rawValue.uppercased())
    }

    func test_closureFetchFunction_withURL_completesWithError_whenResponseReturnsError() {
        // given
        givenExpectation(description: "Should receive error")
        let mockError = NSError(domain: "com.mxmoney", code: 120)
        mockSession.expectedCompletionValues = (nil, nil, mockError)

        // when
        whenClosureFetchWithUrlCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockError), receivedError)
    }

    func test_closureFetchFunction_withURL_completesWithInvalidResponse_whenResponseCantBeParsed_toHTTPResponse() {
        // given
        givenExpectation(description: "Should receive error")
        let invalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, invalidResponse, nil)

        // when
        whenClosureFetchWithUrlCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: invalidResponse), receivedError)
    }

    func test_closureFetchFunction_withURL_completesWithRequestFailed_whenResponseCode_isntBetween200And300() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosureFetchWithUrlCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockResponse), receivedError)
    }

    func test_closureFetchFunction_withURL_completesWithUnknown_whenNoDataWasReceived() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosureFetchWithUrlCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: ""), receivedError)
    }

    func test_closureFetchFunction_withURL_completesWithFailedDeserialization_whenDataDoesntMatchTheModel() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 200)
        let badResponseData = Bundle.getDataFromFile("bad_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (badResponseData, mockResponse, nil)

        // when
        whenClosureFetchWithUrlCompletesWithError()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(.failedDeserialization(type: String(describing: PokemonList.self)), receivedError)
    }

    func test_closureFetchFunction_withURL_completesWithDecodedData_whenDataMatchesTheModel() {
        // given
        givenExpectation(description: "Should receive error")
        let mockResponse = givenMockHTTPResponse(code: 200)
        let badResponseData = Bundle.getDataFromFile("correct_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (badResponseData, mockResponse, nil)
        var fetchedData: Any?

        // when
        sut.fetch(url: mockURL, decodingType: PokemonList.self) { [weak self] result in
            if case .success(let pokemonData) = result {
                fetchedData = pokemonData
                self?.globalExpectation.fulfill()
            }
        }

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertTrue((fetchedData as AnyObject) is PokemonList)
    }

    // MARK: - Async fetch with Endpoint

    func test_asyncFetch_withEndpoint_callsData_onSession() async {
        // when
        do {
            let _ = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
            XCTAssertTrue(mockSession.calledMethods.contains(.data))
        } catch {
            XCTAssertTrue(mockSession.calledMethods.contains(.data))
        }
    }

    func test_asynFetch_withEndpoint_sendsCorrectRequest_toSession() async {
        // given
        let mockRequest = givenRequest()

        // when
        do {
            let _ = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
            XCTAssertEqual(mockSession.receivedRequest, mockRequest)
        } catch {
            XCTAssertTrue(mockSession.calledMethods.contains(.data))
        }
    }

    func test_asyncFetch_withEndpoint_throwsInvalidResponse_whenResponseCantBeCasted_toHTTPURLResponse() async {
        // given
        let mockResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        do {
            let _ = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(getExpectedError(for: mockResponse), error as? APIError)
        }
    }

    func test_asyncFetch_withEndpoint_throwsRequestFailed_whenResponseCode_isNotBetween200And300() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        do {
            let _ = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(getExpectedError(for: mockResponse), error as? APIError)
        }
    }

    func test_asyncFetch_withEndpoint_throwsFailedDeserialization_ifResponseDataDoesntMatchModel() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        let wrongData = Bundle.getDataFromFile("bad_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (wrongData, mockResponse, nil)

        // when
        do {
            let _ = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(.failedDeserialization(type: String(describing: PokemonList.self)), error as? APIError)
        }
    }

    func test_asyncFetch_withEndpoint_returnsDecodedData_ifResponseDataMatchesmModel() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        let validData = Bundle.getDataFromFile("correct_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (validData, mockResponse, nil)

        // when
        do {
            let decodedData = try await sut.fetch(endpoint: PokeApiEndpoint.pokemonList(limit: 100), decodingType: PokemonList.self)

            // then
            XCTAssertNotNil(decodedData)
        } catch {
            XCTFail()
        }
    }

    // MARK: - Async fetch with URL

    func test_asyncFetch_withURL_callsData_onSession() async {
        // when
        do {
            let _ = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)
            XCTAssertTrue(mockSession.calledMethods.contains(.data))
        } catch {
            XCTAssertTrue(mockSession.calledMethods.contains(.data))
        }
    }

    func test_asyncFetch_withURL_sendsCorrectRequest_toSession() async {
        // given
        let request = givenRequest()

        // when
        do {
            let _ = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)

            // then
            XCTAssertEqual(mockSession.receivedRequest, request)
        } catch {
            XCTAssertEqual(mockSession.receivedRequest, request)
        }
    }

    func test_asyncFetch_withURL_throwsInvalidResponse_whenResponseCantBeCasted_toHTTPURLResponse() async {
        // given
        let mockResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        do {
            let _ = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)
            XCTFail()
        } catch {
            XCTAssertEqual(getExpectedError(for: mockResponse), error as? APIError)
        }
    }

    func test_asyncFetch_withURL_throwsRequestFialed_wheRequesCode_isntBetween200And300() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        do {
            let _ = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)
            XCTFail()
        } catch {
            XCTAssertEqual(getExpectedError(for: mockResponse), error as? APIError)
        }
    }

    func test_asyncFetch_withURL_throwsFailedDeserialization_ifResponseDataDoesntMatchModel() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        let incorrectData = Bundle.getDataFromFile("bad_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (incorrectData, mockResponse, nil)

        // when
        do {
            let _ = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)
            XCTFail()
        } catch {
            XCTAssertEqual(.failedDeserialization(type: String(describing: PokemonList.self)), error as? APIError)
        }
    }

    func test_asyncFetch_withURL_returnsDecodedData_ifResponseDataMatchesModel() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        let validData = Bundle.getDataFromFile("correct_pokemon_response", type: "json")
        mockSession.expectedCompletionValues = (validData, mockResponse, nil)

        // when
        do {
            let decodedData = try await sut.fetch(url: mockURL, decodingType: PokemonList.self)
        } catch {
            XCTFail()
        }
    }

    // MARK: - Closure post function with endpoint

    func test_closurePost_withEndpoint_callsDataTask_onSession() {
        // given
        let testProduct = givenTestProduct()

        // when
        sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: testProduct, completion: {_ in})

        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.dataTask))
    }

    func test_closurePost_withEndpoint_sendsCorrectRequest_toSession() {
        // given
        let testProduct = givenTestProduct()
        let request = givenRequest(method: .POST, body: testProduct)

        // when
        sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: testProduct, completion: {_ in})

        // then
        XCTAssertEqual(request.url, mockSession.receivedRequest?.url)
        XCTAssertEqual(request.httpMethod, mockSession.receivedRequest?.httpMethod)
        XCTAssertEqual(request.httpBody, mockSession.receivedRequest?.httpBody)
    }

    func test_closurePost_withEndpoint_sendsHeaders_ifSent_onFunction() {
        // given
        let testProduct = givenTestProduct()

        let testHeaders = [
            "Authorization": "Bearer Auth",
            "Some other": "1"
        ]

        // when
        sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: testProduct, headers: testHeaders, completion: { _ in})

        // then
        XCTAssertEqual(testHeaders, mockSession.receivedRequest?.allHTTPHeaderFields)
    }

    func test_closurePost_withEndpoint_completesWithUnknownError_whenResponseHasError() {
        // given
        let error = NSError(domain: "com.mxnetworking", code: 123)
        givenExpectation(description: "Should complete with error")
        mockSession.expectedCompletionValues = (nil, nil, error)

        // when
        whenClosurePostWithEndpointCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: error), receivedError)
    }

    func test_closurePost_completesWithInvalidResponse_whenResponceCantBeCasted_intoHTTPURLResponse() {
        // given
        let mockInvalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        givenExpectation(description: "Should complete with error")
        mockSession.expectedCompletionValues = (nil, mockInvalidResponse, nil)

        // when
        whenClosurePostWithEndpointCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockInvalidResponse), receivedError)
    }

    func test_closurePost_withEndpoint_completesWithRequestFailed_whenResponseCode_isntBetween200And300() {
        // given
        givenExpectation(description: "Should complete with error")
        let response = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, response, nil)

        // when
        whenClosurePostWithEndpointCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: response), receivedError)
    }

    func test_closurePost_withEndpoint_completesWithSuccess_whenResponseCode_isBetween200And300() {
        // given
        givenExpectation(description: "Should complete with no errors")
        let response = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, response, nil)

        // when
        whenClosurePostWithEndpointCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(receivedError)
    }

    // MARK: - Closure post with url

    func test_closurePost_withURL_callsDataTask_onSession() {
        // given
        let testProduct = givenTestProduct()
        
        // when
        sut.post(url: mockURL, body: testProduct, completion: {_ in})

        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.dataTask))
    }

    func test_closurePost_withURL_sendsCorrectRequest_toSession() {
        // given
        let testProduct = givenTestProduct()
        let request = givenRequest(method: .POST, body: testProduct)

        // when
        sut.post(url: mockURL, body: testProduct, completion: {_ in })

        // then
        XCTAssertEqual(request.url, mockSession.receivedRequest?.url)
        XCTAssertEqual(request.httpMethod, mockSession.receivedRequest?.httpMethod)
        XCTAssertEqual(request.httpBody, mockSession.receivedRequest?.httpBody)
    }

    func test_closurePost_withURL_setsHeadersOnRequest_whenTheyAreSent() {
        // given
        let mockHeaders = [
            "Authorization": "Bearer Auth",
            "Some": "1"
        ]

        // when
        sut.post(url: mockURL, body: givenTestProduct(), headers: mockHeaders, completion: { _ in})

        // then
        XCTAssertEqual(mockSession.receivedRequest?.allHTTPHeaderFields, mockHeaders)
    }

    func test_closurePost_withURL_completesWithUnknown_whenErrorIsReceived() {
        // given
        givenExpectation(description: "Should complete with unknown error")
        let mockError = NSError(domain: "com.mxnetworking", code: 123)
        mockSession.expectedCompletionValues = (nil, nil, mockError)

        // when
        whenClosurePostWithUrlCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockError), receivedError)
    }

    func test_closurePost_withURL_completesWithInvalidResponse_whenResponseCantBeCasted_toHTTPURLResponse() {
        // given
        let mockInvalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        givenExpectation(description: "Should complete with invalidResponse")
        mockSession.expectedCompletionValues = (nil, mockInvalidResponse, nil)

        // when
        whenClosurePostWithUrlCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockInvalidResponse), receivedError)
    }

    func test_closurePost_withURL_completesWithRequestFailed_ifResponseCode_isNotBetween200And300() {
        // given
        let mockResponse = givenMockHTTPResponse(code: 404)
        givenExpectation(description: "Should complete with requestFailed")
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosurePostWithUrlCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(getExpectedError(for: mockResponse), receivedError)
    }

    func test_closurePost_withURL_completesWithSuccess_whenResponseCode_isBetween200And300() {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        givenExpectation(description: "Should complete with success")
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        whenClosurePostWithUrlCompletes()

        // then
        waitForExpectations(timeout: 0.1)
        XCTAssertNil(receivedError)
    }

    // MARK: - Async post with endpoint

    func test_asyncPost_withEndpoint_callsData_onSession() async {
        // when
        do {
            try await sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct())
        } catch {
            print(error)
        }
    
        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.data))
    }

    func test_asyncPost_withEndpoint_sendCorrectRequest_toSession() async {
        // given
        let request = givenRequest(method: .POST, body: givenTestProduct())

        // when
        do {
            try await sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct())
        } catch {
            print(error)
        }

        // then
        XCTAssertEqual(request.url, mockSession.receivedRequest?.url)
        XCTAssertEqual(request.httpMethod, mockSession.receivedRequest?.httpMethod)
        XCTAssertEqual(request.httpBody, mockSession.receivedRequest?.httpBody)
    }

    func test_asyncPost_withEndpoint_setsHeaders_whenHeadersAreSent() async {
        // given
        let mockHeaders = [
            "Authorization": "bearer",
            "Some": "1"
        ]

        // when
        do {
            try await sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct(), headers: mockHeaders)
        } catch {
            print(error)
        }

        // then
        XCTAssertEqual(mockHeaders, mockSession.receivedRequest?.allHTTPHeaderFields)
    }

    func test_asyncPost_withEndpoint_throwsInvalidResponse_whenItCantBeCasted_toHTTPURLResponse() async {
        // given
        let mockInvalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, mockInvalidResponse, nil)

        // when
        await whenAsyncPostCompletesWithError()

        // then
        XCTAssertEqual(getExpectedError(for: mockInvalidResponse), receivedError)
    }

    func test_asyncPost_withEndpoint_throwsRequestFailed_whenResponseCode_isntBetween200And300() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        await whenAsyncPostCompletesWithError()

        // then
        XCTAssertEqual(getExpectedError(for: mockResponse), receivedError)
    }

    func test_asyncPost_withEndpoint_doesntThrow_whenResponseCode_isBetween200And300() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        do {
            try await sut.post(endpoint: PokeApiEndpoint.pokemonList(limit: 100), body: givenTestProduct())
        } catch {
            XCTFail()
        }
    }

    // MARK: - Async post with URL

    func test_asyncPost_withURL_callsData_onSession() async {
        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct())
        } catch {
            print(error)
        }

        // then
        XCTAssertTrue(mockSession.calledMethods.contains(.data))
    }

    func test_asyncPost_withURL_sendsCorrectRequest_toSession() async {
        // given
        let request = givenRequest(method: .POST, body: givenTestProduct())

        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct())
        } catch {
            print(error)
        }

        // then
        XCTAssertEqual(request.url, mockSession.receivedRequest?.url)
        XCTAssertEqual(request.httpMethod, mockSession.receivedRequest?.httpMethod)
        XCTAssertEqual(request.httpBody, mockSession.receivedRequest?.httpBody)
    }

    func test_asycPost_withURL_setsHeadersOnRequest_whenHeadersAreSent() async {
        // given
        let mockHeaders = [
            "Authorization": "Bearer",
            "Some": "1"
        ]

        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct(), headers: mockHeaders)
        } catch {
            print(error)
        }

        // then
        XCTAssertEqual(mockHeaders, mockSession.receivedRequest?.allHTTPHeaderFields)
    }

    func test_asyncPost_withURL_throwsInvalidResponse_whenResponseCantBeCasted_toHTTPURLResponse() async {
        // given
        let mockInvalidResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, mockInvalidResponse, nil)

        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct())
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(getExpectedError(for: mockInvalidResponse), error as? APIError)
        }
    }

    func test_asyncPost_withURL_throwsRequestFailed_whenResponseCode_isntBetween200And300() async {
        // given
        let mockResposne = givenMockHTTPResponse(code: 404)
        mockSession.expectedCompletionValues = (nil, mockResposne, nil)

        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct())
            XCTFail()
        } catch {
            // then
            XCTAssertEqual(getExpectedError(for: mockResposne), error as? APIError)
        }
    }

    func test_asyncPost_withURL_doesntThrow_whenResponseCode_isBetween200And300() async {
        // given
        let mockResponse = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, mockResponse, nil)

        // when
        do {
            try await sut.post(url: mockURL, body: givenTestProduct())
        } catch {
            XCTFail()
        }
    }

    func test_dataWithRequest_completesWithInvalidResponse_ifURLRequestCouldNotBeFormed() {
        // Given
        let mockRequest = Request(url: "")
        let expectation = expectation(description: "Should call completion handler")
        
        // When
        sut.data(for: mockRequest) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let failure):
                XCTAssertEqual(.invalidRequest, failure)
            }
            
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.1)
        
    }

    func test_dataWithRequest_completesWithUnknownError_ifRequestFails() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let expectedError = NSError(domain: "com.mxnetworking", code: 10)
        mockSession.expectedCompletionValues = (nil, nil, expectedError)
        
        // When
        sut.data(for: request) { result in
            
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let failure):
                XCTAssertEqual(failure, .unknown(description: expectedError.localizedDescription))
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_dataWithRequest_completesWithInvalidResponse_ifResponseCantBeParsedToHTTPOne() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let expectedResponse = URLResponse(url: URL(string: "Hola")!,
                                           mimeType: "application/json",
                                           expectedContentLength: 5151161,
                                           textEncodingName: "utf-8")
        
        mockSession.expectedCompletionValues = (nil, expectedResponse, nil)
        
        // When
        sut.data(for: request) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t cmplete with success")
            case .failure(let failure):
                XCTAssertEqual(self.getExpectedError(for: expectedResponse), failure)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataWithRequest_completesWithRequestFailed_ifResponseCodeIsNotInRange() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let expectedRespose = givenMockHTTPResponse(code: 400)
        mockSession.expectedCompletionValues = (nil, expectedRespose, nil)
        
        // When
        sut.data(for: request) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let failure):
                XCTAssertEqual(self.getExpectedError(for: expectedRespose), failure)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_dataWithRequest_completesWithUnknownError_ifDataIsNil() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let response = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (nil, response, nil)
        
        // When
        sut.data(for: request) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case let .failure(error):
                XCTAssertEqual(APIError.unknown(description: "No data recieved"), error)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_dataWithRequest_completesWithData() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let response = givenMockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (Data(), response, nil)
        
        // When
        sut.data(for: request) { result in
            // Then
            if case .failure = result {
                XCTFail("Shouldn´t complete with failure")
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
}
