//
//  SupernettingCalculatorTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class SupernettingCalculatorTests: XCTestCase {

    // MARK: - Supernetting Tests

    func testSupernetting_twoSlash24s() throws {
        let networks: [(IPv4Address, Int)] = [
            (IPv4Address(192, 168, 0, 0), 24),
            (IPv4Address(192, 168, 1, 0), 24)
        ]
        
        let result = try SupernettingCalculator.aggregate(networks: networks)
        
        XCTAssertEqual(result.network.description, "192.168.0.0")
        XCTAssertEqual(result.prefixLength, 23)
    }
    
    func testSupernetting_fourSlash24s() throws {
        let networks: [(IPv4Address, Int)] = [
            (IPv4Address(10, 0, 0, 0), 24),
            (IPv4Address(10, 0, 1, 0), 24),
            (IPv4Address(10, 0, 2, 0), 24),
            (IPv4Address(10, 0, 3, 0), 24)
        ]
        
        let result = try SupernettingCalculator.aggregate(networks: networks)
        
        XCTAssertEqual(result.network.description, "10.0.0.0")
        XCTAssertEqual(result.prefixLength, 22)
    }
    
    func testSupernetting_singleNetwork() throws {
        let networks: [(IPv4Address, Int)] = [
            (IPv4Address(172, 16, 0, 0), 24)
        ]
        
        let result = try SupernettingCalculator.aggregate(networks: networks)
        
        XCTAssertEqual(result.network.description, "172.16.0.0")
        XCTAssertEqual(result.prefixLength, 24)
    }
    
    func testSupernetting_nonContiguous() throws {
        let networks: [(IPv4Address, Int)] = [
            (IPv4Address(192, 168, 0, 0), 24),
            (IPv4Address(192, 168, 2, 0), 24) // Missing 1.0
        ]
        
        // Supernetting should find the common prefix that covers all inputs, which is /22
        let result = try SupernettingCalculator.aggregate(networks: networks)
        
        XCTAssertEqual(result.network.description, "192.168.0.0")
        XCTAssertEqual(result.prefixLength, 22)
    }
    
    func testSupernetting_differentSizes() throws {
        let networks: [(IPv4Address, Int)] = [
            (IPv4Address(10, 0, 0, 0), 24),
            (IPv4Address(10, 0, 1, 0), 25)
        ]
        
        let result = try SupernettingCalculator.aggregate(networks: networks)
        
        XCTAssertEqual(result.network.description, "10.0.0.0")
        XCTAssertEqual(result.prefixLength, 23)
    }
    
    func testSupernetting_emptyList() {
        let networks: [(IPv4Address, Int)] = []
        
        XCTAssertThrowsError(try SupernettingCalculator.aggregate(networks: networks)) { error in
            guard case .invalidInput = error as? NetworkError else {
                XCTFail("Expected invalidInput error, got \(error)")
                return
            }
        }
    }
}
