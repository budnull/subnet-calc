// Services/NetworkDiagnosticService.swift
// NetworkCalcKit

import Foundation
import Darwin

public struct DNSLookupResult: Sendable, Identifiable {
    public let id = UUID()
    public let query: String
    public let hostnames: [String]
    public let ipAddresses: [String]
    
    public init(query: String, hostnames: [String], ipAddresses: [String]) {
        self.query = query
        self.hostnames = hostnames
        self.ipAddresses = ipAddresses
    }
}

public struct PingHostResult: Sendable, Identifiable {
    public let id = UUID()
    public let ip: String
    public let isReachable: Bool
    public let responseTimeMs: Double?
    public var hostname: String?
    
    public init(ip: String, isReachable: Bool, responseTimeMs: Double?, hostname: String? = nil) {
        self.ip = ip
        self.isReachable = isReachable
        self.responseTimeMs = responseTimeMs
        self.hostname = hostname
    }
}

public final class NetworkDiagnosticService: Sendable {
    
    public static let shared = NetworkDiagnosticService()
    
    private init() {}
    
    /// Resolve hostname to IP addresses or IP to hostname (Reverse DNS) with O(1) duplicate prevention
    public func resolveDNS(query: String) async throws -> DNSLookupResult {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NetworkError.invalidInput("Empty query")
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var hints = addrinfo()
                hints.ai_family = AF_UNSPEC
                hints.ai_socktype = SOCK_STREAM
                
                var res: UnsafeMutablePointer<addrinfo>?
                let status = getaddrinfo(trimmed, nil, &hints, &res)
                
                guard status == 0, let firstInfo = res else {
                    continuation.resume(throwing: NetworkError.invalidInput("Could not resolve '\(trimmed)'"))
                    return
                }
                
                defer { freeaddrinfo(res) }
                
                var ipList: [String] = []
                var seenIPs = Set<String>()
                
                var ptrList: [String] = []
                var seenPTRs = Set<String>()
                
                var ptr: UnsafeMutablePointer<addrinfo>? = firstInfo
                while let current = ptr {
                    var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    
                    let niStatus = getnameinfo(
                        current.pointee.ai_addr,
                        current.pointee.ai_addrlen,
                        &hostBuffer,
                        socklen_t(hostBuffer.count),
                        nil,
                        0,
                        NI_NUMERICHOST
                    )
                    
                    if niStatus == 0 {
                        let ipStr = String(cString: hostBuffer)
                        if seenIPs.insert(ipStr).inserted {
                            ipList.append(ipStr)
                        }
                    }
                    
                    // Attempt reverse PTR lookup
                    var ptrBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    let ptrStatus = getnameinfo(
                        current.pointee.ai_addr,
                        current.pointee.ai_addrlen,
                        &ptrBuffer,
                        socklen_t(ptrBuffer.count),
                        nil,
                        0,
                        NI_NAMEREQD
                    )
                    if ptrStatus == 0 {
                        let resolvedName = String(cString: ptrBuffer)
                        if seenPTRs.insert(resolvedName).inserted {
                            ptrList.append(resolvedName)
                        }
                    }
                    
                    ptr = current.pointee.ai_next
                }
                
                continuation.resume(returning: DNSLookupResult(
                    query: trimmed,
                    hostnames: ptrList,
                    ipAddresses: ipList
                ))
            }
        }
    }
    
    /// Lightweight native TCP socket probe with timeout in milliseconds (non-blocking in-process check)
    /// Checks common probe ports (e.g. 80, 443, 22, 53, 445, 8080) or falls back to fast ICMP ping
    public func probeHost(ip: String, timeoutMs: Int = 300) async -> PingHostResult {
        // Fast path 1: Try in-process TCP socket connect on common ports
        let ports: [UInt16] = [80, 443, 22, 53, 445]
        for port in ports {
            if let ms = checkTCPConnect(ip: ip, port: port, timeoutMs: timeoutMs) {
                return PingHostResult(ip: ip, isReachable: true, responseTimeMs: ms)
            }
        }
        
        // Fast path 2: Short ICMP ping (single packet, 250ms timeout, no reverse DNS lookup in hot path)
        return await fastICMPPing(ip: ip, timeoutMs: timeoutMs)
    }
    
    /// Fast ICMP ping with reduced timeout and no reverse DNS on hot path
    private func fastICMPPing(ip: String, timeoutMs: Int) async -> PingHostResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/sbin/ping")
                process.arguments = ["-c", "1", "-W", String(timeoutMs), ip]
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                let startTime = DispatchTime.now()
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let durationMs = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0
                    let success = (process.terminationStatus == 0)
                    
                    continuation.resume(returning: PingHostResult(
                        ip: ip,
                        isReachable: success,
                        responseTimeMs: success ? durationMs : nil,
                        hostname: nil // Decoupled: resolved asynchronously only when needed
                    ))
                } catch {
                    continuation.resume(returning: PingHostResult(
                        ip: ip,
                        isReachable: false,
                        responseTimeMs: nil,
                        hostname: nil
                    ))
                }
            }
        }
    }
    
    /// In-process non-blocking TCP socket connect
    private func checkTCPConnect(ip: String, port: UInt16, timeoutMs: Int) -> Double? {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        
        guard inet_pton(AF_INET, ip, &addr.sin_addr) == 1 else {
            return nil
        }
        
        let sock = socket(AF_INET, SOCK_STREAM, 0)
        guard sock >= 0 else { return nil }
        defer { close(sock) }
        
        // Set non-blocking
        let flags = fcntl(sock, F_GETFL, 0)
        _ = fcntl(sock, F_SETFL, flags | O_NONBLOCK)
        
        let start = DispatchTime.now()
        
        let connResult = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { sa in
                connect(sock, sa, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }
        
        if connResult == 0 {
            let duration = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0
            return duration
        }
        
        guard errno == EINPROGRESS else { return nil }
        
        var pfd = pollfd(fd: sock, events: Int16(POLLOUT), revents: 0)
        let pollRes = poll(&pfd, 1, Int32(timeoutMs))
        
        if pollRes > 0 && (pfd.revents & Int16(POLLOUT)) != 0 {
            var err: Int32 = 0
            var len = socklen_t(MemoryLayout<Int32>.size)
            if getsockopt(sock, SOL_SOCKET, SO_ERROR, &err, &len) == 0 && err == 0 {
                let duration = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0
                return duration
            }
        }
        
        return nil
    }
    
    /// Public asynchronous reverse DNS resolver (called lazily for reachable hosts)
    public func reverseDNS(ip: String) async -> String? {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                var hints = addrinfo()
                hints.ai_family = AF_INET
                hints.ai_flags = AI_NUMERICHOST
                
                var res: UnsafeMutablePointer<addrinfo>?
                guard getaddrinfo(ip, nil, &hints, &res) == 0, let info = res else {
                    continuation.resume(returning: nil)
                    return
                }
                defer { freeaddrinfo(res) }
                
                var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(info.pointee.ai_addr, info.pointee.ai_addrlen, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NAMEREQD) == 0 {
                    continuation.resume(returning: String(cString: hostBuffer))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
