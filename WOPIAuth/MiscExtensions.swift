import Foundation

func formEncodedQueryStringFor(params: [String: String]) -> String {
	var arr: [String] = []
	for (key, val) in params {
		arr.append("\(key)=\(val.wwwFormURLEncodedString)")
	}
	return arr.joinWithSeparator("&")
}

func unwrapStringReplaceNilWithEmpty(str: String?) -> String {
	guard let val = str else {
		return ""
	}
	return val
}