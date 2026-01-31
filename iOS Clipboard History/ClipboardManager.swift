// ClipboardManager.swift
// Shared clipboard manager for app and extension
// Uses App Group UserDefaults for secure, Apple-compliant data sharing

import Foundation

struct ClipboardItem: Codable, Identifiable, Equatable {
    let id: UUID
    let content: String
    let createdAt: Date
}

final class ClipboardManager {
    static let appGroupID = "group.com.yourcompany.clipboardhistory" // <-- Replace with your actual group ID
    static let shared = ClipboardManager()
    private let userDefaults: UserDefaults?
    private let maxItems = 20
    private let storageKey = "clipboardItems"

    private init() {
        userDefaults = UserDefaults(suiteName: ClipboardManager.appGroupID)
    }

    func loadItems() -> [ClipboardItem] {
        guard let data = userDefaults?.data(forKey: storageKey) else { return [] }
        return (try? JSONDecoder().decode([ClipboardItem].self, from: data)) ?? []
    }

    func saveItem(_ content: String) {
        var items = loadItems()
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        // Remove duplicates
        items.removeAll { $0.content == trimmed }
        // Insert new item at top
        let newItem = ClipboardItem(id: UUID(), content: trimmed, createdAt: Date())
        items.insert(newItem, at: 0)
        // Limit to maxItems
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        saveItems(items)
    }

    func deleteItem(_ item: ClipboardItem) {
        var items = loadItems()
        items.removeAll { $0.id == item.id }
        saveItems(items)
    }

    private func saveItems(_ items: [ClipboardItem]) {
        guard let data = try? JSONEncoder().encode(items) else { return }
        userDefaults?.set(data, forKey: storageKey)
    }
}
