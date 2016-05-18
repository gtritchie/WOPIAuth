
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
		provider.scope = ""
		return provider
	}

	private func CreateAlternateValidProviderInfo() -> ProviderInfo {
		let provider = ProviderInfo()
		provider.providerName = "Provider Name 2"
		provider.bootstrapper = "https://contoso2.com/wopibootstrapper/"
		provider.clientId = "abc123$%^2"
		provider.clientSecret = "def9872!42"
		provider.redirectUrl = "https://localhost2"
		provider.scope = "sample scope"
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
		
		XCTAssertFalse(provider.nonThrowValidate())
	}
	
	func testTrimmedObjectIsEmpty() {
		let provider = ProviderInfo()
		provider.providerName = "    "
		provider.bootstrapper = "  "
		provider.clientId = "\t\n  "
		provider.clientSecret = "  \r\n\t"
		provider.redirectUrl = " "
		provider.trimSpaces()
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testValidProvider() {
		XCTAssertTrue(CreateValidProviderInfo().nonThrowValidate())
	}

	func testAlternateValidProvider() {
		XCTAssertTrue(CreateAlternateValidProviderInfo().nonThrowValidate())
	}

	func testProvidersNotEqual() {
		XCTAssertTrue(CreateValidProviderInfo() != CreateAlternateValidProviderInfo())
	}

	func testEmptyProviderNameIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.providerName = ""
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testEmptyBootstrapperIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = ""
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testEmptyClientIdIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.clientId = ""
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testEmptyClientSecretIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.clientSecret = ""
		XCTAssertFalse(provider.nonThrowValidate())
	}
	
	func testEmptyRedirectUriIsInvalid() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = ""
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testValidObjectIsValid() {
		let provider = CreateValidProviderInfo()
		XCTAssertTrue(provider.nonThrowValidate())
	}
	
	func testBootstrapperUrlNotHTTPSFails() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = "http://contoso.com/wopibootstrapper"
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testBootstrapperUrlNotValidUrlFails() {
		let provider = CreateValidProviderInfo()
		provider.bootstrapper = "one two three@34"
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testRedirectUrlNotHTTPSFails() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = "http://localhost"
		XCTAssertFalse(provider.nonThrowValidate())
	}

	func testRedirectUrlNotValidUrlFails() {
		let provider = CreateValidProviderInfo()
		provider.redirectUrl = "one two three@34"
		XCTAssertFalse(provider.nonThrowValidate())
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
	
	func testProviderCopyMatches() {
		let origProvider = CreateValidProviderInfo()
		let otherProvider = ProviderInfo(instance: origProvider)
		XCTAssertTrue(origProvider == otherProvider)
	}
	
	func testProviderCopyIsSeparateInstance() {
		let origProvider = CreateValidProviderInfo()
		let otherProvider = ProviderInfo(instance: origProvider)
		XCTAssertTrue(origProvider == otherProvider)
		
		otherProvider.bootstrapper = "this is something different"
		XCTAssertTrue(origProvider != otherProvider)
	}
}
