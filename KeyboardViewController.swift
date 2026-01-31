// KeyboardViewController.swift
// Minimal custom keyboard extension using UIKit
// Uses ClipboardManager for shared clipboard access

import UIKit

class KeyboardViewController: UIInputViewController {
    private var clipboardItems: [ClipboardItem] = []
    private let clipboardButton = UIButton(type: .system)
    private let copyAndSaveButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        reloadClipboardItems()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -8)
        ])
        
        copyAndSaveButton.setTitle("Copy & Save", for: .normal)
        copyAndSaveButton.addTarget(self, action: #selector(copyAndSaveTapped), for: .touchUpInside)
        stackView.addArrangedSubview(copyAndSaveButton)
        
        clipboardButton.setTitle("Show Clipboard", for: .normal)
        clipboardButton.addTarget(self, action: #selector(showClipboardTapped), for: .touchUpInside)
        stackView.addArrangedSubview(clipboardButton)
    }
    
    private func reloadClipboardItems() {
        clipboardItems = ClipboardManager.shared.loadItems()
        // In a real UI, update the list of items here
    }
    
    @objc private func copyAndSaveTapped() {
        if let context = textDocumentProxy.documentContextBeforeInput, !context.isEmpty {
            ClipboardManager.shared.saveItem(context)
            reloadClipboardItems()
        }
    }
    
    @objc private func showClipboardTapped() {
        // For MVP: insert the most recent item
        guard let first = clipboardItems.first else { return }
        textDocumentProxy.insertText(first.content)
    }
}
