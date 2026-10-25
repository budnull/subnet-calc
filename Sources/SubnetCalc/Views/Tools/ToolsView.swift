import SwiftUI
import NetworkCalcKit

struct ToolsView: View {
    @StateObject private var viewModel = ToolsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Tools")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Section 1: Check IP in subnet
                GroupBox("Check if IP is in subnet") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("IP Address", text: $viewModel.checkIP)
                                .textFieldStyle(.roundedBorder)
                            TextField("Subnet (CIDR)", text: $viewModel.checkSubnet)
                                .textFieldStyle(.roundedBorder)
                            Button("Check") { viewModel.checkIPInSubnet() }
                        }
                        
                        if let error = viewModel.checkError {
                            ErrorBanner(message: error)
                        }
                        
                        if let result = viewModel.checkResult {
                            HStack {
                                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(result ? .green : .red)
                                Text(LocalizedStringKey(result ? "IP belongs to subnet" : "IP does not belong to subnet"))
                                    .fontWeight(.medium)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(8)
                }
                
                // Section 2: CIDR / Mask Converter
                GroupBox("CIDR / Mask Converter") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            TextField("Enter CIDR prefix, subnet mask, or wildcard mask", text: $viewModel.converterInput)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { viewModel.convert() }
                            Button("Convert") { viewModel.convert() }
                        }
                        
                        if let error = viewModel.converterError {
                            ErrorBanner(message: error)
                        }
                        
                        if viewModel.converterCIDR != nil {
                            VStack(spacing: 0) {
                                ResultRow(label: "CIDR Prefix", value: "/\(viewModel.converterCIDR ?? "")")
                                Divider()
                                ResultRow(label: "Subnet Mask", value: viewModel.converterMask ?? "")
                                Divider()
                                ResultRow(label: "Wildcard Mask", value: viewModel.converterWildcard ?? "")
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                    .padding(8)
                }
                
                // Section 3: DNS & Reverse DNS Lookup
                GroupBox("DNS & Reverse DNS Lookup") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resolve domain names to IP addresses, or IP addresses to reverse hostnames (PTR).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Hostname or IP (e.g. apple.com or 8.8.8.8)", text: $viewModel.dnsQuery)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { viewModel.performDNSLookup() }
                            
                            Button(action: { viewModel.performDNSLookup() }) {
                                if viewModel.isResolvingDNS {
                                    ProgressView().controlSize(.small)
                                } else {
                                    Text("Resolve")
                                }
                            }
                            .disabled(viewModel.isResolvingDNS || viewModel.dnsQuery.isEmpty)
                        }
                        
                        if let error = viewModel.dnsError {
                            ErrorBanner(message: error)
                        }
                        
                        if let res = viewModel.dnsResult {
                            VStack(alignment: .leading, spacing: 8) {
                                if !res.ipAddresses.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Resolved IP Addresses:")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        ForEach(res.ipAddresses, id: \.self) { ip in
                                            ResultRow(label: "IP", value: ip)
                                        }
                                    }
                                }
                                
                                if !res.hostnames.isEmpty {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Reverse Hostnames (PTR):")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.secondary)
                                        ForEach(res.hostnames, id: \.self) { host in
                                            ResultRow(label: "Hostname", value: host)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                    .padding(8)
                }
                
                // Section 4: Ping Sweep / Host Scanner
                GroupBox("Ping Sweep / Network Scanner") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Scan an entire subnet (e.g. 192.168.1.0/24) or target host to detect live, reachable devices.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            TextField("Subnet or IP (e.g. 192.168.1.0/24)", text: $viewModel.pingTarget)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit { viewModel.startPingSweep() }
                            
                            if viewModel.isScanning {
                                Button("Stop") { viewModel.cancelScan() }
                                    .foregroundColor(.red)
                            } else {
                                Button("Start Sweep") { viewModel.startPingSweep() }
                                    .disabled(viewModel.pingTarget.isEmpty)
                            }
                            
                            if !viewModel.pingResults.isEmpty {
                                Button("Clear") {
                                    viewModel.pingResults = []
                                    viewModel.scanProgress = 0.0
                                }
                            }
                        }
                        
                        if viewModel.isScanning {
                            VStack(alignment: .leading, spacing: 4) {
                                ProgressView(value: viewModel.scanProgress, total: 1.0)
                                HStack {
                                    Text("Scanning hosts...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(viewModel.scanProgress * 100))%")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        
                        if let error = viewModel.pingError {
                            ErrorBanner(message: error)
                        }
                        
                        if !viewModel.pingResults.isEmpty {
                            let liveCount = viewModel.pingResults.filter { $0.isReachable }.count
                            HStack {
                                Text("\(liveCount) of \(viewModel.pingResults.count) hosts reachable")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                Button("Copy Live IPs") {
                                    let liveIPs = viewModel.pingResults.filter { $0.isReachable }.map { $0.ip }.joined(separator: "\n")
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(liveIPs, forType: .string)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 2)
                            
                            VStack(spacing: 0) {
                                ForEach(viewModel.pingResults) { res in
                                    HStack {
                                        Circle()
                                            .fill(res.isReachable ? Color.green : Color.secondary.opacity(0.4))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(res.ip)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(res.isReachable ? .semibold : .regular)
                                        
                                        if let name = res.hostname {
                                            Text("(\(name))")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        
                                        Spacer()
                                        
                                        if let ms = res.responseTimeMs {
                                            Text(String(format: "%.1f ms", ms))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("Timeout")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding(.vertical, 6)
                                    Divider()
                                }
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        }
                    }
                    .padding(8)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
}
