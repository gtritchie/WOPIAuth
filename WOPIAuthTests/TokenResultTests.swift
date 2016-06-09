import XCTest

@testable import WOPIAuth

private let accessTokenValue = "accessTokenValue"
private let refreshTokenValue = "refresh Token Value"
private let expirationValue: Int32 = 123456
private let expirationValueObject: NSNumber = NSNumber(int: expirationValue)

class TokenResultTests: XCTestCase {

	private func noJSON() -> NSData {
		return NSData()
	}
	
	private func validJSON() -> NSData {
		let jsonItems = [
			"random_stuff": "zoom",
			"access_token": accessTokenValue,
			"expires_in": expirationValueObject,
			"more_random_stuff": "bam",
			"refresh_token": refreshTokenValue,
			"token_type" : "bearer",
			"trailing": "0"
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}

	
	private func noTokenTypeJSON() -> NSData {
		let jsonItems = [
			"random_stuff": "zoom",
			"access_token": accessTokenValue,
			"expires_in": expirationValueObject,
			"more_random_stuff": "bam",
			"refresh_token": refreshTokenValue,
			"trailing": "0"
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}

	private func emptyAccessTokenJSON() -> NSData {
		let jsonItems = [
			"random_stuff": "zoom",
			"access_token": "",
			"expires_in": expirationValueObject,
			"more_random_stuff": "bam",
			"refresh_token": refreshTokenValue,
			"trailing": "0"
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}
	
	private func noAccessTokenJSON() -> NSData {
		let jsonItems = [
			"random_stuff": "zoom",
			"expires_in": expirationValueObject,
			"more_random_stuff": "bam",
			"refresh_token": refreshTokenValue,
			"trailing": "0"
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}
	
	private func validResponse() -> NSHTTPURLResponse {
		return NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: "HTTP/1.1", headerFields: nil)!
	}

	private func invalidResponse() -> NSHTTPURLResponse {
		return NSHTTPURLResponse(URL: NSURL(), statusCode: 500, HTTPVersion: "HTTP/1.1", headerFields: nil)!
	}
	
	func testValidTokenResponse() {
		do {
			let result = try TokenResult.createFromResponse(validJSON(), response: validResponse(), error: nil)
			XCTAssertEqual(result.accessToken, accessTokenValue)
			XCTAssertEqual(result.refreshToken, refreshTokenValue)
			XCTAssertTrue(result.tokenExpiration == expirationValue)
		} catch {
			XCTFail()
		}
	}

	func testEmptyJSONTokenResponse() {
		do {
			try TokenResult.createFromResponse(noJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testNoAccessTokenJSONTokenResponse() {
		do {
			try TokenResult.createFromResponse(noAccessTokenJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testEmptyTokenResponse() {
		do {
			try TokenResult.createFromResponse(emptyAccessTokenJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}

	func testNilTokenResponseDataNilError() {
		do {
			try TokenResult.createFromResponse(nil, response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}

	func testNilTokenResponseDataWithError() {
		let error = NSError(domain: "test", code: 1, userInfo: nil)
		do {
			try TokenResult.createFromResponse(nil, response: nil, error: error)
			XCTFail()
		} catch {
		}
	}

	func testNilTokenResponse() {
		do {
			try TokenResult.createFromResponse(validJSON(), response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}

	func testNilTokenResponseWithEmptyData() {
		do {
			try TokenResult.createFromResponse(noJSON(), response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}

	func testInvalidResponseCode() {
		do {
			try TokenResult.createFromResponse(noJSON(), response: invalidResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testMissingTokenType() {
		do {
			try TokenResult.createFromResponse(noTokenTypeJSON(), response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}

}
