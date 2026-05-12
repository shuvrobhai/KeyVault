//
//  ContentView.swift
//  KeyVaultApp
//
//  Created by Rayhan Islam Shuvro on 5/12/26.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: ProfileStore
    @State private var selectedProfileID: UUID?
    @State private var showFirstRunHelp = false
    
    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .onAppear {
            if store.sourceLineInstruction().contains("[ -f ~/.env-switcher") {
                showFirstRunHelp = true
            }
        }
        .alert("Almost done", isPresented: $showFirstRunHelp) {
            Button("Copy line") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString("[ -f ~/.env-switcher/exports ] && source ~/.env-switcher/exports", forType: .string)
            }
            Button("OK") { }
        } message: {
            Text("""
                Add this line to your ~/.zshrc:
                
                [ -f ~/.env-switcher/exports ] && source ~/.env-switcher/exports
                
                New terminal sessions will use the active profile.
                """)
        }
    }
    
    // MARK: - Sidebar
    
    var sidebar: some View {
        List(selection: $selectedProfileID) {
            ForEach(store.profiles) { profile in
                HStack {
                    Text(profile.name)
                    if profile.id == store.activeProfileID {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .tag(profile.id)
            }
            .onDelete(perform: deleteProfiles)
        }
        .toolbar {
            ToolbarItem {
                Button(action: addProfile) {
                    Label("Add Profile", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Profiles")
    }
    
    // MARK: - Detail
    
    @ViewBuilder
    var detailView: some View {
        if let profile = bindingForSelectedProfile() {
            VStack(alignment: .leading, spacing: 16) {
                // Profile name
                TextField("Profile Name", text: profile.name)
                    .font(.title)
                    .textFieldStyle(.plain)
                    .padding(.bottom, 8)
                
                Divider()
                
                // Variables editor
                Text("Environment Variables")
                    .font(.headline)
                
                List {
                    ForEach(profile.variables) { $variable in
                        variableRow(variable: $variable, profile: profile)
                    }
                    .onDelete { indexSet in
                        deleteVariables(in: profile.wrappedValue, offsets: indexSet)
                    }
                    
                    Button(action: { addVariable(to: profile.wrappedValue) }) {
                        Label("Add Variable", systemImage: "plus")
                    }
                }
                
                Spacer()
                
                // Activate button
                HStack {
                    if profile.wrappedValue.id == store.activeProfileID {
                        Label("Active", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("Activate") {
                            store.activate(profile.wrappedValue)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else {
            VStack {
                Text("Select a profile")
                    .foregroundColor(.secondary)
                Text("or create one with the + button")
                    .font(.caption)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func bindingForSelectedProfile() -> Binding<Profile>? {
        guard let id = selectedProfileID,
              let index = store.profiles.firstIndex(where: { $0.id == id }) else {
            // Fallback to first profile if none selected but profiles exist
            if !store.profiles.isEmpty && selectedProfileID == nil {
                DispatchQueue.main.async {
                    selectedProfileID = store.profiles.first?.id
                }
            }
            return nil
        }
        return $store.profiles[index]
    }
    
    private func addProfile() {
        store.addProfile(name: "New Profile")
        if let last = store.profiles.last {
            selectedProfileID = last.id
        }
    }
    
    private func deleteProfiles(offsets: IndexSet) {
        for index in offsets {
            store.deleteProfile(store.profiles[index])
        }
        // Reset selection if needed
        if let id = selectedProfileID, !store.profiles.contains(where: { $0.id == id }) {
            selectedProfileID = nil
        }
    }
    
    private func addVariable(to profile: Profile) {
        store.addVariable(to: profile.id, key: "KEY", value: "VALUE")
    }
    
    private func deleteVariables(in profile: Profile, offsets: IndexSet) {
        for index in offsets {
            let variable = profile.variables[index]
            store.deleteVariable(from: profile.id, variableID: variable.id)
        }
    }
    
    private func variableRow(variable: Binding<Profile.EnvVariable>,
                             profile: Binding<Profile>) -> some View {
        HStack {
            TextField("Key", text: variable.key)
                .frame(width: 120)
            TextField("Value", text: variable.value)
                .frame(minWidth: 200)
        }
        .onChange(of: variable.wrappedValue) { _, _ in
            store.updateProfile(profile.wrappedValue)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ProfileStore())
}
