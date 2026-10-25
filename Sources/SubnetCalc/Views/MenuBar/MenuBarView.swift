import SwiftUI
import NetworkCalcKit

struct MenuBarView: View {
    @State private var input: String = "192.168.1.0/24"
    @State private var result: IPv4SubnetResult?
    @State private var errorMessage: String?
    @State private var copiedLabel: String?
    
    private var isItalian: Bool {
        Locale.current.language.languageCode?.identifier == "it" || Locale.current.identifier.hasPrefix("it")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "network")
                    .foregroundColor(.blue)
                Text(isItalian ? "SubnetCalc Rapido" : "SubnetCalc Quick")
                    .font(.headline)
                Spacer()
                Button(action: {
                    openMainWindow()
                }) {
                    Image(systemName: "macwindow")
                        .help(isItalian ? "Apri Finestra Principale" : "Open Main Window")
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Input field with Paste and Clear
            HStack(spacing: 6) {
                TextField("e.g. 192.168.1.10/24", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { calculate() }
                
                // Paste from clipboard button
                Button(action: {
                    pasteFromClipboard()
                }) {
                    Image(systemName: "doc.on.clipboard")
                        .help(isItalian ? "Incolla dagli appunti e calcola" : "Paste from clipboard and calculate")
                }
                .buttonStyle(.plain)
                
                // Calculate button
                Button(isItalian ? "Calcola" : "Calc") {
                    calculate()
                }
                .keyboardShortcut(.return, modifiers: [])
            }
            
            if let err = errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            
            // Quick results with Copy buttons
            if let res = result {
                VStack(spacing: 6) {
                    quickRow(
                        labelKey: "network",
                        label: isItalian ? "Rete:" : "Network:",
                        value: "\(res.networkAddress.description)/\(res.prefixLength)",
                        copyValue: res.networkAddress.description
                    )
                    Divider()
                    quickRow(
                        labelKey: "broadcast",
                        label: "Broadcast:",
                        value: res.broadcastAddress.description,
                        copyValue: res.broadcastAddress.description
                    )
                    Divider()
                    quickRow(
                        labelKey: "mask",
                        label: isItalian ? "Maschera:" : "Subnet Mask:",
                        value: res.subnetMask.description,
                        copyValue: res.subnetMask.description
                    )
                    Divider()
                    quickRow(
                        labelKey: "hosts",
                        label: isItalian ? "Host Utili:" : "Usable Hosts:",
                        value: "\(res.usableHosts) (\(res.firstUsableHost?.description ?? "-") - \(res.lastUsableHost?.description ?? "-"))",
                        copyValue: "\(res.usableHosts)"
                    )
                }
                .padding(10)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
            }
            
            Divider()
            
            // Footer actions
            HStack {
                Button(isItalian ? "Apri App Completa" : "Open Full App") {
                    openMainWindow()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button(isItalian ? "Esci" : "Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .frame(width: 350)
        .onAppear {
            calculate()
        }
    }
    
    private func quickRow(labelKey: String, label: String, value: String, copyValue: String) -> some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .textSelection(.enabled)
            
            Button(action: {
                copyToClipboard(copyValue, labelKey: labelKey)
            }) {
                if copiedLabel == labelKey {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.system(size: 11, weight: .bold))
                } else {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            .help(isItalian ? "Copia valore" : "Copy value")
        }
    }
    
    private func copyToClipboard(_ value: String, labelKey: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(value, forType: .string)
        
        copiedLabel = labelKey
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if copiedLabel == labelKey {
                copiedLabel = nil
            }
        }
    }
    
    private func pasteFromClipboard() {
        if let clip = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines), !clip.isEmpty {
            input = clip
            calculate()
        }
    }
    
    private func openMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.canBecomeKey {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    private func calculate() {
        errorMessage = nil
        do {
            result = try IPv4Calculator.calculate(input: input)
        } catch {
            errorMessage = error.localizedDescription
            result = nil
        }
    }
}
