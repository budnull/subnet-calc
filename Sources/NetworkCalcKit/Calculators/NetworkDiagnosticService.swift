// Services/NetworkDiagnosticService.swift
// NetworkCalcKit

import Foundation

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
    public let hostname: String?
    
    public init(ip: String, isReachable: Bool, responseTimeMs: Double?, hostname: String?) {
        self.ip = ip
        self.isReachable = isReachable
        self.responseTimeMs = responseTimeMs
        self.hostname = hostname
    }
}

public final class NetworkDiagnosticService: Sendable {
    
    public static let shared = NetworkDiagnosticService()
    
    private init() {}
    
    /// Resolve hostname to IP addresses or IP to hostname (Reverse DNS)
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
                var ptrList: [String] = []
                
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
                        if !ipList.contains(ipStr) {
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
                        if !ptrList.contains(resolvedName) {
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
    
    /// Ping a single IPv4 address (1 packet, 1 second timeout)
    public func ping(ip: String) async -> PingHostResult {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/sbin/ping")
                process.arguments = ["-c", "1", "-W", "1000", ip]
                
                let pipe = Pipe()
                process.standardOutput = pipe
                process.standardError = pipe
                
                let startTime = DispatchTime.now()
                
                do {
                    try process.run()
                    process.waitUntilExit()
                    
                    let durationMs = Double(DispatchTime.now().uptimeNanoseconds - startTime.uptimeNanoseconds) / 1_000_000.0
                    let success = (process.terminationStatus == 0)
                    
                    // Reverse DNS lookup for host if reachable
                    var hostname: String? = nil
                    if success {
                        hostname = self.quickReverseDNS(ip: ip)
                    }
                    
                    continuation.resume(returning: PingHostResult(
                        ip: ip,
                        isReachable: success,
                        responseTimeMs: success ? durationMs : nil,
                        hostname: hostname
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
    
    private func quickReverseDNS(ip: String) -> String? {
        var hints = addrinfo()
        hints.ai_family = AF_INET
        hints.ai_flags = AI_NUMERICHOST
        
        var res: UnsafeMutablePointer<addrinfo>?
        guard getaddrinfo(ip, nil, &hints, &res) == 0, let info = res else { return nil }
        defer { freeaddrinfo(res) }
        
        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if getnameinfo(info.pointee.ai_addr, info.pointee.ai_addrlen, &hostBuffer, socklen_t(hostBuffer.count), nil, 0, NI_NAMEREQD) == 0 {
            return String(cString: hostBuffer)
        }
        return nil
    }
}
