//
//  IPv4CalculatorTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class IPv4CalculatorTests: XCTestCase {

    // MARK: - Calculation Tests

    func testIPv4Calculator_standardSubnet() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(192, 168, 1, 10), prefixLength: 24)
        
        XCTAssertEqual(result.networkAddress.description, "192.168.1.0")
        XCTAssertEqual(result.broadcastAddress.description, "192.168.1.255")
        XCTAssertEqual(result.subnetMask.description, "255.255.255.0")
        XCTAssertEqual(result.wildcardMask.description, "0.0.0.255")
        XCTAssertEqual(result.firstUsableHost?.description, "192.168.1.1")
        XCTAssertEqual(result.lastUsableHost?.description, "192.168.1.254")
        XCTAssertEqual(result.totalAddresses, 256)
        XCTAssertEqual(result.usableHosts, 254)
        XCTAssertEqual(result.addressClass, .C)
        XCTAssertTrue(result.addressTypes.contains(.`private`))
    }
    
    func testIPv4Calculator_slash8() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(10, 0, 0, 0), prefixLength: 8)
        
        XCTAssertEqual(result.networkAddress.description, "10.0.0.0")
        XCTAssertEqual(result.broadcastAddress.description, "10.255.255.255")
        XCTAssertEqual(result.totalAddresses, 16777216)
        XCTAssertEqual(result.usableHosts, 16777214)
    }
    
    func testIPv4Calculator_slash12() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(172, 16, 0, 0), prefixLength: 12)
        
        XCTAssertEqual(result.networkAddress.description, "172.16.0.0")
        XCTAssertEqual(result.broadcastAddress.description, "172.31.255.255")
    }
    
    func testIPv4Calculator_slash32() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(192, 168, 1, 1), prefixLength: 32)
        
        XCTAssertEqual(result.networkAddress.description, "192.168.1.1")
        XCTAssertEqual(result.broadcastAddress.description, "192.168.1.1")
        XCTAssertEqual(result.totalAddresses, 1)
        XCTAssertEqual(result.usableHosts, 0)
        XCTAssertNil(result.firstUsableHost)
        XCTAssertNil(result.lastUsableHost)
    }
    
    func testIPv4Calculator_slash31() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(192, 168, 1, 0), prefixLength: 31)
        
        XCTAssertEqual(result.networkAddress.description, "192.168.1.0")
        XCTAssertEqual(result.broadcastAddress.description, "192.168.1.1")
        XCTAssertEqual(result.totalAddresses, 2)
        XCTAssertEqual(result.usableHosts, 2)
        XCTAssertEqual(result.firstUsableHost?.description, "192.168.1.0")
        XCTAssertEqual(result.lastUsableHost?.description, "192.168.1.1")
    }
    
    func testIPv4Calculator_slash0() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(0, 0, 0, 0), prefixLength: 0)
        
        XCTAssertEqual(result.networkAddress.description, "0.0.0.0")
        XCTAssertEqual(result.broadcastAddress.description, "255.255.255.255")
        XCTAssertEqual(result.totalAddresses, 4294967296)
        XCTAssertEqual(result.usableHosts, 4294967294)
    }
    
    func testIPv4Calculator_slash30() throws {
        let result = try IPv4Calculator.calculate(ip: IPv4Address(10, 1, 1, 0), prefixLength: 30)
        
        XCTAssertEqual(result.networkAddress.description, "10.1.1.0")
        XCTAssertEqual(result.broadcastAddress.description, "10.1.1.3")
        XCTAssertEqual(result.firstUsableHost?.description, "10.1.1.1")
        XCTAssertEqual(result.lastUsableHost?.description, "10.1.1.2")
        XCTAssertEqual(result.totalAddresses, 4)
        XCTAssertEqual(result.usableHosts, 2)
    }
    
    func testIPv4Calculator_hostBitsSet() throws {
        // IP with host bits set should compute same network address as the zeroed version
        let result = try IPv4Calculator.calculate(ip: IPv4Address(192, 168, 1, 10), prefixLength: 24)
        XCTAssertEqual(result.networkAddress.description, "192.168.1.0")
    }

    // MARK: - String Parsing Tests
    
    func testIPv4Calculator_stringParsing() throws {
        let result1 = try IPv4Calculator.calculate(input: "192.168.1.10/24")
        XCTAssertEqual(result1.networkAddress.description, "192.168.1.0")
        XCTAssertEqual(result1.prefixLength, 24)
        
        let result2 = try IPv4Calculator.calculate(input: "10.0.0.0 255.0.0.0")
        XCTAssertEqual(result2.networkAddress.description, "10.0.0.0")
        XCTAssertEqual(result2.prefixLength, 8)
    }
    
    // MARK: - Error Tests
    
    func testIPv4Calculator_invalidPrefix() {
        XCTAssertThrowsError(try IPv4Calculator.calculate(ip: IPv4Address(10, 0, 0, 0), prefixLength: 33)) { error in
            guard let netErr = error as? NetworkError else {
                XCTFail("Expected NetworkError")
                return
            }
            switch netErr {
            case .invalidCIDRPrefix, .prefixLengthOutOfRange: break
            default: XCTFail("Expected invalidCIDRPrefix or prefixLengthOutOfRange, got \(netErr)")
            }
        }
        
        XCTAssertThrowsError(try IPv4Calculator.calculate(ip: IPv4Address(10, 0, 0, 0), prefixLength: -1)) { error in
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
    
    func testIPv4Calculator_invalidIPInInput() {
        XCTAssertThrowsError(try IPv4Calculator.calculate(input: "999.999.999.999/24"))
    }
}
