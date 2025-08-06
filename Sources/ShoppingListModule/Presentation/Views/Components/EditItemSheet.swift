//
//  EditItemSheet.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI

/// Sheet for editing existing shopping items
public struct EditItemSheet: View {
    let item: ShoppingItem
    let onSave: (String, Int, String?) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var quantity: Int
    @State private var note: String
    
    public init(item: ShoppingItem, onSave: @escaping (String, Int, String?) -> Void) {
        self.item = item
        self.onSave = onSave
        self._name = State(initialValue: item.name)
        self._quantity = State(initialValue: item.quantity)
        self._note = State(initialValue: item.note ?? "")
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Item name", text: $name)
                    
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                    
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(name, quantity, note.isEmpty ? nil : note)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #else
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, quantity, note.isEmpty ? nil : note)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #endif
            }
        }
    }
}

