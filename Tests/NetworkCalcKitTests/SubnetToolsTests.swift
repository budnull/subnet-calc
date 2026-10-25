//
//  SubnetToolsTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class SubnetToolsTests: XCTestCase {

    // MARK: - IP in Subnet Tests

    func testSubnetTools_isIPInSubnet_true() {
        let result = SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 100), network: IPv4Address(192, 168, 1, 0), prefixLength: 24)
        XCTAssertTrue(result)
    }
    
    func testSubnetTools_isIPInSubnet_false() {
        let result = SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 2, 100), network: IPv4Address(192, 168, 1, 0), prefixLength: 24)
        XCTAssertFalse(result)
    }
    
    func testSubnetTools_isIPInSubnet_edges() {
        // First address
        XCTAssertTrue(SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 0), network: IPv4Address(192, 168, 1, 0), prefixLength: 24))
        
        // Last address
        XCTAssertTrue(SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 255), network: IPv4Address(192, 168, 1, 0), prefixLength: 24))
        
        // /32
        XCTAssertTrue(SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 1), network: IPv4Address(192, 168, 1, 1), prefixLength: 32))
        XCTAssertFalse(SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 2), network: IPv4Address(192, 168, 1, 1), prefixLength: 32))
        
        // /0
        XCTAssertTrue(SubnetTools.isIPInSubnet(ip: IPv4Address(192, 168, 1, 1), network: IPv4Address(0, 0, 0, 0), prefixLength: 0))
        XCTAssertTrue(SubnetTools.isIPInSubnet(ip: IPv4Address(255, 255, 255, 255), network: IPv4Address(0, 0, 0, 0), prefixLength: 0))
    }

    // MARK: - Mask and CIDR Conversions
    
    func testSubnetTools_cidrToSubnetMask() throws {
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 0).description, "0.0.0.0")
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 8).description, "255.0.0.0")
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 16).description, "255.255.0.0")
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 24).description, "255.255.255.0")
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 25).description, "255.255.255.128")
        XCTAssertEqual(try SubnetTools.cidrToSubnetMask(prefixLength: 32).description, "255.255.255.255")
    }
    
    func testSubnetTools_cidrToSubnetMask_outOfRange() {
        XCTAssertThrowsError(try SubnetTools.cidrToSubnetMask(prefixLength: 33)) { error in
            guard let netErr = error as? NetworkError else {
                XCTFail("Expected NetworkError")
                return
            }
            switch netErr {
            case .invalidCIDRPrefix, .prefixLengthOutOfRange: break
            default: XCTFail("Expected invalidCIDRPrefix or prefixLengthOutOfRange, got \(netErr)")
            }
        }
        
        XCTAssertThrowsError(try SubnetTools.cidrToSubnetMask(prefixLength: -1)) { error in
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
    
    func testSubnetTools_subnetMaskToCIDR() throws {
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(0, 0, 0, 0)), 0)
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 0, 0, 0)), 8)
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 255, 0, 0)), 16)
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 255, 255, 0)), 24)
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 255, 255, 128)), 25)
        XCTAssertEqual(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 255, 255, 255)), 32)
    }
    
    func testSubnetTools_subnetMaskToCIDR_invalidMask() {
        XCTAssertThrowsError(try SubnetTools.subnetMaskToCIDR(mask: IPv4Address(255, 0, 255, 0))) { error in
            guard case .invalidSubnetMask = error as? NetworkError else {
                XCTFail("Expected invalidSubnetMask error, got \(error)")
                return
            }
        }
    }
    
    func testSubnetTools_maskToWildcard() {
        let wildcard = SubnetTools.subnetMaskToWildcard(mask: IPv4Address(255, 255, 255, 0))
        XCTAssertEqual(wildcard.description, "0.0.0.255")
    }
    
    func testSubnetTools_wildcardToMask() {
        let mask = SubnetTools.wildcardToSubnetMask(wildcard: IPv4Address(0, 0, 0, 255))
        XCTAssertEqual(mask.description, "255.255.255.0")
    }
}
