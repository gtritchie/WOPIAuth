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
			"trailing": "0"
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTAssertFalse(true)
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
			XCTAssertFalse(true)
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
			XCTAssertFalse(true)
			return noJSON()
		}
	}

	func testEmptyJSONTokenResult() {
		XCTAssertFalse(TokenResult().populateFromResponseData(noJSON()))
	}
	
	func testNoAccessTokenJSONTokenResult() {
		XCTAssertFalse(TokenResult().populateFromResponseData(noAccessTokenJSON()))
	}

	func testValidTokenResult() {
		let tokenResult = TokenResult()
		tokenResult.populateFromResponseData(validJSON())

		XCTAssertTrue(tokenResult.populateFromResponseData(validJSON()))
		XCTAssertEqual(tokenResult.accessToken, accessTokenValue)
		XCTAssertEqual(tokenResult.refreshToken, refreshTokenValue)
		XCTAssertTrue(tokenResult.tokenExpiration == expirationValue)
	}
	
	func testEmptyTokenResult() {
		let tokenResult = TokenResult()
		XCTAssertFalse(tokenResult.populateFromResponseData(emptyAccessTokenJSON()))
	}

}
