//
//  KeyboardViewController.swift
//  ClipboardKeyboard
//
//  Created by Soham Chaudhary on 31/01/26.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    private let stackView = UIStackView()
    private let copyAndSaveButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let itemsStack = UIStackView()
    private var clipboardItems: [ClipboardItem] = []
    private let nextKeyboardButton = UIButton(type: .system)

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

        // Copy & Save button
        copyAndSaveButton.setTitle("Copy & Save", for: .normal)
        copyAndSaveButton.addTarget(self, action: #selector(copyAndSaveTapped), for: .touchUpInside)
        stackView.addArrangedSubview(copyAndSaveButton)

        // Scrollable clipboard items
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        stackView.addArrangedSubview(scrollView)
        itemsStack.axis = .vertical
        itemsStack.spacing = 4
        itemsStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(itemsStack)

        // Next Keyboard button
        nextKeyboardButton.setTitle("Next Keyboard", for: .normal)
        nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        stackView.addArrangedSubview(nextKeyboardButton)

        // Layout
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            scrollView.heightAnchor.constraint(equalToConstant: 120),
            itemsStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            itemsStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            itemsStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            itemsStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            itemsStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func reloadClipboardItems() {
        clipboardItems = ClipboardManager.shared.loadItems()
        for view in itemsStack.arrangedSubviews { view.removeFromSuperview() }
        for item in clipboardItems {
            let button = UIButton(type: .system)
            button.setTitle(item.content, for: .normal)
            button.contentHorizontalAlignment = .left
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.addTarget(self, action: #selector(pasteItemTapped(_:)), for: .touchUpInside)
            button.tag = clipboardItems.firstIndex(of: item) ?? 0
            // Long-press to delete
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(deleteItemLongPress(_:)))
            button.addGestureRecognizer(longPress)
            itemsStack.addArrangedSubview(button)
        }
    }

    @objc private func copyAndSaveTapped() {
        // Only allow user-initiated clipboard read
        if let string = UIPasteboard.general.string, !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ClipboardManager.shared.saveItem(string)
            reloadClipboardItems()
        } else {
            // Optionally show a message (not implemented in MVP)
        }
    }

    @objc private func pasteItemTapped(_ sender: UIButton) {
        let index = sender.tag
        guard clipboardItems.indices.contains(index) else { return }
        let item = clipboardItems[index]
        textDocumentProxy.insertText(item.content)
    }

    @objc private func deleteItemLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let button = gesture.view as? UIButton else { return }
        let index = button.tag
        guard clipboardItems.indices.contains(index) else { return }
        let item = clipboardItems[index]
        ClipboardManager.shared.deleteItem(item)
        reloadClipboardItems()
    }

    override func viewWillLayoutSubviews() {
        nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
}
