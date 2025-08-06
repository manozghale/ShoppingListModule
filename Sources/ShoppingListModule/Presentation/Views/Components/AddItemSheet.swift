//
//  AddItemSheet.swift
//  ShoppingListModule
//
//  Created by Manoj on 06/08/2025.
//

import SwiftUI

/// Sheet for adding new shopping items
public struct AddItemSheet: View {
    @ObservedObject var viewModel: ShoppingListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var quantity = 1
    @State private var note = ""
    
    public init(viewModel: ShoppingListViewModel) {
        self.viewModel = viewModel
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
            .navigationTitle("Add Item")
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
                    Button("Add") {
                        Task {
                            await viewModel.addItem(name: name, quantity: quantity, note: note.isEmpty ? nil : note)
                            dismiss()
                        }
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
                    Button("Add") {
                        Task {
                            await viewModel.addItem(name: name, quantity: quantity, note: note.isEmpty ? nil : note)
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                #endif
            }
        }
    }
}

