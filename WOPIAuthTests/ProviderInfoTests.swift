
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

	private func CreateAlternateValidProviderInfo() -> ProviderInfo {
		let provider = ProviderInfo()
		provider.providerName = "Provider Name 2"
		provider.bootstrapper = "https://contoso2.com/wopibootstrapper"
		provider.clientId = "abc123$%^2"
		provider.clientSecret = "def9872!42"
		provider.redirectUrl = "https://localhost2"
		return provider
	}

	private func EncodeProvider(provider: ProviderInfo) -> NSData {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		
		// archive known object
		provider.encodeWithCoder(archiver)
		archiver.finishEncoding()
		return data
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

	func testValidProvider() {
		XCTAssertTrue(CreateValidProviderInfo().validate())
	}

	func testAlternateValidProvider() {
		XCTAssertTrue(CreateAlternateValidProviderInfo().validate())
	}

	func testProvidersNotEqual() {
		XCTAssertTrue(CreateValidProviderInfo() != CreateAlternateValidProviderInfo())
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
	
	func testProviderEncodeDecode() {
		let origProvider = CreateValidProviderInfo()
		let data = EncodeProvider(origProvider)

		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newProvider = ProviderInfo(coder: unarchiver)
		XCTAssertNotNil(newProvider)
		XCTAssertTrue(newProvider! == origProvider)
	}

	func testProviderDecodeFailInvalidVersion() {
		let origProvider = CreateValidProviderInfo()
		origProvider.providerInfoVersion = 99999
		let data = EncodeProvider(origProvider)

		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newProvider = ProviderInfo(coder: unarchiver)
		XCTAssertNil(newProvider)
	}

}
