import SwiftUI

enum HelpLanguage: String, CaseIterable, Identifiable {
    case en = "English"
    case it = "Italiano"
    
    var id: String { rawValue }
}

struct HelpSection: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let summary: String
    let content: [HelpItem]
}

struct HelpItem: Identifiable {
    let id = UUID()
    let heading: String
    let text: String
    let example: String?
}

struct HelpView: View {
    @State private var searchText: String = ""
    @State private var selectedLanguage: HelpLanguage = {
        let isIt = Locale.current.language.languageCode?.identifier == "it" || Locale.current.identifier.hasPrefix("it")
        return isIt ? .it : .en
    }()
    
    private var englishSections: [HelpSection] {
        [
            HelpSection(
                title: "IPv4 Subnet Calculator",
                icon: "4.circle.fill",
                summary: "Calculate subnet masks, usable host ranges, broadcast addresses, and binary breakdown.",
                content: [
                    HelpItem(
                        heading: "Accepted Input Formats",
                        text: "You can specify an IPv4 address using standard CIDR notation or an address followed by a dotted decimal subnet mask.",
                        example: "192.168.1.10/24  or  10.0.0.1 255.255.0.0"
                    ),
                    HelpItem(
                        heading: "Network & Broadcast Addresses",
                        text: "The Network Address is the first address in the block with all host bits set to 0. The Broadcast Address is the last address with all host bits set to 1.",
                        example: "For 192.168.1.0/24: Network = 192.168.1.0, Broadcast = 192.168.1.255"
                    ),
                    HelpItem(
                        heading: "Usable Host Range",
                        text: "For prefixes between /1 and /30, usable hosts start at (Network + 1) and end at (Broadcast - 1). Special RFC 3021 /31 point-to-point links allow 2 usable hosts. A /32 represents a single host route.",
                        example: "/24 provides 254 usable hosts (192.168.1.1 - 192.168.1.254)"
                    ),
                    HelpItem(
                        heading: "Binary Representation",
                        text: "Visualizes all 32 bits divided into 4 octets. Network bits are highlighted in blue and host bits in orange to easily see boundary transitions.",
                        example: "11000000.10101000.00000001 (Network) . 00001010 (Host)"
                    ),
                    HelpItem(
                        heading: "Address Classes & Types",
                        text: "Identifies legacy Class (A, B, C, D Multicast, E Reserved) as well as RFC 1918 Private ranges (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16), Loopback (127.0.0.0/8), and Link-Local APIPA (169.254.0.0/16).",
                        example: nil
                    )
                ]
            ),
            HelpSection(
                title: "IPv6 Subnet Calculator",
                icon: "6.circle.fill",
                summary: "Calculate 128-bit IPv6 prefixes, first/last addresses, and total address space.",
                content: [
                    HelpItem(
                        heading: "Input Format",
                        text: "Accepts IPv6 addresses with a slash followed by the prefix length (0 to 128). Both compressed (using '::') and fully expanded 8-hextet formats are supported.",
                        example: "2001:db8::1/48  or  fe80::1/10"
                    ),
                    HelpItem(
                        heading: "RFC 5952 Compression",
                        text: "Results are formatted following the canonical RFC 5952 standard: leading zeros in each 16-bit block are omitted, and the longest run of consecutive zero hextets is replaced with '::'.",
                        example: "2001:0db8:0000:0000:0000:0000:0000:0000 -> 2001:db8::"
                    ),
                    HelpItem(
                        heading: "Total Address Count",
                        text: "Calculates the exact total address count as 2^(128 - prefixLength), displayed in full precision without scientific notation overflow.",
                        example: "A /64 subnet contains 18,446,744,073,709,551,616 addresses"
                    )
                ]
            ),
            HelpSection(
                title: "Subnetting (Equal & VLSM)",
                icon: "rectangle.split.3x1.fill",
                summary: "Divide networks into equal-sized subnets or optimal variable-length subnets.",
                content: [
                    HelpItem(
                        heading: "Equal Subnetting",
                        text: "Divides a parent network into a specified number of equal-sized subnets. The calculator automatically rounds up to the next power of 2 and provides network, mask, usable range, and broadcast for each subnet.",
                        example: "Divide 192.168.1.0/24 into 4 subnets -> four /26 subnets of 62 hosts each"
                    ),
                    HelpItem(
                        heading: "VLSM (Variable Length Subnet Masking)",
                        text: "Allows you to enter multiple subnet requirements with custom host counts. The algorithm sorts requirements in descending order and assigns the smallest valid CIDR block for each requirement, minimizing wasted addresses.",
                        example: "LAN A: 100 hosts (/25), LAN B: 50 hosts (/26), WAN: 2 hosts (/30)"
                    )
                ]
            ),
            HelpSection(
                title: "Supernetting (Route Aggregation)",
                icon: "arrow.triangle.merge",
                summary: "Aggregate multiple individual routes into a single summary prefix.",
                content: [
                    HelpItem(
                        heading: "CIDR Summarization",
                        text: "Enter two or more network prefixes. The algorithm finds the longest common bit prefix that encompasses all provided routes and computes the minimal summary supernet.",
                        example: "192.168.0.0/24 + 192.168.1.0/24 -> 192.168.0.0/23"
                    ),
                    HelpItem(
                        heading: "Non-Contiguous Aggregation",
                        text: "If non-contiguous subnets are provided, the supernet expands to the closest boundary covering all specified ranges.",
                        example: "192.168.0.0/24 and 192.168.2.0/24 -> 192.168.0.0/22"
                    )
                ]
            ),
            HelpSection(
                title: "Tools & Converters",
                icon: "wrench.and.screwdriver.fill",
                summary: "Utility tools for verification and mask conversions.",
                content: [
                    HelpItem(
                        heading: "Check IP in Subnet",
                        text: "Tests whether a specific IPv4 address belongs to a designated CIDR subnet by checking if (IP & mask) == (Subnet & mask).",
                        example: "Is 192.168.1.150 in 192.168.1.128/25? -> Yes (128 - 255)"
                    ),
                    HelpItem(
                        heading: "CIDR / Mask Converter",
                        text: "Bidirectional converter. Type a prefix number (e.g. '24'), a dotted subnet mask (e.g. '255.255.255.0'), or a wildcard mask (e.g. '0.0.0.255') to immediately view all three representations.",
                        example: "27 <-> 255.255.255.224 <-> 0.0.0.31"
                    )
                ]
            ),
            HelpSection(
                title: "History, Export & Shortcuts",
                icon: "clock.arrow.circlepath",
                summary: "Export results, access past calculations, and keyboard shortcuts.",
                content: [
                    HelpItem(
                        heading: "History Storage",
                        text: "Calculations are automatically recorded in the History section and persisted across application restarts via local preferences.",
                        example: nil
                    ),
                    HelpItem(
                        heading: "Export Formats",
                        text: "Use the Export menu button on calculation results to copy text to clipboard, copy comma-separated values (CSV), or save directly to a .csv file.",
                        example: nil
                    ),
                    HelpItem(
                        heading: "Keyboard Shortcuts",
                        text: "• Command + Return: Calculate current input\n• Return: Submit input in single text fields\n• Command + C: Copy selected values",
                        example: nil
                    )
                ]
            )
        ]
    }
    
