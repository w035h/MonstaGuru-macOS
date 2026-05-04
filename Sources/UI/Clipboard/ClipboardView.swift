// ClipboardView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Clipboard Agent)

import SwiftUI
import Data

/// Main clipboard view for managing persistent clipboard entries.
public struct ClipboardView: View {
    
    @Environment(\.
        modelContainer) private var modelContainer
    
    @StateObject private var viewModel = ClipboardViewModel()
    
    @State private var selectedEntry: ClipboardEntry?
    @State private var showNewEntrySheet: Bool = false
    @State private var showClearAllAlert: Bool = false
    
    // MARK: - Main View
    
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Clipboard")
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        toolbarActions
                    }
                }
        }
        .onAppear {
            viewModel.loadData(modelContainer: modelContainer)
        }
        .sheet(isPresented: $showNewEntrySheet) {
            NewClipboardEntryView(viewModel: viewModel)
                .environment(modelContainer)
        }
        .alert("Clear All Entries", isPresented: $showClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                viewModel.clearAll()
            }
        } message: {
            Text("Are you sure you want to clear all clipboard entries? This cannot be undone.")
        }
    }
    
    // MARK: - Content
    
    private var content: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Header
            header
            
            // Filter Bar
            filterBar
            
            // Entries List
            entriesList
        }
        .padding(DesignSystem.Spacing.md)
    }
    
    private var header: some View {
        HStack {
            Text("Persistent Clipboard")
                .font(DesignSystem.Typography.title3)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            Spacer()
            
            Text("(\viewModel.filteredEntries.count) entries")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textTertiary)
        }
    }
    
    private var filterBar: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            TextField("Search...", text: $viewModel.searchQuery)
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 200)
            
            Picker("Type", selection: $viewModel.filterType) {
                ForEach(ClipboardViewModel.FilterType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .frame(width: 120)
            
            Spacer()
            
            Button(action: { showNewEntrySheet = true }) {
                Label("New Entry", systemImage: "plus")
            }
            .buttonStyle(isPrimary: true)
        }
    }
    
    private var entriesList: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: DesignSystem.Spacing.md)],
                spacing: DesignSystem.Spacing.md
            ) {
                ForEach(viewModel.filteredEntries) { entry in
                    ClipboardEntryCard(
                        entry: entry,
                        isSelected: selectedEntry?.id == entry.id,
                        onTap: { selectedEntry = entry }
                    )
                    .contextMenu {
                        EntryContextMenu(entry: entry, viewModel: viewModel)
                    }
                    .onTapGesture {
                        selectedEntry = entry
                    }
                }
            }
            .padding(DesignSystem.Spacing.sm)
        }
    }
    
    private var toolbarActions: some View {
        Group {
            Button(action: { viewModel.pasteSelected() }) {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
            .help("Paste selected entry to editor")
            .disabled(selectedEntry == nil)
            
            Button(action: { showClearAllAlert = true }) {
                Label("Clear All", systemImage: "trash")
            }
            .help("Clear all clipboard entries")
            .foregroundStyle(DesignSystem.Colors.error)
            .disabled(viewModel.filteredEntries.isEmpty)
        }
    }
}

// MARK: - Subviews

private struct ClipboardEntryCard: View {
    let entry: ClipboardEntry
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: entryTypeIcon)
                    .foregroundStyle(entryTypeColor)
                    .font(DesignSystem.Typography.title3)
                
                Text(entry.name)
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.dateFormatted)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
            
            if let description = entry.description, !description.isEmpty {
                Text(description)
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                
                Text(entry.sizeDescription)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
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
    
    private var entryTypeIcon: String {
        switch entry.type {
        case .program: return "slider.horizontal.3"
        case .oscillator: return "waveform"
        case .filter: return "line.3.horizontal"
        case .envelope: return "chart.line.uptrend.xyaxis"
        case .lfo: return "waveform.sine"
        case .matrixSlot: return "square.grid.3x3"
        case .effects: return "speaker.wave.2"
        case .globalSettings: return "gearshape"
        case .mixer: return "slider.horizontal.2"
        }
    }
    
    private var entryTypeColor: Color {
        switch entry.type {
        case .program: return DesignSystem.Colors.accentPurple
        case .oscillator: return DesignSystem.Colors.primary
        case .filter: return DesignSystem.Colors.accentPurple
        case .envelope: return DesignSystem.Colors.accentGreen
        case .lfo: return DesignSystem.Colors.accentOrange
        case .matrixSlot: return DesignSystem.Colors.primary
        case .effects: return DesignSystem.Colors.accentPurple
        case .globalSettings: return DesignSystem.Colors.accentOrange
        case .mixer: return DesignSystem.Colors.accentGreen
        }
    }
}

private struct EntryContextMenu: View {
    let entry: ClipboardEntry
    @ObservedObject var viewModel: ClipboardViewModel
    
    var body: some View {
        Group {
            Button(action: { viewModel.renameEntry(entry) }) {
                Label("Rename", systemImage: "pencil")
            }
            
            Button(action: { viewModel.duplicateEntry(entry) }) {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Divider()
            
            Button(action: { viewModel.deleteEntry(entry) }) {
                Label("Delete", systemImage: "trash")
            }
            .foregroundStyle(DesignSystem.Colors.error)
        }
    }
}

// MARK: - Preview

#Preview {
    ClipboardView()
        .frame(width: 1000, height: 700)
}
