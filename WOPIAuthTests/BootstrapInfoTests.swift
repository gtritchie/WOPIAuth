
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
	
}