    private var italianSections: [HelpSection] {
        [
            HelpSection(
                title: "Calcolatore Sottoreti IPv4",
                icon: "4.circle.fill",
                summary: "Calcola maschere di sottorete, intervalli host utilizzabili, indirizzi di broadcast e rappresentazione binaria.",
                content: [
                    HelpItem(
                        heading: "Formati di Input Supportati",
                        text: "Puoi specificare un indirizzo IPv4 utilizzando la notazione standard CIDR oppure l'indirizzo seguito dalla maschera di sottorete decimale puntata.",
                        example: "192.168.1.10/24  oppure  10.0.0.1 255.255.0.0"
                    ),
                    HelpItem(
                        heading: "Indirizzi di Rete e di Broadcast",
                        text: "L'Indirizzo di Rete è il primo indirizzo del blocco con tutti i bit di host a 0. L'Indirizzo di Broadcast è l'ultimo indirizzo con tutti i bit di host a 1.",
                        example: "Per 192.168.1.0/24: Rete = 192.168.1.0, Broadcast = 192.168.1.255"
                    ),
                    HelpItem(
                        heading: "Intervallo Host Utilizzabili",
                        text: "Per prefissi tra /1 e /30, gli host utilizzabili iniziano a (Rete + 1) e terminano a (Broadcast - 1). I collegamenti punto-punto RFC 3021 /31 consentono 2 host utilizzabili. Un /32 rappresenta un singolo host.",
                        example: "/24 fornisce 254 host utilizzabili (192.168.1.1 - 192.168.1.254)"
                    ),
                    HelpItem(
                        heading: "Rappresentazione Binaria",
                        text: "Visualizza tutti i 32 bit suddivisi nei 4 ottetti. I bit di rete sono evidenziati in blu e i bit di host in arancione per identificare chiaramente i confini.",
                        example: "11000000.10101000.00000001 (Rete) . 00001010 (Host)"
                    ),
                    HelpItem(
                        heading: "Classi e Tipologie di Indirizzo",
                        text: "Riconosce la classe storica (A, B, C, D Multicast, E Riservata) e le tipologie RFC 1918 Private (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16), Loopback (127.0.0.0/8) e Link-Local APIPA (169.254.0.0/16).",
                        example: nil
                    )
                ]
            ),
            HelpSection(
                title: "Calcolatore Sottoreti IPv6",
                icon: "6.circle.fill",
                summary: "Calcola prefissi IPv6 a 128 bit, primo e ultimo indirizzo e spazio totale di indirizzamento.",
                content: [
                    HelpItem(
                        heading: "Formato di Input",
                        text: "Accetta indirizzi IPv6 seguiti dalla barra e dalla lunghezza del prefisso (da 0 a 128). Sono supportati sia il formato compresso (con '::') sia quello esteso a 8 gruppi esadecimali.",
                        example: "2001:db8::1/48  oppure  fe80::1/10"
                    ),
                    HelpItem(
                        heading: "Compressione RFC 5952",
                        text: "I risultati sono formattati secondo lo standard canonico RFC 5952: gli zeri iniziali in ogni blocco a 16 bit vengono omessi e la sequenza più lunga di zeri consecutivi viene sostituita da '::'.",
                        example: "2001:0db8:0000:0000:0000:0000:0000:0000 -> 2001:db8::"
                    ),
                    HelpItem(
                        heading: "Numero Totale di Indirizzi",
                        text: "Calcola il numero totale esatto di indirizzi come 2^(128 - prefisso), visualizzato in precisione completa senza approssimazione scientifica.",
                        example: "Una sottorete /64 contiene 18.446.744.073.709.551.616 indirizzi"
                    )
                ]
            ),
            HelpSection(
                title: "Subnetting (Divisione Equa & VLSM)",
                icon: "rectangle.split.3x1.fill",
                summary: "Suddivide le reti in sottoreti di uguali dimensioni o sottoreti a lunghezza variabile ottimali.",
                content: [
                    HelpItem(
                        heading: "Divisione Equa",
                        text: "Suddivide una rete madre in un numero specificato di sottoreti identiche. Il calcolatore arrotonda automaticamente alla potenza di 2 successiva e calcola rete, maschera, intervallo e broadcast per ciascuna.",
                        example: "Dividere 192.168.1.0/24 in 4 sottoreti -> quattro sottoreti /26 con 62 host ciascuna"
                    ),
                    HelpItem(
                        heading: "VLSM (Variable Length Subnet Masking)",
                        text: "Consente di inserire requisiti con numero di host variabile. L'algoritmo ordina i requisiti in modo decrescente e assegna il blocco CIDR minimo necessario, azzerando gli sprechi di indirizzi.",
                        example: "LAN A: 100 host (/25), LAN B: 50 host (/26), WAN: 2 host (/30)"
                    )
                ]
            ),
            HelpSection(
                title: "Supernetting (Aggregazione Rotte)",
                icon: "arrow.triangle.merge",
                summary: "Aggrega molteplici rotte individuali in un unico prefisso riassuntivo.",
                content: [
                    HelpItem(
                        heading: "Sommarizzazione CIDR",
                        text: "Inserisci due o più prefissi di rete. L'algoritmo individua il prefisso binario comune più specifico che include tutte le rotte fornite e genera la supernet minima.",
                        example: "192.168.0.0/24 + 192.168.1.0/24 -> 192.168.0.0/23"
                    ),
                    HelpItem(
                        heading: "Aggregazione Non Contigua",
                        text: "Se le sottoreti non sono perfettamente contigue, la supernet si espande fino al confine di blocco più vicino che copre tutti gli intervalli inseriti.",
                        example: "192.168.0.0/24 e 192.168.2.0/24 -> 192.168.0.0/22"
                    )
                ]
            ),
            HelpSection(
                title: "Strumenti e Convertitori",
                icon: "wrench.and.screwdriver.fill",
                summary: "Utility di verifica e conversione rapida maschere.",
                content: [
                    HelpItem(
                        heading: "Verifica IP nella Sottorete",
                        text: "Verifica se un determinato indirizzo IPv4 appartiene a una sottorete CIDR controllando se (IP & maschera) == (Sottorete & maschera).",
                        example: "192.168.1.150 appartiene a 192.168.1.128/25? -> Sì (intervallo 128 - 255)"
                    ),
                    HelpItem(
                        heading: "Convertitore CIDR / Maschera",
                        text: "Convertitore bidirezionale istantaneo. Inserisci un prefisso numerico (es. '24'), una subnet mask decimale (es. '255.255.255.0') o una wildcard mask (es. '0.0.0.255') per visualizzare contemporaneamente tutte e tre le forme.",
                        example: "27 <-> 255.255.255.224 <-> 0.0.0.31"
                    )
                ]
            ),
            HelpSection(
                title: "Cronologia, Esportazione e Scorciatoie",
                icon: "clock.arrow.circlepath",
                summary: "Esporta i risultati, accedi ai calcoli passati e consulta le scorciatoie da tastiera.",
                content: [
                    HelpItem(
                        heading: "Salvataggio Cronologia",
                        text: "I calcoli eseguiti vengono salvati automaticamente nella sezione Cronologia e persistono anche dopo la chiusura dell'applicazione.",
                        example: nil
                    ),
                    HelpItem(
                        heading: "Formati di Esportazione",
                        text: "Usa il pulsante Esporta presente nei risultati per copiare come testo, copiare in formato CSV o salvare direttamente un file .csv sul disco.",
                        example: nil
                    ),
                    HelpItem(
                        heading: "Scorciatoie da Tastiera",
                        text: "• Comando + Invio: Esegui calcolo\n• Invio: Conferma nei campi di testo singoli\n• Comando + C: Copia valori selezionati",
                        example: nil
                    )
                ]
            )
        ]
    }
    
