//
//  MxRequestNetworkerTests.swift
//  MxNetworkingTests
//
//  Created by Uriel Hernandez Gonzalez on 14/08/24.
//

@testable import MxNetworking
import XCTest

final class MxRequestNetworkerTests: XCTestCase {

    var sut: MxRequestNetworker!
    var mockSession: MockUrlSession!
    
    override func setUp() {
        super.setUp()
        mockSession = MockUrlSession()
        sut = MxRequestNetworker(session: mockSession)
    }

    override func tearDown() {
        mockSession = nil
        sut = nil
        super.tearDown()
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
                XCTAssertEqual(ExpectedError(for: expectedResponse), failure)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_dataWithRequest_completesWithRequestFailed_ifResponseCodeIsNotInRange() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let expectedRespose = MockHTTPResponse(code: 400)
        mockSession.expectedCompletionValues = (nil, expectedRespose, nil)
        
        // When
        sut.data(for: request) { result in
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let failure):
                XCTAssertEqual(ExpectedError(for: expectedRespose), failure)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_dataWithRequest_completesWithUnknownError_ifDataIsNil() {
        // Given
        let request = Request(url: "www.google.com")
        let expectation = expectation(description: "Should call completion handler")
        let response = MockHTTPResponse(code: 200)
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
        let response = MockHTTPResponse(code: 200)
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

    func test_asyncDataWithRequest_throwsInvalidRequest_ifURLRequestCouldNotBeFormed() async {
        // Given
        let request = Request(url: "")
        
        // When
        do {
            _ = try await sut.data(for: request)
            XCTFail("Shouldn´t complete with success")
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail("Should have thrown APIError")
                return
            }
            
            // Then
            XCTAssertEqual(apiError, .invalidRequest)
        }
    }

    func test_asyncDataWithRequest_throwsInvalidResponse_ifResponseCanNotBeCastedToHTTPResponse() async {
        // Given
        let request = Request(url: "www.google.com")
        let badResponse = URLResponse(url: URL(string: "Hola")!, mimeType: "application/json", expectedContentLength: 5151161, textEncodingName: "utf-8")
        mockSession.expectedCompletionValues = (nil, badResponse, nil)
        
        // When
        do {
            _ = try await sut.data(for: request)
            XCTFail("Shouldn´t complete with success")
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail("Should have thrown APIError")
                return
            }
            
            XCTAssertEqual(ExpectedError(for: badResponse), apiError)
        }
    }

    func test_asyncDataWithRequest_throwsRequestFailed_ifResponseCodeIsNotInRange() async {
        // Given
        let request = Request(url: "www.google.com")
        let badResponse = MockHTTPResponse(code: 400)
        mockSession.expectedCompletionValues = (nil, badResponse, nil)
        
        // When
        do {
            _ = try await sut.data(for: request)
            XCTFail("Shouldn´t complete with success")
        } catch {
            guard let apiError = error as? APIError else {
                XCTFail("Should have thrown APIError")
                return
            }
            
            XCTAssertEqual(ExpectedError(for: badResponse), apiError)
        }
    }

    func test_asyncDataWithRequest_completesWithData() async throws {
        // Given
        let request = Request(url: "www.google.com")
        let response = MockHTTPResponse(code: 200)
        mockSession.expectedCompletionValues = (Data(), response, nil)
        
        // When
        _ = try await sut.data(for: request)
    }

    func test_modelWithRequest_completesWithInvalidRequest_ifURLRequestCanNotBeFormed() {
        // Given
        let request = Request(url: "")
        let expectation = expectation(description: "Should call completion handler")
        
        // When
        sut.model(from: request) { (result: Result<MockModel, APIError>) in
            
            // Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidRequest)
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

    func test_modelWithRequest_completesWithUnkownError_ifErrorIsRecieved() {
        // Given
        let request = Request(url: "www.google.com")
        let mockError = NSError(domain: "com.mxnetworker", code: 10)
        let expectation = expectation(description: "Should call completion handler")
        mockSession.expectedCompletionValues = (nil, nil, mockError)
        
        // When
        sut.model(from: request) { (result: Result<MockModel, APIError>) in
            //Then
            switch result {
            case .success:
                XCTFail("Shouldn´t complete with success")
            case .failure(let failure):
                XCTAssertEqual(ExpectedError(for: mockError), .unknown(description: String(describing: mockError)))
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.1)
    }

}