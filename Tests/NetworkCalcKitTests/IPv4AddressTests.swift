//
//  IPv4AddressTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class IPv4AddressTests: XCTestCase {

    // MARK: - Initialization and Parsing Tests

    func testIPv4_validParsing_standardAddress() throws {
        let ip = try IPv4Address(string: "192.168.1.1")
        XCTAssertEqual(ip.octets.0, 192)
        XCTAssertEqual(ip.octets.1, 168)
        XCTAssertEqual(ip.octets.2, 1)
        XCTAssertEqual(ip.octets.3, 1)
        
        let ip2 = try IPv4Address(string: "0.0.0.0")
        XCTAssertEqual(ip2.rawValue, 0)
        
        let ip3 = try IPv4Address(string: "255.255.255.255")
        XCTAssertEqual(ip3.rawValue, 0xFFFFFFFF)
        
        let ip4 = try IPv4Address(string: "10.0.0.1")
        XCTAssertEqual(ip4.octets.0, 10)
    }

    func testIPv4_invalidParsing() {
        let invalidStrings = [
            "256.0.0.0",
            "1.2.3",
            "1.2.3.4.5",
            "",
            "abc.def.ghi.jkl",
            "1.2.3.-1",
            "1.2.3.999"
        ]
        
        for string in invalidStrings {
            XCTAssertThrowsError(try IPv4Address(string: string)) { error in
                guard case .invalidIPv4Address = error as? NetworkError else {
                    XCTFail("Expected invalidIPv4Address error, got \(error)")
                    return
                }
            }
        }
    }
    
    func testIPv4_initWithOctets() {
        let ip = IPv4Address(192, 168, 1, 1)
        XCTAssertEqual(ip.rawValue, 0xC0A80101)
    }
    
    func testIPv4_initWithRawValue() {
        let ip = IPv4Address(rawValue: 0xC0A80101)
        XCTAssertEqual(ip.description, "192.168.1.1")
    }

    // MARK: - Properties Tests
    
    func testIPv4_equalityAndHashing() {
        let ip1 = IPv4Address(192, 168, 1, 1)
        let ip2 = IPv4Address(rawValue: 0xC0A80101)
        let ip3 = IPv4Address(10, 0, 0, 1)
        
        XCTAssertEqual(ip1, ip2)
        XCTAssertNotEqual(ip1, ip3)
        XCTAssertEqual(ip1.hashValue, ip2.hashValue)
    }
    
    func testIPv4_binaryString() {
        let ip = IPv4Address(192, 168, 1, 1)
        XCTAssertEqual(ip.binaryString, "11000000.10101000.00000001.00000001")
    }
    
    func testIPv4_addressClass() {
        XCTAssertEqual(IPv4Address(10, 0, 0, 1).addressClass, .A)
        XCTAssertEqual(IPv4Address(128, 0, 0, 1).addressClass, .B)
        XCTAssertEqual(IPv4Address(192, 168, 1, 1).addressClass, .C)
        XCTAssertEqual(IPv4Address(224, 0, 0, 1).addressClass, .D)
        XCTAssertEqual(IPv4Address(240, 0, 0, 1).addressClass, .E)
    }
    
    func testIPv4_addressTypes() {
        XCTAssertTrue(IPv4Address(10, 0, 0, 1).addressTypes.contains(.`private`))
        XCTAssertTrue(IPv4Address(172, 16, 0, 1).addressTypes.contains(.`private`))
        XCTAssertTrue(IPv4Address(172, 32, 0, 1).addressTypes.contains(.`public`))
        XCTAssertTrue(IPv4Address(192, 168, 1, 1).addressTypes.contains(.`private`))
        XCTAssertTrue(IPv4Address(127, 0, 0, 1).addressTypes.contains(.loopback))
        XCTAssertTrue(IPv4Address(169, 254, 1, 1).addressTypes.contains(.linkLocal))
        XCTAssertTrue(IPv4Address(224, 0, 0, 1).addressTypes.contains(.multicast))
        XCTAssertTrue(IPv4Address(240, 0, 0, 1).addressTypes.contains(.reserved))
        XCTAssertTrue(IPv4Address(255, 255, 255, 255).addressTypes.contains(.broadcast))
        XCTAssertTrue(IPv4Address(0, 0, 0, 0).addressTypes.contains(.currentNetwork))
        XCTAssertTrue(IPv4Address(8, 8, 8, 8).addressTypes.contains(.`public`))
    }
    
    // MARK: - Codable Tests
    
    func testIPv4_codableRoundtrip() throws {
        let ip = IPv4Address(192, 168, 1, 1)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(ip)
        let decodedIP = try decoder.decode(IPv4Address.self, from: data)
        
        XCTAssertEqual(ip, decodedIP)
    }
}
