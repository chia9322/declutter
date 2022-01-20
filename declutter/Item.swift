//
//  Item.swift
//  Declutter
//
//  Created by Chia on 2022/01/12.
//

import Foundation


struct Item: Codable {
    var name: String
    var date: String
    var imageName: String
    var memo: String
    
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func saveItems(_ items: [Self]) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(items)
        let url = documentDirectory.appendingPathComponent("items")
        try? data?.write(to: url)
    }
    
    static func loadItems() -> [Self]? {
        let decoder = JSONDecoder()
        let url = documentDirectory.appendingPathComponent("items")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? decoder.decode([Self].self, from: data)
    }
}
