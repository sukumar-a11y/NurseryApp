//  Plant.swift
//  NurseryApp
//
//  Created by Sumit Kumar on 2025/10/24.
//  Copyright © 2025 YourCompany. All rights reserved.

import Foundation

public struct Plant: Identifiable, Hashable, Codable {
    public let id: UUID
    public let name: String
    public let species: String?
    public let description: String?
    public let emoji: String?
    public var isFavorite: Bool

    public init(id: UUID = UUID(), name: String, species: String? = nil, description: String? = nil, emoji: String? = "🪴", isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.species = species
        self.description = description
        self.emoji = emoji
        self.isFavorite = isFavorite
    }

    // Factory that mirrors the trimming and defaulting logic used by AddPlantView's Save action
    public static func fromInput(name: String, species: String, description: String, emoji: String) -> Plant {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSpecies = species.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmoji = emoji.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "🪴" : emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        return Plant(name: trimmedName, species: trimmedSpecies.isEmpty ? nil : trimmedSpecies, description: trimmedDescription.isEmpty ? nil : trimmedDescription, emoji: trimmedEmoji)
    }
}
