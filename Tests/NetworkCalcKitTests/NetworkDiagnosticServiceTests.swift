//
//  NetworkDiagnosticServiceTests.swift
//  NetworkCalcKitTests
//

import XCTest
@testable import NetworkCalcKit

final class NetworkDiagnosticServiceTests: XCTestCase {

    func testDNS_resolveLocalhost() async throws {
        let service = NetworkDiagnosticService.shared
        let result = try await service.resolveDNS(query: "localhost")
        
        XCTAssertEqual(result.query, "localhost")
        XCTAssertTrue(result.ipAddresses.contains("127.0.0.1") || result.ipAddresses.contains("::1"))
    }
    
    func testDNS_resolveIPv4Loopback() async throws {
        let service = NetworkDiagnosticService.shared
        let result = try await service.resolveDNS(query: "127.0.0.1")
        
        XCTAssertEqual(result.query, "127.0.0.1")
        XCTAssertTrue(result.ipAddresses.contains("127.0.0.1"))
    }
    
    func testDNS_emptyQueryThrows() async {
        let service = NetworkDiagnosticService.shared
        do {
            _ = try await service.resolveDNS(query: "   ")
            XCTFail("Expected empty query to throw")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
    
    func testPing_loopbackReachable() async {
        let service = NetworkDiagnosticService.shared
        let result = await service.ping(ip: "127.0.0.1")
        
        XCTAssertEqual(result.ip, "127.0.0.1")
        XCTAssertTrue(result.isReachable)
        XCTAssertNotNil(result.responseTimeMs)
    }
}
