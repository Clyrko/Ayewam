//
//  Step+CoreDataProperties.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//
//

import Foundation
import CoreData


extension Step {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Step> {
        return NSFetchRequest<Step>(entityName: "Step")
    }

    @NSManaged public var orderIndex: Int16
    @NSManaged public var instruction: String?
    @NSManaged public var duration: Int32
    @NSManaged public var imageName: String?
    @NSManaged public var recipe: Recipe?

}

extension Step : Identifiable {

}
