//  AddPlantView.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import SwiftUI

struct AddPlantView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var species: String = ""
    @State private var description: String = ""
    @State private var emoji: String = "🪴"

    var onSave: (Plant) -> Void

    // Small curated emoji list for quick selection
    private let emojiChoices: [String] = ["🪴","🌿","🌱","🌵","🍃","🌸","🎋","🍀","🌻","🌼","🌺","🥀","🌴","🪻","🌾"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic")) {
                    TextField("Name", text: $name)
                    TextField("Species", text: $species)

                    HStack {
                        TextField("Emoji (e.g. 🪴)", text: $emoji)
                            .frame(width: 120)
                        Spacer()
                        Text(emoji)
                            .font(.largeTitle)
                    }

                    // Emoji picker: horizontal scroll of tappable emoji buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojiChoices, id: \.self) { item in
                                Button(action: {
                                    emoji = item
                                }) {
                                    Text(item)
                                        .font(.system(size: 28))
                                        .frame(width: 44, height: 44)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(item == emoji ? Color.green.opacity(0.2) : Color.clear)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(item == emoji ? Color.green : Color.clear, lineWidth: 1)
                                        )
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(Text("Select emoji \(item)"))
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section(header: Text("Notes")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Plant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let plant = Plant(name: name.trimmingCharacters(in: .whitespacesAndNewlines), species: species.trimmingCharacters(in: .whitespacesAndNewlines), description: description.trimmingCharacters(in: .whitespacesAndNewlines), emoji: emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "🪴" : emoji.trimmingCharacters(in: .whitespacesAndNewlines))
                        onSave(plant)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddPlantView { _ in }
}
