//
//  SubnettingCalculatorTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class SubnettingCalculatorTests: XCTestCase {

    // MARK: - Divide Equally Tests

    func testSubnetting_divideEqually_powerOf2() throws {
        let subnets = try SubnettingCalculator.divideEqually(network: IPv4Address(192, 168, 1, 0), prefixLength: 24, numberOfSubnets: 4)
        
        XCTAssertEqual(subnets.count, 4)
        
        XCTAssertEqual(subnets[0].networkAddress.description, "192.168.1.0")
        XCTAssertEqual(subnets[0].prefixLength, 26)
        XCTAssertEqual(subnets[0].firstUsableHost?.description, "192.168.1.1")
        XCTAssertEqual(subnets[0].lastUsableHost?.description, "192.168.1.62")
        
        XCTAssertEqual(subnets[1].networkAddress.description, "192.168.1.64")
        XCTAssertEqual(subnets[1].prefixLength, 26)
        XCTAssertEqual(subnets[1].firstUsableHost?.description, "192.168.1.65")
        XCTAssertEqual(subnets[1].lastUsableHost?.description, "192.168.1.126")
        
        XCTAssertEqual(subnets[2].networkAddress.description, "192.168.1.128")
        XCTAssertEqual(subnets[2].prefixLength, 26)
        
        XCTAssertEqual(subnets[3].networkAddress.description, "192.168.1.192")
        XCTAssertEqual(subnets[3].prefixLength, 26)
        XCTAssertEqual(subnets[3].lastUsableHost?.description, "192.168.1.254")
    }
    
    func testSubnetting_divideEqually_nonPowerOf2() throws {
        let subnets = try SubnettingCalculator.divideEqually(network: IPv4Address(192, 168, 1, 0), prefixLength: 24, numberOfSubnets: 3)
        
        // Requested 3 subnets — code breaks after the requested count
        XCTAssertEqual(subnets.count, 3)
        XCTAssertEqual(subnets[0].prefixLength, 26)
        XCTAssertEqual(subnets[2].networkAddress.description, "192.168.1.128")
    }
    
    func testSubnetting_divideEqually_slash32() throws {
        let subnets = try SubnettingCalculator.divideEqually(network: IPv4Address(192, 168, 1, 0), prefixLength: 24, numberOfSubnets: 256)
        
        XCTAssertEqual(subnets.count, 256)
        XCTAssertEqual(subnets[0].prefixLength, 32)
        XCTAssertEqual(subnets[255].networkAddress.description, "192.168.1.255")
    }
    
    func testSubnetting_divideEqually_exceedingSpace() {
        XCTAssertThrowsError(try SubnettingCalculator.divideEqually(network: IPv4Address(192, 168, 1, 0), prefixLength: 24, numberOfSubnets: 257)) { error in
            guard case .subnetsExceedSpace = error as? NetworkError else {
                XCTFail("Expected subnetsExceedSpace error, got \(error)")
                return
            }
        }
    }

    // MARK: - VLSM Tests
    
    func testSubnetting_divideVLSM() throws {
        let requirements: [(String, Int)] = [
            ("LAN A", 100),
            ("LAN B", 50),
            ("LAN C", 20),
            ("WAN", 2)
        ]
        
        let subnets = try SubnettingCalculator.divideVLSM(network: IPv4Address(10, 0, 0, 0), prefixLength: 24, requirements: requirements)
        
        XCTAssertEqual(subnets.count, 4)
        
        // LAN A: Needs 100 -> 128 total (126 usable) -> /25
        XCTAssertEqual(subnets[0].name, "LAN A")
        XCTAssertEqual(subnets[0].prefixLength, 25)
        XCTAssertEqual(subnets[0].networkAddress.description, "10.0.0.0")
        XCTAssertEqual(subnets[0].usableHosts, 126)
        
        // LAN B: Needs 50 -> 64 total (62 usable) -> /26
        XCTAssertEqual(subnets[1].name, "LAN B")
        XCTAssertEqual(subnets[1].prefixLength, 26)
        XCTAssertEqual(subnets[1].networkAddress.description, "10.0.0.128")
        XCTAssertEqual(subnets[1].usableHosts, 62)
        
        // LAN C: Needs 20 -> 32 total (30 usable) -> /27
        XCTAssertEqual(subnets[2].name, "LAN C")
        XCTAssertEqual(subnets[2].prefixLength, 27)
        XCTAssertEqual(subnets[2].networkAddress.description, "10.0.0.192")
        XCTAssertEqual(subnets[2].usableHosts, 30)
        
        // WAN: Needs 2 -> 4 total (2 usable) -> /30
        XCTAssertEqual(subnets[3].name, "WAN")
        XCTAssertEqual(subnets[3].prefixLength, 30)
        XCTAssertEqual(subnets[3].networkAddress.description, "10.0.0.224")
        XCTAssertEqual(subnets[3].usableHosts, 2)
    }
    
    func testSubnetting_divideVLSM_overflow() {
        let requirements: [(String, Int)] = [
            ("LAN A", 200),
            ("LAN B", 100) // Total 300+ > 256 available in /24
        ]
        
        XCTAssertThrowsError(try SubnettingCalculator.divideVLSM(network: IPv4Address(10, 0, 0, 0), prefixLength: 24, requirements: requirements)) { error in
            guard let netErr = error as? NetworkError else {
                XCTFail("Expected NetworkError, got \(error)")
                return
            }
            switch netErr {
            case .subnetsExceedSpace, .insufficientAddressSpace, .invalidInput: break
            default: XCTFail("Expected address space error, got \(netErr)")
            }
        }
    }
}
