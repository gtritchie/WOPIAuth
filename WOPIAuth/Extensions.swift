import Foundation

extension String
{
	private static var wwwFormURLPlusSpaceCharacterSet: NSCharacterSet = NSMutableCharacterSet.wwwFormURLPlusSpaceCharacterSet()
	
	/// Encodes a string to become x-www-form-urlencoded; the space is encoded as plus sign (+).
	var wwwFormURLEncodedString: String {
		let characterSet = String.wwwFormURLPlusSpaceCharacterSet
		return (stringByAddingPercentEncodingWithAllowedCharacters(characterSet) ?? "").stringByReplacingOccurrencesOfString(" ", withString: "+")
	}
	
	/// Decodes a percent-encoded string and converts the plus sign into a space.
	var wwwFormURLDecodedString: String {
		let rep = stringByReplacingOccurrencesOfString("+", withString: " ")
		return rep.stringByRemovingPercentEncoding ?? rep
	}
}

extension NSMutableCharacterSet
{
	/**
	Return the character set that does NOT need percent-encoding for x-www-form-urlencoded requests INCLUDING SPACE.
	YOU are responsible for replacing spaces " " with the plus sign "+".
	
	RFC3986 and the W3C spec are not entirely consistent, we're using W3C's spec which says:
	http://www.w3.org/TR/html5/forms.html#application/x-www-form-urlencoded-encoding-algorithm
	
	> If the byte is 0x20 (U+0020 SPACE if interpreted as ASCII):
	> - Replace the byte with a single 0x2B byte ("+" (U+002B) character if interpreted as ASCII).
	> If the byte is in the range 0x2A (*), 0x2D (-), 0x2E (.), 0x30 to 0x39 (0-9), 0x41 to 0x5A (A-Z), 0x5F (_),
	> 0x61 to 0x7A (a-z)
	> - Leave byte as-is
	*/
	class func wwwFormURLPlusSpaceCharacterSet() -> NSMutableCharacterSet {
		let set = NSMutableCharacterSet.alphanumericCharacterSet()
		set.addCharactersInString("-._* ")
		return set
	}
}

func formEncodedQueryStringFor(params: [String: String]) -> String {
	var arr: [String] = []
	for (key, val) in params {
		arr.append("\(key)=\(val.wwwFormURLEncodedString)")
	}
	return arr.joinWithSeparator("&")
}