
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
		XCTAssertTrue(CreateBootstrapInfo() == CreateBootstrapInfo())
	}
	
	func testBootstrapNotEqual() {
		XCTAssertFalse(CreateBootstrapInfo() != CreateBootstrapInfo())
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
		XCTAssertTrue(newBootstrap != origBootstrap)
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

	
//	func populateFromAuthenticateHeader(header: String) -> Bool {
//		
//		WOPIAuthLogInfo("WWW-Authenticate: \(header)")
//		
//		// Replace all "Bearer" with nothing; this is dubious but is what Office clients are doing
//		var trimHeader = header.stringByReplacingOccurrencesOfString("Bearer", withString: "")
//		trimHeader = trimHeader.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//		
//		let separators = NSCharacterSet(charactersInString: "=,")
//		let tokens: [String] = trimHeader.componentsSeparatedByCharactersInSet(separators)
//		
//		var nameValue = [String: String]()
//		
//		// TODO: I'm pretty sure there's a much tidier way to do all of this
//		var lastKey = ""
//		for (index, token) in tokens.enumerate() {
//			var trimmedToken = token.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//			trimmedToken = trimmedToken.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\""))
//			
//			if index % 2 == 0 {
//				lastKey = trimmedToken
//				nameValue[trimmedToken] = ""
//			} else {
//				nameValue[lastKey] = trimmedToken
//			}
//		}
//		
//		guard let authUri = nameValue["authorization_uri"] else {
//			WOPIAuthLogError("No authorization_uri in WWW-Authenticated header")
//			return false
//		}
//		guard let tokenUri = nameValue["tokenIssuance_uri"] else {
//			WOPIAuthLogError("No tokenIssuance_uri in WWW-Authenticated header")
//			return false
//		}
//		
//		authorizationURL = authUri
//		tokenIssuanceURL = tokenUri
//		
//		return true
//	}
	
}
