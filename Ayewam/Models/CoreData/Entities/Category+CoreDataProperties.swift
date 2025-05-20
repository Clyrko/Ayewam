//
//  Category+CoreDataProperties.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var imageName: String?
    @NSManaged public var recipes: Recipe?

}

extension Category : Identifiable {

}
