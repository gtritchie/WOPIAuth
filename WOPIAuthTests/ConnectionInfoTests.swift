
import XCTest
@testable import WOPIAuth

class ConnectionInfoTests: XCTestCase {
	
	private func CreateConnectionInfo() -> ConnectionInfo {
		let connection = ConnectionInfo()
		connection.providerName = "Provider Name"
		connection.userId = "12345abc"
		connection.userName = "User Name"
		connection.friendlyName = "Friendly Name"
		connection.postAuthTokenIssuanceURL = "https://contoso.com/auth"
		connection.sessionContext = "Session Context"
		connection.accessToken = "abc123$%^"
		connection.tokenExpiration = 60
		connection.refreshToken = "def567*()"
		connection.bootstrapInfo = BootstrapInfo()
		return connection
	}

	private func EncodeConnectionInfo(connection: ConnectionInfo) -> NSData {
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		
		// archive known object
		connection.encodeWithCoder(archiver)
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

	func testConnectionsEqual() {
		let a = CreateConnectionInfo()
		let b = CreateConnectionInfo()
		XCTAssertTrue(a == b)
	}

	func testConnectionsNotEqual() {
		XCTAssertFalse(CreateConnectionInfo() != CreateConnectionInfo())
	}

	func testConnectionDescriptionNotEmpty() {
		let connection = CreateConnectionInfo()
		XCTAssertFalse(connection.description.isEmpty)
	}

	func testConnectionInfoEncodeDecode() {
		let origConnection = CreateConnectionInfo()
		let data = EncodeConnectionInfo(origConnection)
		
		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newConnection = ConnectionInfo(coder: unarchiver)
		XCTAssertNotNil(newConnection)
		XCTAssertTrue(newConnection! == origConnection)
	}
	
	func testConnectionDecodeFailInvalidVersion() {
		let origConnection = CreateConnectionInfo()
		origConnection.connectionInfoVersion = 99999
		let data = EncodeConnectionInfo(origConnection)

		// create new object from the archive
		let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
		let newConnection = ConnectionInfo(coder: unarchiver)
		XCTAssertNil(newConnection)
	}
}
