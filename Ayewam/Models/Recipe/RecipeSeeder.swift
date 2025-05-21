//
//  RecipeSeeder.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class RecipeSeeder {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func seedDefaultRecipesIfNeeded() {
        let count = try? context.count(for: Recipe.fetchRequest())
        
        if count == 0 {
            createCategories()
            createRecipes()
            
            do {
                try context.save()
                print("Successfully seeded default recipes")
            } catch {
                print("Failed to seed recipes: \(error)")
                context.rollback()
            }
        }
    }
    
    private func createCategories() {
        // Create Ghanaian recipe categories
        createCategory(name: "Soups", colorHex: "#E57373", imageName: "category_soups")
        createCategory(name: "Stews", colorHex: "#FFB74D", imageName: "category_stews")
        createCategory(name: "Rice Dishes", colorHex: "#FFF176", imageName: "category_rice")
        createCategory(name: "Street Food", colorHex: "#81C784", imageName: "category_street")
        createCategory(name: "Breakfast", colorHex: "#4FC3F7", imageName: "category_breakfast")
        createCategory(name: "Desserts", colorHex: "#BA68C8", imageName: "category_desserts")
        createCategory(name: "Drinks", colorHex: "#4DB6AC", imageName: "category_drinks")
        createCategory(name: "Sides", colorHex: "#A1887F", imageName: "category_sides")
    }
    
    @discardableResult
    private func createCategory(name: String, colorHex: String, imageName: String?) -> Category {
        let category = Category(context: context)
        category.name = name
        category.colorHex = colorHex
        category.imageName = imageName
        return category
    }
    
    private func createRecipes() {
        // Get created categories
        let soups = fetchCategory(name: "Soups")
//        let stews = fetchCategory(name: "Stews")
        let riceDishes = fetchCategory(name: "Rice Dishes")
        //TODO: justynx fetch other categories similarly
        
        //TODO: justynx initial recipes (examples)
        // 1. Light Soup (Nkrakra)
        let lightSoup = createRecipe(
            id: "light_soup",
            name: "Light Soup (Nkrakra)",
            description: "A delicious clear soup made with meat and aromatic herbs, popular across Ghana.",
            prepTime: 20,
            cookTime: 60,
            servings: 4,
            difficulty: "Medium",
            region: "Nationwide",
            imageName: "light_soup",
            category: soups
        )
        
        //TODO: justynx add ingredients for Light Soup
        createIngredient(name: "Goat meat or chicken", quantity: 500, unit: "g", notes: "Cut into pieces", orderIndex: 0, recipe: lightSoup)
        createIngredient(name: "Onion", quantity: 1, unit: "medium", notes: "Chopped", orderIndex: 1, recipe: lightSoup)
        createIngredient(name: "Tomatoes", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 2, recipe: lightSoup)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 3, recipe: lightSoup)
        createIngredient(name: "Garlic", quantity: 2, unit: "cloves", notes: "Minced", orderIndex: 4, recipe: lightSoup)
        createIngredient(name: "Chili pepper", quantity: 1, unit: "small", notes: "Or to taste", orderIndex: 5, recipe: lightSoup)
        createIngredient(name: "Water", quantity: 1.5, unit: "liters", notes: nil, orderIndex: 6, recipe: lightSoup)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 7, recipe: lightSoup)
        
        //TODO: justynx add steps for Light Soup
        createStep(instruction: "In a pot, boil the meat with salt, half the onion, and a little ginger until tender.", duration: 1800, imageName: "light_soup_step1", orderIndex: 0, recipe: lightSoup)
        createStep(instruction: "In a blender, blend the remaining onion, tomatoes, ginger, garlic, and chili pepper.", duration: 120, imageName: "light_soup_step2", orderIndex: 1, recipe: lightSoup)
        createStep(instruction: "Add the blended mixture to the pot with the meat and bring to a boil.", duration: 300, imageName: "light_soup_step3", orderIndex: 2, recipe: lightSoup)
        createStep(instruction: "Reduce heat and simmer for 15-20 minutes until the flavors meld.", duration: 1200, imageName: "light_soup_step4", orderIndex: 3, recipe: lightSoup)
        createStep(instruction: "Adjust seasoning to taste and serve hot with fufu or rice balls.", duration: 60, imageName: "light_soup_step5", orderIndex: 4, recipe: lightSoup)
        
        // 2. Jollof Rice
        let jollofRice = createRecipe(
            id: "jollof_rice",
            name: "Jollof Rice",
            description: "A one-pot rice dish popular throughout West Africa, with a distinct Ghanaian preparation style.",
            prepTime: 15,
            cookTime: 45,
            servings: 6,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "jollof_rice",
            category: riceDishes
        )
        
        // Add ingredients for Jollof Rice
        createIngredient(name: "Long grain rice", quantity: 3, unit: "cups", notes: "Washed and drained", orderIndex: 0, recipe: jollofRice)
        createIngredient(name: "Vegetable oil", quantity: 0.25, unit: "cup", notes: nil, orderIndex: 1, recipe: jollofRice)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Finely chopped", orderIndex: 2, recipe: jollofRice)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 3, recipe: jollofRice)
        createIngredient(name: "Canned tomatoes", quantity: 400, unit: "g", notes: "Or 4 fresh tomatoes, blended", orderIndex: 4, recipe: jollofRice)
        createIngredient(name: "Chicken stock", quantity: 3, unit: "cups", notes: "Or vegetable stock", orderIndex: 5, recipe: jollofRice)
        createIngredient(name: "Bay leaves", quantity: 2, unit: "", notes: nil, orderIndex: 6, recipe: jollofRice)
        createIngredient(name: "Curry powder", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 7, recipe: jollofRice)
        createIngredient(name: "Thyme", quantity: 0.5, unit: "teaspoon", notes: "Dried", orderIndex: 8, recipe: jollofRice)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 9, recipe: jollofRice)
        
        // Add steps for Jollof Rice
        createStep(instruction: "Heat oil in a large pot over medium heat. Add onions and sauté until translucent.", duration: 300, imageName: "jollof_step1", orderIndex: 0, recipe: jollofRice)
        createStep(instruction: "Add tomato paste and stir for 2-3 minutes until it darkens slightly.", duration: 180, imageName: "jollof_step2", orderIndex: 1, recipe: jollofRice)
        createStep(instruction: "Add canned tomatoes, curry powder, thyme, bay leaves, and salt. Simmer for 5 minutes.", duration: 300, imageName: "jollof_step3", orderIndex: 2, recipe: jollofRice)
        createStep(instruction: "Add the washed rice and stir to coat with the sauce.", duration: 60, imageName: "jollof_step4", orderIndex: 3, recipe: jollofRice)
        createStep(instruction: "Pour in the stock, stir once, and bring to a boil.", duration: 300, imageName: "jollof_step5", orderIndex: 4, recipe: jollofRice)
        createStep(instruction: "Reduce heat to low, cover the pot with foil and then the lid to trap steam.", duration: 30, imageName: "jollof_step6", orderIndex: 5, recipe: jollofRice)
        createStep(instruction: "Cook for 30 minutes or until rice is tender. Fluff with a fork before serving.", duration: 1800, imageName: "jollof_step7", orderIndex: 6, recipe: jollofRice)
        
    }
    
    private func createRecipe(id: String, name: String, description: String?, prepTime: Int32?, cookTime: Int32?, servings: Int16?, difficulty: String?, region: String?, imageName: String?, category: Category?) -> Recipe {
        let recipe = Recipe(context: context)
        recipe.id = id
        recipe.name = name
        recipe.recipeDescription = description
        recipe.prepTime = prepTime ?? 0
        recipe.cookTime = cookTime ?? 0
        recipe.servings = servings ?? 0
        recipe.difficulty = difficulty
        recipe.region = region
        recipe.imageName = imageName
        recipe.isFavorite = false
        
        if let category = category {
            recipe.addToCategory(category)
        }
        
        return recipe
    }
    
    @discardableResult
    private func createIngredient(name: String, quantity: Double?, unit: String?, notes: String?, orderIndex: Int16, recipe: Recipe) -> Ingredient {
        let ingredient = Ingredient(context: context)
        ingredient.name = name
        ingredient.quantity = quantity ?? 0
        ingredient.unit = unit
        ingredient.notes = notes
        ingredient.orderIndex = orderIndex
        ingredient.recipe = recipe
        return ingredient
    }
    
    @discardableResult
    private func createStep(instruction: String, duration: Int32?, imageName: String?, orderIndex: Int16, recipe: Recipe) -> Step {
        let step = Step(context: context)
        step.instruction = instruction
        step.duration = duration ?? 0
        step.imageName = imageName
        step.orderIndex = orderIndex
        step.recipe = recipe
        return step
    }
    
    private func fetchCategory(name: String) -> Category? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching category: \(error)")
            return nil
        }
    }
}
