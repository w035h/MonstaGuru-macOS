// ImportExportView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import UniformTypeIdentifiers
import Data

/// View for importing and exporting banks and presets.
public struct ImportExportView: View {
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    // MARK: - State
    
    @State private var selectedFormat: ImportExportFormat = .microMonstaSysEx
    @State private var isImporting = false
    @State private var isExporting = false
    @State private var exportBank: Bank?
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Body
    
    public var body: some View {
        NavigationStack {
            Form {
                // Format Selection
                Section(header: Text("File Format")) {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ImportExportFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text(selectedFormat.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // Import Section
                Section(header: Text("Import")) {
                    VStack(spacing: 16) {
                        Text("Import banks or presets from a file")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(action: { isImporting = true }) {
                            Label("Import File", systemImage: "folder")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .fileImporter(
                            isPresented: $isImporting,
                            allowedContentTypes: [.data],
                            allowsMultipleSelection: false
                        ) { result in
                            handleImport(result: result)
                        }
                    }
                }
                
                // Export Section
                Section(header: Text("Export")) {
                    VStack(spacing: 16) {
                        Text("Export banks or presets to a file")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Bank selection for export
                        if viewModel.hasBanks {
                            Picker("Select Bank", selection: $exportBank) {
                                Text("None").tag(nil as Bank?)
                                ForEach(viewModel.banks) { bank in
                                    Text(bank.displayName).tag(bank as Bank?)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Button(action: { 
                                if let bank = exportBank {
                                    isExporting = true
                                } else {
                                    alertMessage = "Please select a bank to export"
                                    showAlert = true
                                }
                            }) {
                                Label("Export Bank", systemImage: "square.and.arrow.up")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(exportBank == nil)
                            .fileExporter(
                                isPresented: $isExporting,
                                document: BankExportDocument(bank: exportBank ?? Bank.newBank(), format: selectedFormat),
                                contentType: .data,
                                defaultFilename: exportBank?.name ?? "bank" + selectedFormat.fileExtension
                            ) { result in
                                handleExport(result: result)
                            }
                        } else {
                            Text("No banks available to export")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
                
                // Batch Operations Section
                Section(header: Text("Batch Operations")) {
                    VStack(spacing: 8) {
                        Button(action: {}) {
                            Label("Export All Banks", systemImage: "square.stack.3d.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.hasBanks)
                        
                        Button(action: {}) {
                            Label("Backup Library", systemImage: "archivebox")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(!viewModel.hasBanks)
                        
                        Button(action: {}) {
                            Label("Restore Backup", systemImage: "archivebox.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            
            // Toolbar
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        // Dismiss action handled by parent
                    }
                }
            }
            
            .navigationTitle("Import/Export")
            
            // Alert
            .alert("Message", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            exportBank = viewModel.selectedBank ?? viewModel.banks.first
        }
    }
    
    // MARK: - Import Handler
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let bank = try viewModel.importBank(from: url)
                viewModel.banks.append(bank)
                alertMessage = "Successfully imported bank"
                showAlert = true
            } catch {
                alertMessage = "Import failed: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)")
                showAlert = true
            }
        case .failure(let error):
            alertMessage = "Import error: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)")
            showAlert = true
        }
    }
    
    // MARK: - Export Handler
    
    private func handleExport(result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            alertMessage = "Successfully exported to: $0".replacingOccurrences(of: "$0", with: "\(url.lastPathComponent)")
            showAlert = true
        case .failure(let error):
            alertMessage = "Export error: $0".replacingOccurrences(of: "$0", with: "\(error.localizedDescription)")
            showAlert = true
        }
    }
}

// MARK: - Import/Export Format

public enum ImportExportFormat: String, CaseIterable, Identifiable {
    case microMonstaSysEx
    case monstaGuruFile
    case midiSysEx
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .microMonstaSysEx: return "MicroMonsta SysEx"
        case .monstaGuruFile: return "MonstaGuru File"
        case .midiSysEx: return "MIDI SysEx"
        }
    }
    
    public var fileExtension: String {
        switch self {
        case .microMonstaSysEx: return ".syx"
        case .monstaGuruFile: return ".mm2"
        case .midiSysEx: return ".syx"
        }
    }
    
    public var description: String {
        switch self {
        case .microMonstaSysEx: return "MicroMonsta 2 SysEx dump format"
        case .monstaGuruFile: return "MonstaGuru native file format"
        case .midiSysEx: return "Standard MIDI SysEx format"
        }
    }
}

// MARK: - Bank Export Document

struct BankExportDocument: FileDocument {
    var bank: Bank
    var format: ImportExportFormat
    
    init(bank: Bank, format: ImportExportFormat) {
        self.bank = bank
        self.format = format
    }
    
    static var readableContentTypes: [UTType] { [.data] }
    static var writableContentTypes: [UTType] { [.data] }
    
    var fileType: UTType { .data }
    
    func write(to writer: FileDocumentWriter) throws {
        // Convert bank to data based on format
        let data: Data
        switch format {
        case .microMonstaSysEx, .midiSysEx:
            // Convert bank to SysEx format
            data = try convertBankToSysEx(bank: bank)
        case .monstaGuruFile:
            // Convert bank to MonstaGuru format
            data = try convertBankToMonstaGuruFormat(bank: bank)
        }
        
        try writer.write(data)
    }
    
    private func convertBankToSysEx(bank: Bank) throws -> Data {
        // Implementation for converting bank to SysEx format
        // This would use the SysExParser to create SysEx messages
        var sysExData = Data()
        
        // For now, return empty data
        // TODO: Implement actual SysEx conversion
        return sysExData
    }
    
    private func convertBankToMonstaGuruFormat(bank: Bank) throws -> Data {
        // Implementation for converting bank to MonstaGuru format
        // This would serialize the bank to a custom format
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(bank)
    }
}

// MARK: - Color Extension

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Preview

#Preview {
    let viewModel = LibrarianViewModel()
    return ImportExportView(viewModel: viewModel)
        .frame(width: 600, height: 500)
}