    private var activeSections: [HelpSection] {
        selectedLanguage == .it ? italianSections : englishSections
    }
    
    private var filteredSections: [HelpSection] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return activeSections
        }
        let q = searchText.lowercased()
        return activeSections.compactMap { sec in
            let matchesSec = sec.title.lowercased().contains(q) || sec.summary.lowercased().contains(q)
            let matchingItems = sec.content.filter { item in
                item.heading.lowercased().contains(q) ||
                item.text.lowercased().contains(q) ||
                (item.example?.lowercased().contains(q) ?? false)
            }
            if matchesSec {
                return sec
            } else if !matchingItems.isEmpty {
                return HelpSection(title: sec.title, icon: sec.icon, summary: sec.summary, content: matchingItems)
            } else {
                return nil
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with Language Picker
                HStack(alignment: .top) {
                    HStack(spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(selectedLanguage == .it ? "Guida & Documentazione" : "Help & Documentation")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text(selectedLanguage == .it ?
                                 "Guida di riferimento completa per le funzionalità di SubnetCalc e i concetti di rete." :
                                 "Comprehensive reference guide for SubnetCalc features and network concepts.")
                                .foregroundColor(.secondary)
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    
                    // Language switcher
                    Picker("", selection: $selectedLanguage) {
                        ForEach(HelpLanguage.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 170)
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField(
                        selectedLanguage == .it ?
                        "Cerca argomenti, parole chiave o esempi (es. VLSM, /24, broadcast)..." :
                        "Search topics, keywords, or examples (e.g. VLSM, /24, broadcast)...",
                        text: $searchText
                    )
                    .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                
                Divider()
                
                // Content sections
                if filteredSections.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text(selectedLanguage == .it ? "Nessun argomento trovato" : "No matching help topics found")
                            .font(.headline)
                        Text(selectedLanguage == .it ?
                             "Prova a cercare termini come 'CIDR', 'IPv6', 'VLSM' o 'wildcard'." :
                             "Try searching for terms like 'CIDR', 'IPv6', 'VLSM', or 'wildcard'.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    ForEach(filteredSections) { section in
                        VStack(alignment: .leading, spacing: 14) {
                            // Section header
                            HStack(spacing: 10) {
                                Image(systemName: section.icon)
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(section.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text(section.summary)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            // Items in section
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(section.content) { item in
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(item.heading)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Text(item.text)
                                            .font(.body)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        if let ex = item.example {
                                            HStack(alignment: .top, spacing: 6) {
                                                Text(selectedLanguage == .it ? "Esempio:" : "Example:")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.blue)
                                                Text(ex)
                                                    .font(.system(.caption, design: .monospaced))
                                                    .foregroundColor(.primary)
                                            }
                                            .padding(6)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(Color.blue.opacity(0.08))
                                            .cornerRadius(6)
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding(24)
        }
    }
}
