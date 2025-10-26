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
}
