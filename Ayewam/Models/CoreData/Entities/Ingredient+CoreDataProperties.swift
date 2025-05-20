//
//  Ingredient+CoreDataProperties.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//
//

import Foundation
import CoreData


extension Ingredient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ingredient> {
        return NSFetchRequest<Ingredient>(entityName: "Ingredient")
    }

    @NSManaged public var name: String?
    @NSManaged public var quantity: Double
    @NSManaged public var unit: String?
    @NSManaged public var notes: String?
    @NSManaged public var orderIndex: Int16
    @NSManaged public var recipe: Recipe?

}

extension Ingredient : Identifiable {

}
