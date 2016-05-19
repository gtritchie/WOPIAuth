
import XCTest
@testable import WOPIAuth

class BootstrapInfoTests: XCTestCase {
	
	private func CreateBootstrapInfo() -> BootstrapInfo {
		let bootstrap = BootstrapInfo()
		bootstrap.authorizationURL = "https://contoso.com/auth"
		bootstrap.tokenIssuanceURL = "https://contoso.com/token"
		return bootstrap
	}
	
	private func EncodeBootstrapInfo(bootstrap: BootstrapInfo) -> NSData {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		
		// archive known object
		bootstrap.encodeWithCoder(archiver)
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
	
	func testBootstrapEqual() {
		let a = CreateBootstrapInfo()
		let b = CreateBootstrapInfo()
		XCTAssertTrue(a == b)
	}
	
	func testBootstrapNotEqual() {
		let a = CreateBootstrapInfo()
		let b = CreateBootstrapInfo()
		XCTAssertFalse(a != b)
	}
	
	func testBootstrapDescriptionNotEmpty() {
		let bootstrap = CreateBootstrapInfo()
		XCTAssertFalse(bootstrap.description.isEmpty)
	}
	
	func testBootstrapInfoEncodeDecode() {
		let origBootstrap = CreateBootstrapInfo()
		let data = EncodeBootstrapInfo(origBootstrap)
		
		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newBootstrap = BootstrapInfo(coder: unarchiver)
		XCTAssertNotNil(newBootstrap)
		XCTAssertTrue(newBootstrap! == origBootstrap)
	}
	
	func testBootstrapDecodeFailInvalidVersion() {
		let origBootstrap = CreateBootstrapInfo()
		origBootstrap.bootstrapInfoVersion = 99999
		let data = EncodeBootstrapInfo(origBootstrap)
		
		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newBootstrap = BootstrapInfo(coder: unarchiver)
		XCTAssertNil(newBootstrap)
	}
	
	func testValidAuthHeaderParse() {
		let bootstrap = BootstrapInfo()
		
		XCTAssertTrue(bootstrap.populateFromAuthenticateHeader("Bearer authorization_uri=\"https://contoso.com/auth\",tokenIssuance_uri=\"https://contoso.com/token\""))
	}
	
	func testAuthHeaderMissingAuthUri() {
		let bootstrap = BootstrapInfo()
		
		XCTAssertFalse(bootstrap.populateFromAuthenticateHeader("Bearer tokenIssuance_uri=\"https://contoso.com/token\""))
	}

	func testAuthHeaderMissingTokenUri() {
		let bootstrap = BootstrapInfo()
		
		XCTAssertFalse(bootstrap.populateFromAuthenticateHeader("Bearer authorization_uri=\"https://contoso.com/auth\""))
	}
	
	func testBootstrapInitFromAnother() {
		let bootstrap = CreateBootstrapInfo()
		let newBootstrap = BootstrapInfo(instance: bootstrap)
		XCTAssertTrue(bootstrap == newBootstrap)
	}
	
	func testBootstrapValidateValidObject() {
		let bootstrap = CreateBootstrapInfo()
		XCTAssertTrue(bootstrap.nonThrowValidate())
	}
	
	func testBootstrapValidateInvalidObjectNonHttpsAuthURL() {
		let bootstrap = CreateBootstrapInfo()
		bootstrap.authorizationURL = "http://foo.com/auth" // needs to be HTTPS
		XCTAssertFalse(bootstrap.nonThrowValidate())
	}

	func testBootstrapValidateInvalidObjectNonHttpsTokenURL() {
		let bootstrap = CreateBootstrapInfo()
		bootstrap.tokenIssuanceURL = "http://foo.com/auth" // needs to be HTTPS
		XCTAssertFalse(bootstrap.nonThrowValidate())
	}

	func testBootstrapValidateInvalidObjectEmptyTokenURL() {
		let bootstrap = CreateBootstrapInfo()
		bootstrap.tokenIssuanceURL = ""
		XCTAssertFalse(bootstrap.nonThrowValidate())
	}

	func testBootstrapValidateInvalidObjectEmptyAuthURL() {
		let bootstrap = CreateBootstrapInfo()
		bootstrap.authorizationURL = ""
		XCTAssertFalse(bootstrap.nonThrowValidate())
	}
	
	func testBootstrapValidateAuthURLViaKVCSuccess() {
		let bootstrap = CreateBootstrapInfo()
		do {
			var str: NSString? = bootstrap.authorizationURL as NSString?
			let authURLStringPointer = AutoreleasingUnsafeMutablePointer<NSString?>(&str)
			try bootstrap.validateAuthorizationURL(authURLStringPointer)
			XCTAssertTrue(true)
		} catch {
			XCTAssertTrue(false)
		}
	}

	func testBootstrapValidateAuthURLViaKVCFailure() {
		let bootstrap = CreateBootstrapInfo()
		do {
			bootstrap.authorizationURL = "not an https url"
			var str: NSString? = bootstrap.authorizationURL as NSString?
			let authURLStringPointer = AutoreleasingUnsafeMutablePointer<NSString?>(&str)
			try bootstrap.validateAuthorizationURL(authURLStringPointer)
			XCTAssertTrue(false)
		} catch {
			XCTAssertTrue(true)
		}
	}

	func testBootstrapValidateTokenURLViaKVCSuccess() {
		let bootstrap = CreateBootstrapInfo()
		do {
			var str: NSString? = bootstrap.tokenIssuanceURL as NSString?
			let tokenURLStringPointer = AutoreleasingUnsafeMutablePointer<NSString?>(&str)
			try bootstrap.validateTokenIssuanceURL(tokenURLStringPointer)
			XCTAssertTrue(true)
		} catch {
			XCTAssertTrue(false)
		}
	}
	
	func testBootstrapValidateTokenURLViaKVCFailure() {
		let bootstrap = CreateBootstrapInfo()
		do {
			bootstrap.tokenIssuanceURL = "not an https url"
			var str: NSString? = bootstrap.tokenIssuanceURL as NSString?
			let tokenURLStringPointer = AutoreleasingUnsafeMutablePointer<NSString?>(&str)
			try bootstrap.validateTokenIssuanceURL(tokenURLStringPointer)
			XCTAssertTrue(false)
		} catch {
			XCTAssertTrue(true)
		}
	}
}
