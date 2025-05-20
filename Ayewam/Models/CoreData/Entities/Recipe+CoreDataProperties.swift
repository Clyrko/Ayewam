//
//  Recipe+CoreDataProperties.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//
//

import Foundation
import CoreData


extension Recipe {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var recipeDescription: String?
    @NSManaged public var prepTime: Int32
    @NSManaged public var cookTime: Int32
    @NSManaged public var servings: Int16
    @NSManaged public var difficulty: String?
    @NSManaged public var region: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var imageName: String?
    @NSManaged public var ingredients: NSSet?
    @NSManaged public var steps: NSSet?
    @NSManaged public var category: Category?

}

// MARK: Generated accessors for ingredients
extension Recipe {

    @objc(addIngredientsObject:)
    @NSManaged public func addToIngredients(_ value: Ingredient)

    @objc(removeIngredientsObject:)
    @NSManaged public func removeFromIngredients(_ value: Ingredient)

    @objc(addIngredients:)
    @NSManaged public func addToIngredients(_ values: NSSet)

    @objc(removeIngredients:)
    @NSManaged public func removeFromIngredients(_ values: NSSet)

}

// MARK: Generated accessors for steps
extension Recipe {

    @objc(addStepsObject:)
    @NSManaged public func addToSteps(_ value: Step)

    @objc(removeStepsObject:)
    @NSManaged public func removeFromSteps(_ value: Step)

    @objc(addSteps:)
    @NSManaged public func addToSteps(_ values: NSSet)

    @objc(removeSteps:)
    @NSManaged public func removeFromSteps(_ values: NSSet)

}

extension Recipe : Identifiable {

}
