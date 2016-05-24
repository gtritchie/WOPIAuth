import XCTest

@testable import WOPIAuth

private let userId = "234sdER"
private let signInName = "fred@smith.com"
private let friendlyName = "Fred Smith"

class ProfileResultTests: XCTestCase {

	
//	{
//	"EcosystemUrl": "https:\/\/app.box.com\/api\/wopi\/ecosystem?access_token=FiMvFlwrCeOANdmCdK8eTBexlmjplAzf",
//	"UserId": "257119441",
//	"SignInName": "eshi+office2@box.com",
//	"UserFriendlyName": "Office Test 2"
//	}

	private func noJSON() -> NSData {
		return NSData()
	}

	private func validJSON() -> NSData {
		let jsonItems = [
			"UserId": userId,
			"SignInName": signInName,
			"UserFriendlyName": friendlyName
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}
	
	private func emptyUserIdJSON() -> NSData {
		let jsonItems = [
			"UserId": "",
			"SignInName": signInName,
			"UserFriendlyName": friendlyName
		]
		do {
			return try NSJSONSerialization.dataWithJSONObject(jsonItems, options: NSJSONWritingOptions(rawValue: 0))
		} catch {
			XCTFail()
			return noJSON()
		}
	}
	
	
	private func noUserIdJSON() -> NSData {
		let jsonItems = [
			"SignInName": signInName,
			"UserFriendlyName": friendlyName
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
	

	func testValidProfileResponse() {
		do {
			let result = try ProfileResult.createFromResponse(validJSON(), response: validResponse(), error: nil)
			XCTAssertEqual(result.userId, userId)
			XCTAssertEqual(result.signInName, signInName)
			XCTAssertTrue(result.friendlyName == friendlyName)
		} catch {
			XCTFail()
		}
	}

	func testEmptyJSONProfileResponse() {
		do {
			try ProfileResult.createFromResponse(noJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}

	func testNoUserIdProfileResponse() {
		do {
			try ProfileResult.createFromResponse(noUserIdJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}


	func testEmptyUserIdResponse() {
		do {
			try ProfileResult.createFromResponse(emptyUserIdJSON(), response: validResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testNilProfileResponseDataNilError() {
		do {
			try ProfileResult.createFromResponse(nil, response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testNilProfileResponseDataWithError() {
		let error = NSError(domain: "test", code: 1, userInfo: nil)
		do {
			try ProfileResult.createFromResponse(nil, response: nil, error: error)
			XCTFail()
		} catch {
		}
	}
	
	func testNilTokenResponse() {
		do {
			try ProfileResult.createFromResponse(validJSON(), response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testNilTokenResponseWithEmptyData() {
		do {
			try ProfileResult.createFromResponse(noJSON(), response: nil, error: nil)
			XCTFail()
		} catch {
		}
	}
	
	func testInvalidResponseCode() {
		do {
			try ProfileResult.createFromResponse(noJSON(), response: invalidResponse(), error: nil)
			XCTFail()
		} catch {
		}
	}

}