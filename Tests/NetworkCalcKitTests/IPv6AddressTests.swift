//
//  IPv6AddressTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class IPv6AddressTests: XCTestCase {

    // MARK: - Parsing Tests

    func testIPv6_parseExpanded() throws {
        let ip = try IPv6Address(string: "2001:0db8:0000:0000:0000:0000:0000:0001")
        XCTAssertEqual(ip.groups, [0x2001, 0x0db8, 0, 0, 0, 0, 0, 0x0001])
    }
    
    func testIPv6_parseCompressed() throws {
        let ip = try IPv6Address(string: "2001:db8::1")
        XCTAssertEqual(ip.groups, [0x2001, 0x0db8, 0, 0, 0, 0, 0, 0x0001])
    }
    
    func testIPv6_parseAllZeros() throws {
        let ip = try IPv6Address(string: "::")
        XCTAssertEqual(ip.groups, [0, 0, 0, 0, 0, 0, 0, 0])
    }
    
    func testIPv6_parseLocalhost() throws {
        let ip = try IPv6Address(string: "::1")
        XCTAssertEqual(ip.groups, [0, 0, 0, 0, 0, 0, 0, 1])
    }
    
    func testIPv6_parseLinkLocal() throws {
        let ip = try IPv6Address(string: "fe80::1")
        XCTAssertEqual(ip.groups, [0xfe80, 0, 0, 0, 0, 0, 0, 1])
    }
    
    func testIPv6_parseMulticast() throws {
        let ip = try IPv6Address(string: "ff02::1:2")
        XCTAssertEqual(ip.groups, [0xff02, 0, 0, 0, 0, 0, 1, 2])
    }
    
    func testIPv6_invalidParsing() {
        let invalidStrings = [
            "xyz",
            "1:2:3:4:5:6:7:8:9", // Too many groups
            "2001:db8::g1" // Invalid hex
        ]
        
        for string in invalidStrings {
            XCTAssertThrowsError(try IPv6Address(string: string)) { error in
                guard case .invalidIPv6Address = error as? NetworkError else {
                    XCTFail("Expected invalidIPv6Address error, got \(error)")
                    return
                }
            }
        }
    }
    
    // MARK: - Formatting Tests
    
    func testIPv6_expandedString() throws {
        let ip = try IPv6Address(string: "2001:db8::1")
        XCTAssertEqual(ip.expandedString.lowercased(), "2001:0db8:0000:0000:0000:0000:0000:0001")
    }
    
    func testIPv6_compressedString() throws {
        let ip1 = try IPv6Address(groups: [0x2001, 0x0db8, 0, 0, 0, 0, 0, 0x0001])
        XCTAssertEqual(ip1.compressedString.lowercased(), "2001:db8::1")
        
        let ip2 = try IPv6Address(groups: [0, 0, 0, 0, 0, 0, 0, 0])
        XCTAssertEqual(ip2.compressedString, "::")
        
        let ip3 = try IPv6Address(groups: [0xfe80, 0, 0, 0, 0, 0, 0, 1])
        XCTAssertEqual(ip3.compressedString.lowercased(), "fe80::1")
    }

    // MARK: - Equality Tests
    
    func testIPv6_equality() throws {
        let ip1 = try IPv6Address(groups: [0x2001, 0x0db8, 0, 0, 0, 0, 0, 0x0001])
        let ip2 = try! IPv6Address(string: "2001:db8::1")
        let ip3 = try! IPv6Address(string: "2001:db8::2")
        
        XCTAssertEqual(ip1, ip2)
        XCTAssertNotEqual(ip1, ip3)
    }
    
    // MARK: - Codable Tests
    
    func testIPv6_codableRoundtrip() throws {
        let ip = try IPv6Address(string: "2001:db8::1")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(ip)
        let decodedIP = try decoder.decode(IPv6Address.self, from: data)
        
        XCTAssertEqual(ip, decodedIP)
    }
}
