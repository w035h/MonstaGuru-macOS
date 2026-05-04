// LibrarianView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import Data
import MIDI

/// Main librarian view for managing presets and banks.
public struct LibrarianView: View {
    
    @Environment(\.
        modelContainer) private var modelContainer
    @EnvironmentObject private var midiManager: MIDIManager
    
    @StateObject private var viewModel = LibrarianViewModel()
    
    @State private var selectedBank: Bank?
    @State private var selectedPreset: Preset?
    @State private var showNewBankSheet: Bool = false
    @State private var showNewPresetSheet: Bool = false
    @State private var showImportSheet: Bool = false
    @State private var showExportSheet: Bool = false
    
    // MARK: - Main View
    
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Librarian")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        toolbarActions
                    }
                }
        }
        .onAppear {
            viewModel.loadData(modelContainer: modelContainer)
        }
        .sheet(isPresented: $showNewBankSheet) {
            NewBankView(viewModel: viewModel)
                .environment(modelContainer)
        }
        .sheet(isPresented: $showNewPresetSheet) {
            NewPresetView(viewModel: viewModel, bank: selectedBank)
                .environment(modelContainer)
        }
        .sheet(isPresented: $showImportSheet) {
            ImportView(viewModel: viewModel)
                .environment(modelContainer)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportView(viewModel: viewModel)
                .environment(modelContainer)
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Sidebar - Banks List
            banksSidebar
                .frame(width: 250)
            
            // Main Content - Presets Grid
            presetsContent
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    private var banksSidebar: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            // Header
            HStack {
                Text("Banks")
                    .font(DesignSystem.Typography.headline)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Button(action: { showNewBankSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .buttonStyle(.plain)
                .help("New Bank")
            }
            
            // Banks List
            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(viewModel.banks) { bank in
                        BankRow(
                            bank: bank,
                            isSelected: selectedBank?.id == bank.id,
                            presetCount: bank.presetCount
                        )
                        .onTapGesture {
                            selectedBank = bank
                            selectedPreset = nil
                        }
                        .contextMenu {
                            BankContextMenu(bank: bank, viewModel: viewModel)
                        }
                    }
                }
            }
            
            // All Presets
            Button(action: { selectedBank = nil }) {
                HStack {
                    Image(systemName: selectedBank == nil ? "record.circle.fill" : "record.circle")
                        .foregroundStyle(selectedBank == nil ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    Text("All Presets")
                        .foregroundStyle(selectedBank == nil ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                    Spacer()
                    Text("(\(viewModel.allPresets.count))")
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
                .padding(DesignSystem.Spacing.sm)
            }
            .buttonStyle(.plain)
        }
        .cardStyle()
    }
    
    private var presetsContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            HStack {
                Text(selectedBank?.displayName ?? "All Presets")
                    .font(DesignSystem.Typography.title3)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if let bank = selectedBank {
                    Text("(\bank.presetCount) presets")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                } else {
                    Text("(\viewModel.allPresets.count) presets")
                        .font(DesignSystem.Typography.bodySmall)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
            }
            
            // Filter Bar
            filterBar
            
            // Presets Grid
            presetsGrid
        }
    }
    
    private var filterBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Search...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 200)
            
            Picker("Sort", selection: $viewModel.sortOrder) {
                ForEach(LibrarianViewModel.SortOrder.allCases, id: \.self) { order in
                    Text(order.rawValue).tag(order)
                }
            }
            .frame(width: 120)
            
            Spacer()
            
            Button(action: { showNewPresetSheet = true }) {
                Label("New Preset", systemImage: "plus")
            }
            .buttonStyle(isPrimary: true)
            .disabled(selectedBank == nil)
        }
    }
    
    private var presetsGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: DesignSystem.Spacing.md)],
                spacing: DesignSystem.Spacing.md
            ) {
                ForEach(viewModel.filteredPresets) { preset in
                    PresetCard(
                        preset: preset,
                        isSelected: selectedPreset?.id == preset.id,
                        onTap: { selectedPreset = preset }
                    )
                    .contextMenu {
                        PresetContextMenu(preset: preset, viewModel: viewModel)
                    }
                    .onTapGesture {
                        selectedPreset = preset
                    }
                }
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
    
    private var toolbarActions: some View {
        Group {
            Button(action: { showImportSheet = true }) {
                Label("Import", systemImage: "square.and.arrow.down")
            }
            .help("Import presets or banks")
            
            Button(action: { showExportSheet = true }) {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .help("Export presets or banks")
            
            if let preset = selectedPreset {
                Button(action: { viewModel.sendToDevice(preset: preset, midiManager: midiManager) }) {
                    Label("Send to Device", systemImage: "arrow.up.doc")
                }
                .help("Send selected preset to MicroMonsta 2")
                .disabled(!midiManager.isOutputConnected)
            }
        }
    }
}

// MARK: - Subviews

private struct BankRow: View {
    let bank: Bank
    let isSelected: Bool
    let presetCount: Int
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle()
                .fill(Color(hex: bank.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bank.displayName)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                Text("(\presetCount) presets")
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            
            Spacer()
        }
        .padding(DesignSystem.Spacing.sm)
        .background(isSelected ? DesignSystem.Colors.surfaceHover : Color.clear)
        .cornerRadius(DesignSystem.CornerRadius.sm)
        .contentShape(Rectangle())
    }
}

