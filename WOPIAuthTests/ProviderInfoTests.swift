
import XCTest
@testable import WOPIAuth

class ProviderInfoTests: XCTestCase {
	
	private func CreateValidProviderInfo() -> ProviderInfo {
		let provider = ProviderInfo()
		provider.providerName = "Provider Name"
		provider.bootstrapper = "https://contoso.com/wopibootstrapper"
		provider.clientId = "abc123$%^"
		provider.clientSecret = "def9872!4"
		provider.redirectUrl = "https://localhost"
		return provider
	}
	
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testDefaultObjectNotValid() {
		let provider = ProviderInfo()
		
		XCTAssertFalse(provider.validate())
		XCTAssertFalse(provider.validateNonEmpty())
	}
	
	func testTrimmedObjectIsEmpty() {
		let provider = ProviderInfo()
		provider.providerName = "    "
		provider.bootstrapper = "  "
		provider.clientId = "\t\n  "
		provider.clientSecret = "  \r\n\t"
		provider.redirectUrl = " "
		XCTAssertTrue(provider.validateNonEmpty())
		provider.trimSpaces()
		XCTAssertFalse(provider.validateNonEmpty())
	}
	
	func testEmptyProviderNameIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.providerName = ""
		XCTAssertFalse(provider.validateNonEmpty())
	}

	func testEmptyBootstrapperIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = ""
		XCTAssertFalse(provider.validateNonEmpty())
	}

	func testEmptyClientIdIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.clientId = ""
		XCTAssertFalse(provider.validateNonEmpty())
	}

	func testEmptyClientSecretIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.clientSecret = ""
		XCTAssertFalse(provider.validateNonEmpty())
	}
	
	func testEmptyRedirectUriIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = ""
		XCTAssertFalse(provider.validateNonEmpty())
	}

	func testValidObjectIsValid() {
		let provider = CreateValidProviderInfo()
		XCTAssertTrue(provider.validate())
	}
	
	func testBootstrapperUrlNotHTTPSFails() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = "http://contoso.com/wopibootstrapper"
		XCTAssertFalse(provider.validate())
	}

	func testBootstrapperUrlNotEndingWopiBootstrapperFails() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = "https://contoso.com"
		XCTAssertFalse(provider.validate())
		provider.bootstrapper = "https://contoso.com/wopi"
		XCTAssertFalse(provider.validate())
	}

	func testBootstrapperUrlNotValidUrlFails() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = "one two three@34"
		XCTAssertFalse(provider.validate())
	}

	func testRedirectUrlNotHTTPSFails() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = "http://localhost"
		XCTAssertFalse(provider.validate())
	}

	func testRedirectUrlNotValidUrlFails() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = "one two three@34"
		XCTAssertFalse(provider.validate())
	}

	func testProviderDescriptionNotEmpty() {
		let provider = CreateValidProviderInfo()
		XCTAssertFalse(provider.description.isEmpty)
	}
	
//	/// The Provider Name. For display purposes only, and treated as a unique key in this application.
//	dynamic var providerName: String = ""
//	let providerNameKey = "providerName"
//	
//	/// The WOPI bootstrap endpoint URL. This is treated as the primary unique key.
//	dynamic var bootstrapper: String = ""
//	let bootstrapperKey = "bootstrapper"
//	
//	/// The OAuth2 Client ID issued by the provider for Microsoft Office.
//	dynamic var clientId: String = ""
//	let clientIdKey = "clientId"
//	
//	/// The OAuth2 Client Secret issued by the provider for Microsoft Office.
//	dynamic var clientSecret: String = ""
//	let clientSecretKey = "clientSecret"
//	
//	/**
//	The redirect URL used to indicate that authorization has completed and
//	is returning an authorization_code via the code URL parameter.
//	*/
//	dynamic var redirectUrl: String = ""
//	let redirectUrlKey = "redirectUrl"
//	
//	/// Summary of `ProviderInfo` suitable for logging
//	override var description: String {
//		get {
//			return "[providerName=\"\(providerName)\", bootstrapper=\"\(bootstrapper)\", clientId=\"\(clientId)\", clientSecret=\"***\", redirectUrl=\"\(redirectUrl)\"]"
//		}
//	}

	
	
//	func testPerformanceExample() {
//		// This is an example of a performance test case.
//		self.measureBlock {
//			// Put the code you want to measure the time of here.
//		}
//	}
	
}
