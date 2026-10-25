//
//  IPv6CalculatorTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class IPv6CalculatorTests: XCTestCase {

    // MARK: - Calculation Tests

    func testIPv6Calculator_standardSubnet() throws {
        let result = try IPv6Calculator.calculate(address: IPv6Address(string: "2001:db8::1"), prefixLength: 48)
        
        XCTAssertEqual(result.networkPrefix.compressedString.lowercased(), "2001:db8::")
        XCTAssertEqual(result.firstAddress.expandedString.lowercased(), "2001:0db8:0000:0000:0000:0000:0000:0000")
        XCTAssertEqual(result.lastAddress.expandedString.lowercased(), "2001:0db8:0000:ffff:ffff:ffff:ffff:ffff")
        XCTAssertEqual(result.totalAddresses, "1208925819614629174706176")
    }
    
    func testIPv6Calculator_slash0() throws {
        let result = try IPv6Calculator.calculate(address: IPv6Address(string: "::"), prefixLength: 0)
        
        XCTAssertEqual(result.networkPrefix.compressedString, "::")
        // 2^128 as string
        XCTAssertEqual(result.totalAddresses, "340282366920938463463374607431768211456")
    }
    
    func testIPv6Calculator_slash128() throws {
        let result = try IPv6Calculator.calculate(address: IPv6Address(string: "::1"), prefixLength: 128)
        
        XCTAssertEqual(result.networkPrefix.compressedString, "::1")
        XCTAssertEqual(result.totalAddresses, "1")
    }
    
    func testIPv6Calculator_linkLocal() throws {
        let result = try IPv6Calculator.calculate(address: IPv6Address(string: "fe80::1"), prefixLength: 10)
        
        XCTAssertEqual(result.networkPrefix.compressedString.lowercased(), "fe80::")
    }

    // MARK: - String Parsing Tests
    
    func testIPv6Calculator_stringParsing() throws {
        let result = try IPv6Calculator.calculate(input: "2001:db8::1/48")
        
        XCTAssertEqual(result.networkPrefix.compressedString.lowercased(), "2001:db8::")
        XCTAssertEqual(result.prefixLength, 48)
    }
    
    // MARK: - Error Tests
    
    func testIPv6Calculator_invalidPrefix() {
        XCTAssertThrowsError(try IPv6Calculator.calculate(address: IPv6Address(string: "2001:db8::1"), prefixLength: 129)) { error in
            guard let netErr = error as? NetworkError else {
                XCTFail("Expected NetworkError")
                return
            }
            switch netErr {
            case .invalidCIDRPrefix, .prefixLengthOutOfRange: break
            default: XCTFail("Expected invalidCIDRPrefix or prefixLengthOutOfRange, got \(netErr)")
            }
        }
    }
}
