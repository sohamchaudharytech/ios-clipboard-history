// ClipboardListView.swift
// SwiftUI view for displaying clipboard history

import SwiftUI

struct ClipboardListView: View {
    @State private var items: [ClipboardItem] = ClipboardManager.shared.loadItems()
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.content)
                            .font(.body)
                            .lineLimit(2)
                        Text(item.createdAt, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Clipboard History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addFromClipboard) {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Clipboard Empty"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear(perform: reload)
    }
    
    private func reload() {
        items = ClipboardManager.shared.loadItems()
    }
    
    private func addFromClipboard() {
        if let string = UIPasteboard.general.string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ClipboardManager.shared.saveItem(string)
            reload()
        } else {
            alertMessage = "There is no text in the clipboard."
            showAlert = true
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            ClipboardManager.shared.deleteItem(items[index])
        }
        reload()
    }
}

// Preview
struct ClipboardListView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardListView()
    }
}