private struct PresetCard: View {
    let preset: Preset
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Circle()
                    .fill(Color(hex: preset.color))
                    .frame(width: 16, height: 16)
                
                Text(preset.displayName)
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                if let program = preset.program {
                    Text("#\program.number)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                        .monospacedDigit()
                }
            }
            
            if !preset.author.isEmpty {
                Text("by \preset.author)")
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            
            if !preset.tags.isEmpty {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    ForEach(preset.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(DesignSystem.Typography.caption)
                            .padding(.horizontal, DesignSystem.Spacing.xxs)
                            .padding(.vertical, DesignSystem.Spacing.xxs)
                            .background(DesignSystem.Colors.backgroundTertiary)
                            .foregroundStyle(DesignSystem.Colors.textTertiary)
                            .cornerRadius(DesignSystem.CornerRadius.xs)
                    }
                }
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                if let rating = preset.rating as? Int, rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { star in
                            Image(systemName: star < rating ? "star.fill" : "star")
                                .foregroundStyle(DesignSystem.Colors.accentOrange)
                                .font(DesignSystem.Typography.caption)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.sm)
        .frame(minWidth: 200, minHeight: 120)
        .background(isSelected ? DesignSystem.Colors.surfaceHover : DesignSystem.Colors.surface)
        .cornerRadius(DesignSystem.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .stroke(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.borderSubtle, lineWidth: 1)
        )
        .shadow(DesignSystem.Shadows.sm)
        .onTapGesture(perform: onTap)
    }
}

private struct BankContextMenu: View {
    let bank: Bank
    @ObservedObject var viewModel: LibrarianViewModel
    
    var body: some View {
        Group {
            Button(action: { viewModel.renameBank(bank) }) {
                Label("Rename", systemImage: "pencil")
            }
            
            Button(action: { viewModel.duplicateBank(bank) }) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(action: { viewModel.deleteBank(bank) }) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(DesignSystem.Colors.error)
        }
    }
}

private struct PresetContextMenu: View {
    let preset: Preset
    @ObservedObject var viewModel: LibrarianViewModel
    
    var body: some View {
        Group {
            Button(action: { viewModel.editPreset(preset) }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(action: { viewModel.duplicatePreset(preset) }) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            if let bank = preset.bank {
                Button(action: { viewModel.removeFromBank(preset, bank: bank) }) {
                    Label("Remove from Bank", systemImage: "folder.badge.minus")
                }
            }
            
            Divider()
            
            Button(action: { viewModel.deletePreset(preset) }) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(DesignSystem.Colors.error)
        }
    }
}

// MARK: - Preview

#Preview {
    LibrarianView()
        .environmentObject(MIDIManager())
        .frame(width: 1200, height: 800)
}
