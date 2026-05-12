import Foundation
import Observation
import SwiftUI

// MARK: - Models

struct Profile: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var variables: [EnvVariable] = []
    
    struct EnvVariable: Identifiable, Codable, Equatable {
        var id = UUID()
        var key: String
        var value: String
    }
}

// MARK: - Store (Observation framework)

@Observable
final class ProfileStore {
    var profiles: [Profile] = []
    var activeProfileID: UUID?
    
    private let storageDir: URL
    private let profilesFile: URL
    private let exportsFile: URL

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        storageDir = home.appendingPathComponent(".env-switcher")
        try? FileManager.default.createDirectory(at: storageDir,
                                                 withIntermediateDirectories: true)
        profilesFile = storageDir.appendingPathComponent("profiles.json")
        exportsFile = storageDir.appendingPathComponent("exports")
        
        print(">>> ProfileStore init. storageDir = \(storageDir.path)")
        
        loadProfiles()
        loadActiveProfileID()
    }
    
    // MARK: - Persistence
    
    private func loadProfiles() {
        guard let data = try? Data(contentsOf: profilesFile) else {
            profiles = []
            return
        }
        do {
            profiles = try JSONDecoder().decode([Profile].self, from: data)
        } catch {
            print("Failed to decode profiles: \(error)")
            profiles = []
        }
    }
    
    private func saveProfiles() {
        do {
            let data = try JSONEncoder().encode(profiles)
            try data.write(to: profilesFile, options: .atomic)
        } catch {
            print("Failed to save profiles: \(error)")
        }
    }
    
    private func loadActiveProfileID() {
        if let uuidString = UserDefaults.standard.string(forKey: "activeProfileID"),
           let uuid = UUID(uuidString: uuidString) {
            activeProfileID = uuid
        }
    }
    
    private func saveActiveProfileID() {
        UserDefaults.standard.set(activeProfileID?.uuidString, forKey: "activeProfileID")
    }
    
    // MARK: - Profile CRUD
    
    func addProfile(name: String) {
        let newProfile = Profile(name: name)
        profiles.append(newProfile)
        saveProfiles()
    }
    
    func deleteProfile(_ profile: Profile) {
        if profile.id == activeProfileID {
            deactivateAll()
        }
        profiles.removeAll { $0.id == profile.id }
        saveProfiles()
    }
    
    func updateProfile(_ profile: Profile) {
        guard let index = profiles.firstIndex(where: { $0.id == profile.id }) else { return }
        profiles[index] = profile
        saveProfiles()
        if profile.id == activeProfileID {
            writeExports(for: profile)
        }
    }
    
    // MARK: - Variable CRUD
    
    func addVariable(to profileID: UUID, key: String, value: String) {
        guard let index = profiles.firstIndex(where: { $0.id == profileID }) else { return }
        profiles[index].variables.append(.init(key: key, value: value))
        saveProfiles()
        if profileID == activeProfileID {
            writeExports(for: profiles[index])
        }
    }
    
    func deleteVariable(from profileID: UUID, variableID: UUID) {
        guard let index = profiles.firstIndex(where: { $0.id == profileID }) else { return }
        profiles[index].variables.removeAll { $0.id == variableID }
        saveProfiles()
        if profileID == activeProfileID {
            writeExports(for: profiles[index])
        }
    }
    
    // MARK: - Activation
    
    func activate(_ profile: Profile) {
        activeProfileID = profile.id
        saveActiveProfileID()
        writeExports(for: profile)
    }
    
    private func deactivateAll() {
        activeProfileID = nil
        saveActiveProfileID()
        try? "".write(to: exportsFile, atomically: true, encoding: .utf8)
    }
    
    private func writeExports(for profile: Profile) {
        var lines = """
        # KeyVault managed exports – do not edit by hand
        # Profile: \(profile.name)
        
        """
        for variable in profile.variables where !variable.key.isEmpty {
            let escapedValue = variable.value
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
            lines += "export \(variable.key)=\"\(escapedValue)\"\n"
        }
        do {
            try lines.write(to: exportsFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write exports: \(error)")
        }
    }
    
    // MARK: - First‑run helper
    
    var needsSourceLine: Bool { true }
    
    func sourceLineInstruction() -> String {
        """
        To use KeyVault, add this line to your ~/.zshrc:

            [ -f ~/.env-switcher/exports ] && source ~/.env-switcher/exports
        
        New terminal sessions will then load your active profile.
        """
    }
}
