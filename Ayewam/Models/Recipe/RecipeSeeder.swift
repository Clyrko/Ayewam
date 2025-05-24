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
        //TODO: justynx Increment this for each update
        let currentVersion = "1.2"
        let lastSeededVersion = UserDefaults.standard.string(forKey: "lastSeededVersion")
        
        let count = try? context.count(for: Recipe.fetchRequest())
        
        // Force reseed if version changed or no recipes exist
        if lastSeededVersion != currentVersion || count == 0 {
            print("justynx 🌱 Seeding recipes - Current: \(currentVersion), Last: \(lastSeededVersion ?? "none"), Count: \(count ?? 0)")
            
            // Clear existing recipes if version changed
            if lastSeededVersion != currentVersion && count ?? 0 > 0 {
                clearAllRecipes()
            }
            
            createCategories()
            createRecipes()
            
            do {
                try context.save()
                UserDefaults.standard.set(currentVersion, forKey: "lastSeededVersion")
                print("justynx ✅ Successfully seeded recipes for version \(currentVersion)")
            } catch {
                print("justynx ❌ Failed to seed recipes: \(error)")
                context.rollback()
            }
        } else {
            print("justynx ℹ️ Recipes already seeded - Version: \(currentVersion), Count: \(count ?? 0)")
        }
    }

    // Clear existing recipes if version changed
    private func clearAllRecipes() {
        do {
            let recipes = try context.fetch(Recipe.fetchRequest())
            let categories = try context.fetch(Category.fetchRequest())
            
            recipes.forEach { context.delete($0) }
            categories.forEach { context.delete($0) }
            
            try context.save()
            print("justynx 🗑️ Cleared existing recipes and categories")
        } catch {
            print("justynx ❌ Error clearing recipes: \(error)")
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
            imageName: "lightSoup",
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
            description: "**A one-pot rice dish popular throughout West Africa, with a distinct Ghanaian preparation style.",
            prepTime: 15,
            cookTime: 45,
            servings: 6,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "jollofRice",
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
        
        // RED RED
        let redRed = createRecipe(
            id: "red_red",
            name: "Red Red",
            description: "A popular Ghanaian dish made with black-eyed beans cooked in palm oil and spices, usually served with fried plantains.",
            prepTime: 15,
            cookTime: 45,
            servings: 4,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "redRed",
            category: fetchCategory(name: "Street Food")
        )

        createIngredient(name: "Black-eyed beans", quantity: 2, unit: "cups", notes: "Dried, soaked overnight", orderIndex: 0, recipe: redRed)
        createIngredient(name: "Palm oil", quantity: 0.25, unit: "cup", notes: nil, orderIndex: 1, recipe: redRed)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 2, recipe: redRed)
        createIngredient(name: "Tomatoes", quantity: 3, unit: "medium", notes: "Chopped", orderIndex: 3, recipe: redRed)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 4, recipe: redRed)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 5, recipe: redRed)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 6, recipe: redRed)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "Or to taste", orderIndex: 7, recipe: redRed)
        createIngredient(name: "Stock cube", quantity: 1, unit: "", notes: nil, orderIndex: 8, recipe: redRed)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 9, recipe: redRed)
        createIngredient(name: "Ripe plantains", quantity: 2, unit: "large", notes: "For serving", orderIndex: 10, recipe: redRed)

        // steps for Red Red
        createStep(instruction: "Boil the soaked black-eyed beans until tender, about 30-40 minutes. Drain and set aside.", duration: 2400, imageName: "red_red_step1", orderIndex: 0, recipe: redRed)
        createStep(instruction: "Heat palm oil in a large pot over medium heat until it becomes clear.", duration: 180, imageName: "red_red_step2", orderIndex: 1, recipe: redRed)
        createStep(instruction: "Add onions and sauté until translucent, about 5 minutes.", duration: 300, imageName: "red_red_step3", orderIndex: 2, recipe: redRed)
        createStep(instruction: "Add tomato paste, ginger, and garlic. Stir for 2 minutes until fragrant.", duration: 120, imageName: "red_red_step4", orderIndex: 3, recipe: redRed)
        createStep(instruction: "Add chopped tomatoes and scotch bonnet pepper. Cook until tomatoes break down, about 10 minutes.", duration: 600, imageName: "red_red_step5", orderIndex: 4, recipe: redRed)
        createStep(instruction: "Add the cooked beans, stock cube, and salt. Simmer for 15 minutes.", duration: 900, imageName: "red_red_step6", orderIndex: 5, recipe: redRed)
        createStep(instruction: "Slice and fry the plantains until golden. Serve the red red hot with fried plantains.", duration: 600, imageName: "red_red_step7", orderIndex: 6, recipe: redRed)
        
        // 4. Palm Nut Soup (Soups)
        let palmNutSoup = createRecipe(
            id: "palm_nut_soup",
            name: "Palm Nut Soup (Abenkwan)",
            description: "A rich, creamy soup made from palm nuts, popular in the Central and Western regions of Ghana.",
            prepTime: 30,
            cookTime: 90,
            servings: 6,
            difficulty: "Medium",
            region: "Central/Western",
            imageName: "palmnutSoup",
            category: soups
        )

        // Add ingredients for Palm Nut Soup
        createIngredient(name: "Fresh palm nuts", quantity: 4, unit: "cups", notes: "Or 2 cups palm nut cream", orderIndex: 0, recipe: palmNutSoup)
        createIngredient(name: "Beef", quantity: 500, unit: "g", notes: "Cut into chunks", orderIndex: 1, recipe: palmNutSoup)
        createIngredient(name: "Smoked fish", quantity: 200, unit: "g", notes: "Cleaned and deboned", orderIndex: 2, recipe: palmNutSoup)
        createIngredient(name: "Dried fish", quantity: 100, unit: "g", notes: "Soaked and cleaned", orderIndex: 3, recipe: palmNutSoup)
        createIngredient(name: "Crab", quantity: 2, unit: "medium", notes: "Cleaned", orderIndex: 4, recipe: palmNutSoup)
        createIngredient(name: "Onion", quantity: 1, unit: "large", notes: "Chopped", orderIndex: 5, recipe: palmNutSoup)
        createIngredient(name: "Tomatoes", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 6, recipe: palmNutSoup)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 7, recipe: palmNutSoup)
        createIngredient(name: "Garlic", quantity: 2, unit: "cloves", notes: "Minced", orderIndex: 8, recipe: palmNutSoup)
        createIngredient(name: "Chili pepper", quantity: 1, unit: "to taste", notes: nil, orderIndex: 9, recipe: palmNutSoup)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 10, recipe: palmNutSoup)

        // Add steps for Palm Nut Soup
        createStep(instruction: "If using fresh palm nuts, boil them for 30 minutes, then pound and extract the cream.", duration: 1800, imageName: "palm_nut_step1", orderIndex: 0, recipe: palmNutSoup)
        createStep(instruction: "Season and boil the beef with half the onion until tender, about 45 minutes.", duration: 2700, imageName: "palm_nut_step2", orderIndex: 1, recipe: palmNutSoup)
        createStep(instruction: "In a separate pot, heat a little oil and sauté remaining onion, tomatoes, ginger, and garlic.", duration: 300, imageName: "palm_nut_step3", orderIndex: 2, recipe: palmNutSoup)
        createStep(instruction: "Add the palm nut cream to the sautéed vegetables and bring to a boil.", duration: 600, imageName: "palm_nut_step4", orderIndex: 3, recipe: palmNutSoup)
        createStep(instruction: "Add the cooked beef with its stock, smoked fish, dried fish, and crab.", duration: 120, imageName: "palm_nut_step5", orderIndex: 4, recipe: palmNutSoup)
        createStep(instruction: "Season with chili pepper and salt. Simmer for 20 minutes until flavors meld.", duration: 1200, imageName: "palm_nut_step6", orderIndex: 5, recipe: palmNutSoup)
        createStep(instruction: "Serve hot with fufu, banku, or rice balls.", duration: 60, imageName: "palm_nut_step7", orderIndex: 6, recipe: palmNutSoup)

        // 5. Waakye (Rice Dishes)
        let waakye = createRecipe(
            id: "waakye",
            name: "Waakye",
            description: "A popular Ghanaian dish of rice and beans cooked together with waakye leaves, giving it a distinctive reddish-brown color. Often served with various accompaniments.",
            prepTime: 20,
            cookTime: 60,
            servings: 6,
            difficulty: "Easy",
            region: "Northern/Nationwide",
            imageName: "waakye",
            category: riceDishes
        )

        // Add ingredients for Waakye
        createIngredient(name: "Jasmine rice", quantity: 2, unit: "cups", notes: "Washed and drained", orderIndex: 0, recipe: waakye)
        createIngredient(name: "Black-eyed beans", quantity: 1, unit: "cup", notes: "Soaked overnight", orderIndex: 1, recipe: waakye)
        createIngredient(name: "Waakye leaves", quantity: 8, unit: "pieces", notes: "Dried leaves, or millet stalks", orderIndex: 2, recipe: waakye)
        createIngredient(name: "Limestone paste", quantity: 0.5, unit: "teaspoon", notes: "Optional, for enhanced color", orderIndex: 3, recipe: waakye)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 4, recipe: waakye)
        createIngredient(name: "Water", quantity: 5, unit: "cups", notes: "For cooking", orderIndex: 5, recipe: waakye)

        // Add steps for Waakye
        createStep(instruction: "Rinse the soaked black-eyed beans and rice separately until water runs clear.", duration: 300, imageName: "waakye_step1", orderIndex: 0, recipe: waakye)
        createStep(instruction: "Boil 3 cups of water with waakye leaves and limestone paste for 15 minutes to extract color.", duration: 900, imageName: "waakye_step2", orderIndex: 1, recipe: waakye)
        createStep(instruction: "Strain the colored water and discard the leaves. Return the reddish water to the pot.", duration: 180, imageName: "waakye_step3", orderIndex: 2, recipe: waakye)
        createStep(instruction: "Add the black-eyed beans to the colored water and cook for 20 minutes until slightly tender.", duration: 1200, imageName: "waakye_step4", orderIndex: 3, recipe: waakye)
        createStep(instruction: "Add the rice and salt, then add remaining water if needed to cover by 1 inch.", duration: 120, imageName: "waakye_step5", orderIndex: 4, recipe: waakye)
        createStep(instruction: "Bring to a boil, then reduce heat to low, cover and simmer for 25-30 minutes until tender.", duration: 1800, imageName: "waakye_step6", orderIndex: 5, recipe: waakye)
        createStep(instruction: "Let rest for 5 minutes, then fluff gently. Serve with stew, fried plantains, boiled eggs, and gari.", duration: 300, imageName: "waakye_step7", orderIndex: 6, recipe: waakye)
        
        let kelewele = createRecipe(
            id: "kelewele",
            name: "Kelewele",
            description: "Spicy fried plantains seasoned with ginger, garlic, and chili pepper. A beloved Ghanaian street food snack.",
            prepTime: 15,
            cookTime: 10,
            servings: 4,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "kelewele",
            category: fetchCategory(name: "Street Food")
        )

        // Add ingredients for Kelewele
        createIngredient(name: "Very ripe plantains", quantity: 4, unit: "large", notes: "Yellow with black spots", orderIndex: 0, recipe: kelewele)
        createIngredient(name: "Fresh ginger", quantity: 2, unit: "thumb-sized", notes: "Grated", orderIndex: 1, recipe: kelewele)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 2, recipe: kelewele)
        createIngredient(name: "Cayenne pepper", quantity: 1, unit: "teaspoon", notes: "Adjust to taste", orderIndex: 3, recipe: kelewele)
        createIngredient(name: "Ground nutmeg", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 4, recipe: kelewele)
        createIngredient(name: "Salt", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 5, recipe: kelewele)
        createIngredient(name: "Vegetable oil", quantity: 2, unit: "cups", notes: "For deep frying", orderIndex: 6, recipe: kelewele)
        createIngredient(name: "Onion powder", quantity: 0.5, unit: "teaspoon", notes: "Optional", orderIndex: 7, recipe: kelewele)

        // Add steps for Kelewele
        createStep(instruction: "Peel plantains and cut into cubes or bite-sized pieces.", duration: 300, imageName: "kelewele_step1", orderIndex: 0, recipe: kelewele)
        createStep(instruction: "In a bowl, mix grated ginger, minced garlic, cayenne pepper, nutmeg, salt, and onion powder.", duration: 180, imageName: "kelewele_step2", orderIndex: 1, recipe: kelewele)
        createStep(instruction: "Toss the plantain pieces with the spice mixture until well coated. Let marinate for 10 minutes.", duration: 600, imageName: "kelewele_step3", orderIndex: 2, recipe: kelewele)
        createStep(instruction: "Heat oil in a deep pot or fryer to 350°F (175°C).", duration: 300, imageName: "kelewele_step4", orderIndex: 3, recipe: kelewele)
        createStep(instruction: "Carefully add plantain pieces to hot oil in batches. Fry for 2-3 minutes until golden brown.", duration: 180, imageName: "kelewele_step5", orderIndex: 4, recipe: kelewele)
        createStep(instruction: "Remove with slotted spoon and drain on paper towels. Serve hot as a snack or side dish.", duration: 120, imageName: "kelewele_step6", orderIndex: 5, recipe: kelewele)

        // 7. Groundnut Soup (Soups)
        let groundnutSoup = createRecipe(
            id: "groundnut_soup",
            name: "Groundnut Soup (Nkatenkwan)",
            description: "A creamy, rich soup made with groundnuts (peanuts), meat, and vegetables. A Northern Ghanaian favorite.",
            prepTime: 25,
            cookTime: 75,
            servings: 6,
            difficulty: "Medium",
            region: "Northern",
            imageName: "groundnutSoup",
            category: soups
        )

        // Add ingredients for Groundnut Soup
        createIngredient(name: "Raw groundnuts (peanuts)", quantity: 2, unit: "cups", notes: "Or 1 cup peanut butter", orderIndex: 0, recipe: groundnutSoup)
        createIngredient(name: "Chicken", quantity: 1, unit: "whole", notes: "Cut into pieces", orderIndex: 1, recipe: groundnutSoup)
        createIngredient(name: "Beef", quantity: 300, unit: "g", notes: "Cut into chunks", orderIndex: 2, recipe: groundnutSoup)
        createIngredient(name: "Smoked fish", quantity: 150, unit: "g", notes: "Cleaned", orderIndex: 3, recipe: groundnutSoup)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 4, recipe: groundnutSoup)
        createIngredient(name: "Tomatoes", quantity: 4, unit: "medium", notes: "Chopped", orderIndex: 5, recipe: groundnutSoup)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 6, recipe: groundnutSoup)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 7, recipe: groundnutSoup)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 8, recipe: groundnutSoup)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "Whole or chopped", orderIndex: 9, recipe: groundnutSoup)
        createIngredient(name: "Palm oil", quantity: 3, unit: "tablespoons", notes: nil, orderIndex: 10, recipe: groundnutSoup)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: nil, orderIndex: 11, recipe: groundnutSoup)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 12, recipe: groundnutSoup)

        // Add steps for Groundnut Soup
        createStep(instruction: "If using raw peanuts, roast them lightly in a dry pan for 5 minutes, then grind to a smooth paste.", duration: 900, imageName: "groundnut_step1", orderIndex: 0, recipe: groundnutSoup)
        createStep(instruction: "Season and boil the chicken and beef with half the onion until tender, about 45 minutes.", duration: 2700, imageName: "groundnut_step2", orderIndex: 1, recipe: groundnutSoup)
        createStep(instruction: "Heat palm oil in a large pot and sauté remaining onions until translucent.", duration: 300, imageName: "groundnut_step3", orderIndex: 2, recipe: groundnutSoup)
        createStep(instruction: "Add tomato paste, ginger, and garlic. Stir for 2 minutes until fragrant.", duration: 120, imageName: "groundnut_step4", orderIndex: 3, recipe: groundnutSoup)
        createStep(instruction: "Add chopped tomatoes and cook until they break down, about 8 minutes.", duration: 480, imageName: "groundnut_step5", orderIndex: 4, recipe: groundnutSoup)
        createStep(instruction: "Mix the groundnut paste with some meat stock to form a smooth cream, then add to the pot.", duration: 300, imageName: "groundnut_step6", orderIndex: 5, recipe: groundnutSoup)
        createStep(instruction: "Add the cooked meat, remaining stock, smoked fish, scotch bonnet pepper, and seasonings.", duration: 180, imageName: "groundnut_step7", orderIndex: 6, recipe: groundnutSoup)
        createStep(instruction: "Simmer for 20 minutes, stirring occasionally. Adjust seasoning and serve with rice balls or fufu.", duration: 1200, imageName: "groundnut_step8", orderIndex: 7, recipe: groundnutSoup)

        // 8. Koko (Breakfast)
        let koko = createRecipe(
            id: "koko",
            name: "Koko (Millet Porridge)",
            description: "A nutritious fermented millet porridge traditionally served for breakfast, often accompanied by koose or bread.",
            prepTime: 10,
            cookTime: 15,
            servings: 4,
            difficulty: "Easy",
            region: "Northern/Nationwide",
            imageName: "koko",
            category: fetchCategory(name: "Breakfast")
        )

        // Add ingredients for Koko
        createIngredient(name: "Millet flour", quantity: 1, unit: "cup", notes: "Fermented, or regular with starter", orderIndex: 0, recipe: koko)
        createIngredient(name: "Water", quantity: 4, unit: "cups", notes: "Room temperature", orderIndex: 1, recipe: koko)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 2, recipe: koko)
        createIngredient(name: "Cloves", quantity: 3, unit: "whole", notes: nil, orderIndex: 3, recipe: koko)
        createIngredient(name: "Nutmeg", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 4, recipe: koko)
        createIngredient(name: "Sugar", quantity: 2, unit: "tablespoons", notes: "Or to taste", orderIndex: 5, recipe: koko)
        createIngredient(name: "Evaporated milk", quantity: 0.5, unit: "cup", notes: "Optional", orderIndex: 6, recipe: koko)
        createIngredient(name: "Salt", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 7, recipe: koko)

        // Add steps for Koko
        createStep(instruction: "In a bowl, gradually mix millet flour with 1 cup of water to form a smooth paste without lumps.", duration: 300, imageName: "koko_step1", orderIndex: 0, recipe: koko)
        createStep(instruction: "Boil remaining 3 cups of water with ginger, cloves, and nutmeg for 5 minutes.", duration: 300, imageName: "koko_step2", orderIndex: 1, recipe: koko)
        createStep(instruction: "Gradually whisk the millet paste into the boiling spiced water.", duration: 120, imageName: "koko_step3", orderIndex: 2, recipe: koko)
        createStep(instruction: "Cook on medium heat, stirring constantly to prevent lumps, for 8-10 minutes until thickened.", duration: 600, imageName: "koko_step4", orderIndex: 3, recipe: koko)
        createStep(instruction: "Add sugar and salt, stir well. Remove cloves if desired.", duration: 60, imageName: "koko_step5", orderIndex: 4, recipe: koko)
        createStep(instruction: "Serve hot in bowls, topped with evaporated milk if using. Accompany with koose or bread.", duration: 120, imageName: "koko_step6", orderIndex: 5, recipe: koko)
        
        // 9. Banku with Tilapia (Sides)
        let bankuTilapia = createRecipe(
            id: "banku_tilapia",
            name: "Banku with Grilled Tilapia",
            description: "Fermented corn and cassava dough served with perfectly seasoned grilled tilapia and spicy pepper sauce.",
            prepTime: 45,
            cookTime: 60,
            servings: 4,
            difficulty: "Medium",
            region: "Ga/Ewe",
            imageName: "bankuTilapia",
            category: fetchCategory(name: "Sides")
        )

        // Add ingredients for Banku with Tilapia
        createIngredient(name: "Corn flour", quantity: 2, unit: "cups", notes: "Fermented or regular", orderIndex: 0, recipe: bankuTilapia)
        createIngredient(name: "Cassava flour", quantity: 1, unit: "cup", notes: nil, orderIndex: 1, recipe: bankuTilapia)
        createIngredient(name: "Water", quantity: 4, unit: "cups", notes: nil, orderIndex: 2, recipe: bankuTilapia)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: "For banku", orderIndex: 3, recipe: bankuTilapia)
        createIngredient(name: "Whole tilapia", quantity: 2, unit: "medium", notes: "Cleaned and scaled", orderIndex: 4, recipe: bankuTilapia)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 5, recipe: bankuTilapia)
        createIngredient(name: "Garlic", quantity: 4, unit: "cloves", notes: "Minced", orderIndex: 6, recipe: bankuTilapia)
        createIngredient(name: "Lemon juice", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 7, recipe: bankuTilapia)
        createIngredient(name: "Black pepper", quantity: 1, unit: "teaspoon", notes: "Ground", orderIndex: 8, recipe: bankuTilapia)
        createIngredient(name: "Curry powder", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 9, recipe: bankuTilapia)
        createIngredient(name: "Vegetable oil", quantity: 2, unit: "tablespoons", notes: "For grilling", orderIndex: 10, recipe: bankuTilapia)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: "For fish seasoning", orderIndex: 11, recipe: bankuTilapia)

        // Add steps for Banku with Tilapia
        createStep(instruction: "Mix corn flour and cassava flour in a bowl. Gradually add 2 cups water to form a smooth paste.", duration: 600, imageName: "banku_step1", orderIndex: 0, recipe: bankuTilapia)
        createStep(instruction: "Boil remaining 2 cups of water with salt in a heavy-bottomed pot.", duration: 300, imageName: "banku_step2", orderIndex: 1, recipe: bankuTilapia)
        createStep(instruction: "Gradually whisk the flour paste into boiling water. Cook, stirring constantly for 30-40 minutes until thick.", duration: 2400, imageName: "banku_step3", orderIndex: 2, recipe: bankuTilapia)
        createStep(instruction: "Meanwhile, score the fish and season with ginger, garlic, lemon juice, curry powder, black pepper, and salt.", duration: 600, imageName: "banku_step4", orderIndex: 3, recipe: bankuTilapia)
        createStep(instruction: "Let the seasoned fish marinate for 20 minutes while banku finishes cooking.", duration: 1200, imageName: "banku_step5", orderIndex: 4, recipe: bankuTilapia)
        createStep(instruction: "Heat grill or grill pan. Brush fish with oil and grill for 6-8 minutes per side until crispy.", duration: 960, imageName: "banku_step6", orderIndex: 5, recipe: bankuTilapia)
        createStep(instruction: "Shape hot banku into balls using wet hands. Serve with grilled tilapia and pepper sauce.", duration: 300, imageName: "banku_step7", orderIndex: 6, recipe: bankuTilapia)

        // 10. Ghanaian Meat Pie (Street Food)
        let meatPie = createRecipe(
            id: "ghanaian_meat_pie",
            name: "Ghanaian Meat Pie",
            description: "Flaky pastry filled with spiced minced meat and vegetables. A popular street food and party snack.",
            prepTime: 60,
            cookTime: 30,
            servings: 8,
            difficulty: "Hard",
            region: "Nationwide",
            imageName: "meatPie",
            category: fetchCategory(name: "Street Food")
        )

        // Add ingredients for Ghanaian Meat Pie
        createIngredient(name: "All-purpose flour", quantity: 3, unit: "cups", notes: "For pastry", orderIndex: 0, recipe: meatPie)
        createIngredient(name: "Butter", quantity: 150, unit: "g", notes: "Cold, cubed", orderIndex: 1, recipe: meatPie)
        createIngredient(name: "Cold water", quantity: 0.5, unit: "cup", notes: "Ice cold", orderIndex: 2, recipe: meatPie)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: "For pastry", orderIndex: 3, recipe: meatPie)
        createIngredient(name: "Ground beef", quantity: 500, unit: "g", notes: nil, orderIndex: 4, recipe: meatPie)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Finely chopped", orderIndex: 5, recipe: meatPie)
        createIngredient(name: "Carrots", quantity: 2, unit: "medium", notes: "Diced small", orderIndex: 6, recipe: meatPie)
        createIngredient(name: "Potatoes", quantity: 2, unit: "medium", notes: "Diced small", orderIndex: 7, recipe: meatPie)
        createIngredient(name: "Green peas", quantity: 0.5, unit: "cup", notes: "Fresh or frozen", orderIndex: 8, recipe: meatPie)
        createIngredient(name: "Curry powder", quantity: 2, unit: "teaspoons", notes: nil, orderIndex: 9, recipe: meatPie)
        createIngredient(name: "Thyme", quantity: 1, unit: "teaspoon", notes: "Dried", orderIndex: 10, recipe: meatPie)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: "Crushed", orderIndex: 11, recipe: meatPie)
        createIngredient(name: "Vegetable oil", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 12, recipe: meatPie)
        createIngredient(name: "Egg", quantity: 1, unit: "", notes: "For egg wash", orderIndex: 13, recipe: meatPie)

        // Add steps for Ghanaian Meat Pie
        createStep(instruction: "Make pastry: Mix flour and salt, rub in cold butter until mixture resembles breadcrumbs.", duration: 600, imageName: "meat_pie_step1", orderIndex: 0, recipe: meatPie)
        createStep(instruction: "Gradually add cold water to form a firm dough. Wrap and refrigerate for 30 minutes.", duration: 1800, imageName: "meat_pie_step2", orderIndex: 1, recipe: meatPie)
        createStep(instruction: "Heat oil in a pan, sauté onions until translucent, then add ground beef and cook until browned.", duration: 600, imageName: "meat_pie_step3", orderIndex: 2, recipe: meatPie)
        createStep(instruction: "Add carrots, potatoes, peas, curry powder, thyme, and stock cubes. Cook for 10 minutes.", duration: 600, imageName: "meat_pie_step4", orderIndex: 3, recipe: meatPie)
        createStep(instruction: "Let filling cool completely. Preheat oven to 200°C (390°F).", duration: 900, imageName: "meat_pie_step5", orderIndex: 4, recipe: meatPie)
        createStep(instruction: "Roll out pastry, cut into circles, add filling, seal edges, and brush with beaten egg.", duration: 1200, imageName: "meat_pie_step6", orderIndex: 5, recipe: meatPie)
        createStep(instruction: "Bake for 25-30 minutes until golden brown. Cool slightly before serving.", duration: 1800, imageName: "meat_pie_step7", orderIndex: 6, recipe: meatPie)

        // 11. Sobolo (Drinks)
        let sobolo = createRecipe(
            id: "sobolo",
            name: "Sobolo (Hibiscus Drink)",
            description: "A refreshing drink made from dried hibiscus petals, spiced with ginger, cloves, and other natural flavors.",
            prepTime: 15,
            cookTime: 20,
            servings: 6,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "sobolo",
            category: fetchCategory(name: "Drinks")
        )

        // Add ingredients for Sobolo
        createIngredient(name: "Dried hibiscus petals", quantity: 2, unit: "cups", notes: "Also called sorrel leaves", orderIndex: 0, recipe: sobolo)
        createIngredient(name: "Water", quantity: 6, unit: "cups", notes: nil, orderIndex: 1, recipe: sobolo)
        createIngredient(name: "Fresh ginger", quantity: 2, unit: "thumb-sized", notes: "Sliced", orderIndex: 2, recipe: sobolo)
        createIngredient(name: "Cloves", quantity: 6, unit: "whole", notes: nil, orderIndex: 3, recipe: sobolo)
        createIngredient(name: "Cinnamon stick", quantity: 1, unit: "medium", notes: nil, orderIndex: 4, recipe: sobolo)
        createIngredient(name: "Nutmeg", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 5, recipe: sobolo)
        createIngredient(name: "Cucumber", quantity: 1, unit: "medium", notes: "Peeled and sliced", orderIndex: 6, recipe: sobolo)
        createIngredient(name: "Pineapple", quantity: 0.5, unit: "cup", notes: "Diced", orderIndex: 7, recipe: sobolo)
        createIngredient(name: "Orange", quantity: 1, unit: "medium", notes: "Juiced", orderIndex: 8, recipe: sobolo)
        createIngredient(name: "Lemon", quantity: 1, unit: "medium", notes: "Juiced", orderIndex: 9, recipe: sobolo)
        createIngredient(name: "Sugar or honey", quantity: 3, unit: "tablespoons", notes: "To taste", orderIndex: 10, recipe: sobolo)

        // Add steps for Sobolo
        createStep(instruction: "Rinse hibiscus petals in cold water until water runs clear.", duration: 180, imageName: "sobolo_step1", orderIndex: 0, recipe: sobolo)
        createStep(instruction: "Boil water with ginger, cloves, cinnamon, and nutmeg for 5 minutes.", duration: 300, imageName: "sobolo_step2", orderIndex: 1, recipe: sobolo)
        createStep(instruction: "Add hibiscus petals to the boiling spiced water and boil for 10 minutes.", duration: 600, imageName: "sobolo_step3", orderIndex: 2, recipe: sobolo)
        createStep(instruction: "Remove from heat and let steep for 15 minutes for stronger flavor.", duration: 900, imageName: "sobolo_step4", orderIndex: 3, recipe: sobolo)
        createStep(instruction: "Strain the liquid, discarding the solids. Let cool to room temperature.", duration: 1200, imageName: "sobolo_step5", orderIndex: 4, recipe: sobolo)
        createStep(instruction: "Add cucumber, pineapple, orange juice, lemon juice, and sweetener. Stir well.", duration: 300, imageName: "sobolo_step6", orderIndex: 5, recipe: sobolo)
        createStep(instruction: "Refrigerate for at least 2 hours. Serve chilled over ice with fruit garnish.", duration: 7200, imageName: "sobolo_step7", orderIndex: 6, recipe: sobolo)
        
        // 12. Kontomire Stew (Stews)
        let kontomireStew = createRecipe(
            id: "kontomire_stew",
            name: "Kontomire Stew (Cocoyam Leaves)",
            description: "A nutritious stew made with cocoyam leaves (kontomire), often cooked with meat, fish, and palm oil.",
            prepTime: 30,
            cookTime: 45,
            servings: 5,
            difficulty: "Medium",
            region: "Ashanti/Nationwide",
            imageName: "kontomireStew",
            category: fetchCategory(name: "Stews")
        )

        // Add ingredients for Kontomire Stew
        createIngredient(name: "Fresh kontomire leaves", quantity: 2, unit: "bunches", notes: "Or spinach/collard greens as substitute", orderIndex: 0, recipe: kontomireStew)
        createIngredient(name: "Smoked fish", quantity: 200, unit: "g", notes: "Cleaned and flaked", orderIndex: 1, recipe: kontomireStew)
        createIngredient(name: "Beef", quantity: 300, unit: "g", notes: "Cut into chunks", orderIndex: 2, recipe: kontomireStew)
        createIngredient(name: "Palm oil", quantity: 0.25, unit: "cup", notes: nil, orderIndex: 3, recipe: kontomireStew)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 4, recipe: kontomireStew)
        createIngredient(name: "Tomatoes", quantity: 3, unit: "medium", notes: "Chopped", orderIndex: 5, recipe: kontomireStew)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 6, recipe: kontomireStew)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 7, recipe: kontomireStew)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 8, recipe: kontomireStew)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "Whole or chopped", orderIndex: 9, recipe: kontomireStew)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: nil, orderIndex: 10, recipe: kontomireStew)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 11, recipe: kontomireStew)

        // Add steps for Kontomire Stew
        createStep(instruction: "Wash kontomire leaves thoroughly, remove tough stems, and chop finely. Set aside.", duration: 900, imageName: "kontomire_step1", orderIndex: 0, recipe: kontomireStew)
        createStep(instruction: "Season and boil beef with half the onion until tender, about 30 minutes. Reserve stock.", duration: 1800, imageName: "kontomire_step2", orderIndex: 1, recipe: kontomireStew)
        createStep(instruction: "Heat palm oil in a large pot over medium heat until clear.", duration: 180, imageName: "kontomire_step3", orderIndex: 2, recipe: kontomireStew)
        createStep(instruction: "Add remaining onions and sauté until translucent, about 5 minutes.", duration: 300, imageName: "kontomire_step4", orderIndex: 3, recipe: kontomireStew)
        createStep(instruction: "Add tomato paste, ginger, and garlic. Stir for 2 minutes until fragrant.", duration: 120, imageName: "kontomire_step5", orderIndex: 4, recipe: kontomireStew)
        createStep(instruction: "Add chopped tomatoes and scotch bonnet pepper. Cook until tomatoes break down, about 8 minutes.", duration: 480, imageName: "kontomire_step6", orderIndex: 5, recipe: kontomireStew)
        createStep(instruction: "Add chopped kontomire, cooked beef, smoked fish, stock, and seasonings. Simmer for 15 minutes.", duration: 900, imageName: "kontomire_step7", orderIndex: 6, recipe: kontomireStew)
        createStep(instruction: "Adjust seasoning and serve hot with boiled yam, plantain, or rice.", duration: 180, imageName: "kontomire_step8", orderIndex: 7, recipe: kontomireStew)

        // 13. Bofrot (Breakfast/Desserts)
        let bofrot = createRecipe(
            id: "bofrot",
            name: "Bofrot (Ghanaian Donuts)",
            description: "Sweet, fluffy fried dough balls that are perfect for breakfast or as a snack. Often enjoyed with tea or porridge.",
            prepTime: 20,
            cookTime: 20,
            servings: 12,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "bofrot",
            category: fetchCategory(name: "Breakfast")
        )

        // Add ingredients for Bofrot
        createIngredient(name: "All-purpose flour", quantity: 3, unit: "cups", notes: nil, orderIndex: 0, recipe: bofrot)
        createIngredient(name: "Sugar", quantity: 0.5, unit: "cup", notes: nil, orderIndex: 1, recipe: bofrot)
        createIngredient(name: "Active dry yeast", quantity: 1, unit: "packet", notes: "Or 2 tsp", orderIndex: 2, recipe: bofrot)
        createIngredient(name: "Warm water", quantity: 1, unit: "cup", notes: "About 110°F", orderIndex: 3, recipe: bofrot)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 4, recipe: bofrot)
        createIngredient(name: "Butter", quantity: 2, unit: "tablespoons", notes: "Melted", orderIndex: 5, recipe: bofrot)
        createIngredient(name: "Egg", quantity: 1, unit: "large", notes: "Beaten", orderIndex: 6, recipe: bofrot)
        createIngredient(name: "Vanilla extract", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 7, recipe: bofrot)
        createIngredient(name: "Ground nutmeg", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 8, recipe: bofrot)
        createIngredient(name: "Vegetable oil", quantity: 3, unit: "cups", notes: "For deep frying", orderIndex: 9, recipe: bofrot)

        // Add steps for Bofrot
        createStep(instruction: "Dissolve yeast and 1 tablespoon sugar in warm water. Let foam for 5 minutes.", duration: 300, imageName: "bofrot_step1", orderIndex: 0, recipe: bofrot)
        createStep(instruction: "In a large bowl, mix flour, remaining sugar, salt, and nutmeg.", duration: 180, imageName: "bofrot_step2", orderIndex: 1, recipe: bofrot)
        createStep(instruction: "Add yeast mixture, beaten egg, melted butter, and vanilla. Mix to form soft dough.", duration: 300, imageName: "bofrot_step3", orderIndex: 2, recipe: bofrot)
        createStep(instruction: "Knead dough on floured surface for 5 minutes until smooth. Place in oiled bowl.", duration: 300, imageName: "bofrot_step4", orderIndex: 3, recipe: bofrot)
        createStep(instruction: "Cover and let rise in warm place for 1 hour until doubled in size.", duration: 3600, imageName: "bofrot_step5", orderIndex: 4, recipe: bofrot)
        createStep(instruction: "Heat oil to 350°F (175°C). Punch down dough and shape into small balls.", duration: 600, imageName: "bofrot_step6", orderIndex: 5, recipe: bofrot)
        createStep(instruction: "Fry bofrot in batches for 2-3 minutes per side until golden brown. Drain on paper towels.", duration: 600, imageName: "bofrot_step7", orderIndex: 6, recipe: bofrot)
        createStep(instruction: "Serve warm, optionally dusted with powdered sugar or served with honey.", duration: 120, imageName: "bofrot_step8", orderIndex: 7, recipe: bofrot)

        // 14. Chin Chin (Desserts)
        let chinChin = createRecipe(
            id: "chin_chin",
            name: "Chin Chin",
            description: "Crunchy, sweet fried pastry cubes that are perfect as a snack or dessert. A popular treat at parties and celebrations.",
            prepTime: 30,
            cookTime: 15,
            servings: 20,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "chinChin",
            category: fetchCategory(name: "Desserts")
        )

        // Add ingredients for Chin Chin
        createIngredient(name: "All-purpose flour", quantity: 4, unit: "cups", notes: nil, orderIndex: 0, recipe: chinChin)
        createIngredient(name: "Sugar", quantity: 0.75, unit: "cup", notes: nil, orderIndex: 1, recipe: chinChin)
        createIngredient(name: "Butter", quantity: 0.5, unit: "cup", notes: "Cold, cubed", orderIndex: 2, recipe: chinChin)
        createIngredient(name: "Eggs", quantity: 2, unit: "large", notes: "Beaten", orderIndex: 3, recipe: chinChin)
        createIngredient(name: "Baking powder", quantity: 2, unit: "teaspoons", notes: nil, orderIndex: 4, recipe: chinChin)
        createIngredient(name: "Salt", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 5, recipe: chinChin)
        createIngredient(name: "Ground nutmeg", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 6, recipe: chinChin)
        createIngredient(name: "Vanilla extract", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 7, recipe: chinChin)
        createIngredient(name: "Milk", quantity: 0.25, unit: "cup", notes: "If needed", orderIndex: 8, recipe: chinChin)
        createIngredient(name: "Vegetable oil", quantity: 3, unit: "cups", notes: "For deep frying", orderIndex: 9, recipe: chinChin)

        // Add steps for Chin Chin
        createStep(instruction: "In a large bowl, mix flour, sugar, baking powder, salt, and nutmeg.", duration: 180, imageName: "chin_chin_step1", orderIndex: 0, recipe: chinChin)
        createStep(instruction: "Rub cold butter into the flour mixture until it resembles fine breadcrumbs.", duration: 300, imageName: "chin_chin_step2", orderIndex: 1, recipe: chinChin)
        createStep(instruction: "Add beaten eggs and vanilla. Mix to form a firm dough, adding milk if too dry.", duration: 300, imageName: "chin_chin_step3", orderIndex: 2, recipe: chinChin)
        createStep(instruction: "Knead dough lightly on floured surface until smooth. Cover and rest for 15 minutes.", duration: 900, imageName: "chin_chin_step4", orderIndex: 3, recipe: chinChin)
        createStep(instruction: "Roll dough to 1/4 inch thickness. Cut into small cubes or desired shapes.", duration: 600, imageName: "chin_chin_step5", orderIndex: 4, recipe: chinChin)
        createStep(instruction: "Heat oil to 350°F (175°C). Fry chin chin in small batches for 2-3 minutes until golden.", duration: 480, imageName: "chin_chin_step6", orderIndex: 5, recipe: chinChin)
        createStep(instruction: "Remove with slotted spoon and drain on paper towels. Cool completely before storing.", duration: 600, imageName: "chin_chin_step7", orderIndex: 6, recipe: chinChin)
        createStep(instruction: "Store in airtight container for up to 2 weeks. Serve as snack or dessert.", duration: 60, imageName: "chin_chin_step8", orderIndex: 7, recipe: chinChin)
        
        // 15. Okro Stew (Stews)
        let okroStew = createRecipe(
            id: "okro_stew",
            name: "Okro Stew (Okra Soup)",
            description: "A hearty stew made with fresh okra, meat, and fish. Known for its unique texture and rich flavor.",
            prepTime: 25,
            cookTime: 50,
            servings: 6,
            difficulty: "Medium",
            region: "Nationwide",
            imageName: "okraSoup",
            category: fetchCategory(name: "Stews")
        )

        // Add ingredients for Okro Stew
        createIngredient(name: "Fresh okra", quantity: 500, unit: "g", notes: "Chopped", orderIndex: 0, recipe: okroStew)
        createIngredient(name: "Beef", quantity: 400, unit: "g", notes: "Cut into chunks", orderIndex: 1, recipe: okroStew)
        createIngredient(name: "Smoked fish", quantity: 150, unit: "g", notes: "Cleaned and flaked", orderIndex: 2, recipe: okroStew)
        createIngredient(name: "Crab", quantity: 2, unit: "medium", notes: "Cleaned, optional", orderIndex: 3, recipe: okroStew)
        createIngredient(name: "Palm oil", quantity: 3, unit: "tablespoons", notes: nil, orderIndex: 4, recipe: okroStew)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 5, recipe: okroStew)
        createIngredient(name: "Tomatoes", quantity: 3, unit: "medium", notes: "Chopped", orderIndex: 6, recipe: okroStew)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 7, recipe: okroStew)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 8, recipe: okroStew)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 9, recipe: okroStew)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "To taste", orderIndex: 10, recipe: okroStew)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: nil, orderIndex: 11, recipe: okroStew)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 12, recipe: okroStew)

        // Add steps for Okro Stew
        createStep(instruction: "Wash and chop okra into small pieces. Set aside in a bowl.", duration: 600, imageName: "okro_step1", orderIndex: 0, recipe: okroStew)
        createStep(instruction: "Season and boil beef with half the onion until tender, about 35 minutes. Reserve stock.", duration: 2100, imageName: "okro_step2", orderIndex: 1, recipe: okroStew)
        createStep(instruction: "Heat palm oil in a large pot over medium heat.", duration: 120, imageName: "okro_step3", orderIndex: 2, recipe: okroStew)
        createStep(instruction: "Add remaining onions and sauté until translucent, about 5 minutes.", duration: 300, imageName: "okro_step4", orderIndex: 3, recipe: okroStew)
        createStep(instruction: "Add tomato paste, ginger, and garlic. Stir for 2 minutes until fragrant.", duration: 120, imageName: "okro_step5", orderIndex: 4, recipe: okroStew)
        createStep(instruction: "Add chopped tomatoes and scotch bonnet pepper. Cook until tomatoes soften, about 8 minutes.", duration: 480, imageName: "okro_step6", orderIndex: 5, recipe: okroStew)
        createStep(instruction: "Add chopped okra and cook for 5 minutes, stirring gently to avoid over-mashing.", duration: 300, imageName: "okro_step7", orderIndex: 6, recipe: okroStew)
        createStep(instruction: "Add cooked beef, smoked fish, crab, stock, and seasonings. Simmer for 15 minutes.", duration: 900, imageName: "okro_step8", orderIndex: 7, recipe: okroStew)
        createStep(instruction: "Adjust seasoning and serve hot with banku, fufu, or rice.", duration: 180, imageName: "okro_step9", orderIndex: 8, recipe: okroStew)

        // 16. Koose (Street Food)
        let koose = createRecipe(
            id: "koose",
            name: "Koose (Bean Cakes)",
            description: "Deep-fried bean fritters made from black-eyed peas. A popular street food often eaten with koko or bread.",
            prepTime: 45,
            cookTime: 20,
            servings: 15,
            difficulty: "Medium",
            region: "Northern/Nationwide",
            imageName: "koose",
            category: fetchCategory(name: "Street Food")
        )

        // Add ingredients for Koose
        createIngredient(name: "Black-eyed beans", quantity: 2, unit: "cups", notes: "Soaked overnight", orderIndex: 0, recipe: koose)
        createIngredient(name: "Onion", quantity: 1, unit: "small", notes: "Roughly chopped", orderIndex: 1, recipe: koose)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "Or to taste", orderIndex: 2, recipe: koose)
        createIngredient(name: "Fresh ginger", quantity: 1, unit: "thumb-sized", notes: "Peeled", orderIndex: 3, recipe: koose)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 4, recipe: koose)
        createIngredient(name: "Stock cube", quantity: 1, unit: "", notes: "Optional", orderIndex: 5, recipe: koose)
        createIngredient(name: "Water", quantity: 0.25, unit: "cup", notes: "If needed", orderIndex: 6, recipe: koose)
        createIngredient(name: "Vegetable oil", quantity: 3, unit: "cups", notes: "For deep frying", orderIndex: 7, recipe: koose)

        // Add steps for Koose
        createStep(instruction: "Drain soaked beans and rub between palms to remove skins. Rinse until skins float away.", duration: 900, imageName: "koose_step1", orderIndex: 0, recipe: koose)
        createStep(instruction: "Blend beans with onion, scotch bonnet pepper, and ginger until smooth and fluffy.", duration: 600, imageName: "koose_step2", orderIndex: 1, recipe: koose)
        createStep(instruction: "Add salt and stock cube to the bean paste. Mix well. Add water if paste is too thick.", duration: 180, imageName: "koose_step3", orderIndex: 2, recipe: koose)
        createStep(instruction: "Whip the mixture with a wooden spoon for 3-5 minutes until very fluffy and light.", duration: 300, imageName: "koose_step4", orderIndex: 3, recipe: koose)
        createStep(instruction: "Heat oil to 350°F (175°C) in a deep pot.", duration: 300, imageName: "koose_step5", orderIndex: 4, recipe: koose)
        createStep(instruction: "Using two spoons, scoop and drop portions of batter into hot oil.", duration: 120, imageName: "koose_step6", orderIndex: 5, recipe: koose)
        createStep(instruction: "Fry for 3-4 minutes until golden brown, turning once. Don't overcrowd the pot.", duration: 240, imageName: "koose_step7", orderIndex: 6, recipe: koose)
        createStep(instruction: "Remove with slotted spoon and drain on paper towels. Serve hot with koko or bread.", duration: 180, imageName: "koose_step8", orderIndex: 7, recipe: koose)

        // 17. Ginger Beer (Drinks)
        let gingerBeer = createRecipe(
            id: "ginger_beer",
            name: "Ginger Beer",
            description: "A spicy, refreshing non-alcoholic drink made with fresh ginger, lime, and natural spices. Perfect for hot weather.",
            prepTime: 20,
            cookTime: 15,
            servings: 8,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "gingerBeer",
            category: fetchCategory(name: "Drinks")
        )

        // Add ingredients for Ginger Beer
        createIngredient(name: "Fresh ginger", quantity: 200, unit: "g", notes: "Washed and roughly chopped", orderIndex: 0, recipe: gingerBeer)
        createIngredient(name: "Water", quantity: 6, unit: "cups", notes: "Divided", orderIndex: 1, recipe: gingerBeer)
        createIngredient(name: "Limes", quantity: 4, unit: "medium", notes: "Juiced", orderIndex: 2, recipe: gingerBeer)
        createIngredient(name: "Cloves", quantity: 6, unit: "whole", notes: nil, orderIndex: 3, recipe: gingerBeer)
        createIngredient(name: "Cinnamon stick", quantity: 1, unit: "medium", notes: nil, orderIndex: 4, recipe: gingerBeer)
        createIngredient(name: "Nutmeg", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 5, recipe: gingerBeer)
        createIngredient(name: "Pineapple", quantity: 1, unit: "cup", notes: "Chopped, optional", orderIndex: 6, recipe: gingerBeer)
        createIngredient(name: "Cucumber", quantity: 1, unit: "medium", notes: "Sliced, optional", orderIndex: 7, recipe: gingerBeer)
        createIngredient(name: "Sugar", quantity: 0.5, unit: "cup", notes: "Or to taste", orderIndex: 8, recipe: gingerBeer)
        createIngredient(name: "Mint leaves", quantity: 0.25, unit: "cup", notes: "Fresh, for garnish", orderIndex: 9, recipe: gingerBeer)

        // Add steps for Ginger Beer
        createStep(instruction: "Blend chopped ginger with 2 cups of water until smooth.", duration: 180, imageName: "ginger_beer_step1", orderIndex: 0, recipe: gingerBeer)
        createStep(instruction: "Strain the ginger liquid through fine mesh or cheesecloth into a bowl.", duration: 300, imageName: "ginger_beer_step2", orderIndex: 1, recipe: gingerBeer)
        createStep(instruction: "Boil remaining 4 cups water with cloves, cinnamon, and nutmeg for 10 minutes.", duration: 600, imageName: "ginger_beer_step3", orderIndex: 2, recipe: gingerBeer)
        createStep(instruction: "Remove from heat and let the spiced water cool to room temperature.", duration: 1200, imageName: "ginger_beer_step4", orderIndex: 3, recipe: gingerBeer)
        createStep(instruction: "Strain spiced water and mix with ginger juice and lime juice.", duration: 180, imageName: "ginger_beer_step5", orderIndex: 4, recipe: gingerBeer)
        createStep(instruction: "Add sugar and stir until dissolved. Add pineapple and cucumber if using.", duration: 300, imageName: "ginger_beer_step6", orderIndex: 5, recipe: gingerBeer)
        createStep(instruction: "Refrigerate for at least 2 hours. Serve chilled over ice with mint garnish.", duration: 7200, imageName: "ginger_beer_step7", orderIndex: 6, recipe: gingerBeer)
        createStep(instruction: "Store in refrigerator for up to 5 days. Stir before serving.", duration: 60, imageName: "ginger_beer_step8", orderIndex: 7, recipe: gingerBeer)
        
        // 18. Tuo Zaafi (Sides)
        let tuoZaafi = createRecipe(
            id: "tuo_zaafi",
            name: "Tuo Zaafi (Northern Rice Balls)",
            description: "A Northern Ghanaian staple made from rice flour, served as balls with soup or stew. Similar to fufu but made with rice.",
            prepTime: 10,
            cookTime: 25,
            servings: 4,
            difficulty: "Medium",
            region: "Northern",
            imageName: "tuoZaafi",
            category: fetchCategory(name: "Sides")
        )

        // Add ingredients for Tuo Zaafi
        createIngredient(name: "Rice flour", quantity: 2, unit: "cups", notes: "Fine ground", orderIndex: 0, recipe: tuoZaafi)
        createIngredient(name: "Water", quantity: 4, unit: "cups", notes: "Divided", orderIndex: 1, recipe: tuoZaafi)
        createIngredient(name: "Salt", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 2, recipe: tuoZaafi)

        // Add steps for Tuo Zaafi
        createStep(instruction: "Mix rice flour with 1 cup of cold water to form a smooth paste without lumps.", duration: 300, imageName: "tuo_zaafi_step1", orderIndex: 0, recipe: tuoZaafi)
        createStep(instruction: "Boil remaining 3 cups of water with salt in a heavy-bottomed pot.", duration: 300, imageName: "tuo_zaafi_step2", orderIndex: 1, recipe: tuoZaafi)
        createStep(instruction: "Gradually whisk the rice flour paste into the boiling water, stirring constantly.", duration: 180, imageName: "tuo_zaafi_step3", orderIndex: 2, recipe: tuoZaafi)
        createStep(instruction: "Reduce heat to low and cook, stirring continuously with a wooden spoon for 15-20 minutes.", duration: 1200, imageName: "tuo_zaafi_step4", orderIndex: 3, recipe: tuoZaafi)
        createStep(instruction: "The mixture should be smooth, thick, and stretchy when done.", duration: 60, imageName: "tuo_zaafi_step5", orderIndex: 4, recipe: tuoZaafi)
        createStep(instruction: "Using wet hands, shape into smooth balls and serve immediately with soup or stew.", duration: 300, imageName: "tuo_zaafi_step6", orderIndex: 5, recipe: tuoZaafi)

        // 19. Garden Egg Stew (Stews)
        let gardenEggStew = createRecipe(
            id: "garden_egg_stew",
            name: "Garden Egg Stew",
            description: "A delicious stew made with garden eggs (African eggplants), tomatoes, and your choice of protein. A Southern Ghanaian favorite.",
            prepTime: 20,
            cookTime: 40,
            servings: 5,
            difficulty: "Easy",
            region: "Southern",
            imageName: "gardenEggStew",
            category: fetchCategory(name: "Stews")
        )

        // Add ingredients for Garden Egg Stew
        createIngredient(name: "Garden eggs", quantity: 8, unit: "medium", notes: "Or small eggplants", orderIndex: 0, recipe: gardenEggStew)
        createIngredient(name: "Chicken", quantity: 500, unit: "g", notes: "Cut into pieces", orderIndex: 1, recipe: gardenEggStew)
        createIngredient(name: "Smoked fish", quantity: 100, unit: "g", notes: "Cleaned and flaked", orderIndex: 2, recipe: gardenEggStew)
        createIngredient(name: "Palm oil", quantity: 3, unit: "tablespoons", notes: nil, orderIndex: 3, recipe: gardenEggStew)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 4, recipe: gardenEggStew)
        createIngredient(name: "Tomatoes", quantity: 4, unit: "medium", notes: "Chopped", orderIndex: 5, recipe: gardenEggStew)
        createIngredient(name: "Tomato paste", quantity: 2, unit: "tablespoons", notes: nil, orderIndex: 6, recipe: gardenEggStew)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 7, recipe: gardenEggStew)
        createIngredient(name: "Garlic", quantity: 3, unit: "cloves", notes: "Minced", orderIndex: 8, recipe: gardenEggStew)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "To taste", orderIndex: 9, recipe: gardenEggStew)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: nil, orderIndex: 10, recipe: gardenEggStew)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 11, recipe: gardenEggStew)

        // Add steps for Garden Egg Stew
        createStep(instruction: "Wash garden eggs and cut into bite-sized pieces. Set aside.", duration: 600, imageName: "garden_egg_step1", orderIndex: 0, recipe: gardenEggStew)
        createStep(instruction: "Season and cook chicken with half the onion until tender, about 25 minutes. Reserve stock.", duration: 1500, imageName: "garden_egg_step2", orderIndex: 1, recipe: gardenEggStew)
        createStep(instruction: "Heat palm oil in a large pot over medium heat.", duration: 120, imageName: "garden_egg_step3", orderIndex: 2, recipe: gardenEggStew)
        createStep(instruction: "Add remaining onions and sauté until translucent, about 5 minutes.", duration: 300, imageName: "garden_egg_step4", orderIndex: 3, recipe: gardenEggStew)
        createStep(instruction: "Add tomato paste, ginger, and garlic. Stir for 2 minutes until fragrant.", duration: 120, imageName: "garden_egg_step5", orderIndex: 4, recipe: gardenEggStew)
        createStep(instruction: "Add chopped tomatoes and scotch bonnet pepper. Cook until tomatoes break down, about 8 minutes.", duration: 480, imageName: "garden_egg_step6", orderIndex: 5, recipe: gardenEggStew)
        createStep(instruction: "Add garden egg pieces and cook for 5 minutes until they start to soften.", duration: 300, imageName: "garden_egg_step7", orderIndex: 6, recipe: gardenEggStew)
        createStep(instruction: "Add cooked chicken, smoked fish, stock, and seasonings. Simmer for 15 minutes.", duration: 900, imageName: "garden_egg_step8", orderIndex: 7, recipe: gardenEggStew)
        createStep(instruction: "Adjust seasoning and serve hot with rice, yam, or plantain.", duration: 180, imageName: "garden_egg_step9", orderIndex: 8, recipe: gardenEggStew)

        // 20. Hausa Koko (Breakfast)
        let hausaKoko = createRecipe(
            id: "hausa_koko",
            name: "Hausa Koko (Spiced Millet Drink)",
            description: "A spicy millet-based drink popular in Northern Ghana, often sold by Hausa vendors. Perfect for breakfast with koose or bread.",
            prepTime: 15,
            cookTime: 20,
            servings: 6,
            difficulty: "Easy",
            region: "Northern/Nationwide",
            imageName: "hausaKoko",
            category: fetchCategory(name: "Breakfast")
        )

        // Add ingredients for Hausa Koko
        createIngredient(name: "Millet flour", quantity: 1, unit: "cup", notes: nil, orderIndex: 0, recipe: hausaKoko)
        createIngredient(name: "Water", quantity: 5, unit: "cups", notes: "Divided", orderIndex: 1, recipe: hausaKoko)
        createIngredient(name: "Fresh ginger", quantity: 2, unit: "thumb-sized", notes: "Grated", orderIndex: 2, recipe: hausaKoko)
        createIngredient(name: "Cloves", quantity: 4, unit: "whole", notes: nil, orderIndex: 3, recipe: hausaKoko)
        createIngredient(name: "Black pepper", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 4, recipe: hausaKoko)
        createIngredient(name: "Nutmeg", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 5, recipe: hausaKoko)
        createIngredient(name: "Cinnamon", quantity: 0.25, unit: "teaspoon", notes: "Ground", orderIndex: 6, recipe: hausaKoko)
        createIngredient(name: "Calabash nutmeg", quantity: 0.25, unit: "teaspoon", notes: "Ground, optional", orderIndex: 7, recipe: hausaKoko)
        createIngredient(name: "Sugar", quantity: 3, unit: "tablespoons", notes: "Or to taste", orderIndex: 8, recipe: hausaKoko)
        createIngredient(name: "Evaporated milk", quantity: 0.5, unit: "cup", notes: "Optional", orderIndex: 9, recipe: hausaKoko)
        createIngredient(name: "Salt", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 10, recipe: hausaKoko)

        // Add steps for Hausa Koko
        createStep(instruction: "Mix millet flour with 1 cup of cold water to form a smooth paste without lumps.", duration: 300, imageName: "hausa_koko_step1", orderIndex: 0, recipe: hausaKoko)
        createStep(instruction: "Boil remaining 4 cups water with ginger, cloves, black pepper, nutmeg, cinnamon, and calabash nutmeg.", duration: 600, imageName: "hausa_koko_step2", orderIndex: 1, recipe: hausaKoko)
        createStep(instruction: "Gradually whisk the millet paste into the boiling spiced water.", duration: 180, imageName: "hausa_koko_step3", orderIndex: 2, recipe: hausaKoko)
        createStep(instruction: "Cook on medium heat, stirring constantly to prevent lumps, for 10-15 minutes until thickened.", duration: 900, imageName: "hausa_koko_step4", orderIndex: 3, recipe: hausaKoko)
        createStep(instruction: "Add sugar and salt, stir well to dissolve completely.", duration: 120, imageName: "hausa_koko_step5", orderIndex: 4, recipe: hausaKoko)
        createStep(instruction: "Strain to remove spice particles if desired, or leave for more texture.", duration: 180, imageName: "hausa_koko_step6", orderIndex: 5, recipe: hausaKoko)
        createStep(instruction: "Serve hot in cups, topped with evaporated milk if using. Accompany with koose or bread.", duration: 120, imageName: "hausa_koko_step7", orderIndex: 6, recipe: hausaKoko)
        createStep(instruction: "Can be stored in refrigerator for 2 days. Reheat and thin with water if needed.", duration: 60, imageName: "hausa_koko_step8", orderIndex: 7, recipe: hausaKoko)
        
        // 21. Tatale (Street Food)
        let tatale = createRecipe(
            id: "tatale",
            name: "Tatale (Plantain Pancakes)",
            description: "Sweet and savory pancakes made from overripe plantains, onions, and spices. A popular street food snack.",
            prepTime: 15,
            cookTime: 20,
            servings: 8,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "tatale",
            category: fetchCategory(name: "Street Food")
        )

        // Add ingredients for Tatale
        createIngredient(name: "Very ripe plantains", quantity: 4, unit: "large", notes: "Very soft with black spots", orderIndex: 0, recipe: tatale)
        createIngredient(name: "Onion", quantity: 1, unit: "medium", notes: "Finely chopped", orderIndex: 1, recipe: tatale)
        createIngredient(name: "Fresh ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 2, recipe: tatale)
        createIngredient(name: "Scotch bonnet pepper", quantity: 0.5, unit: "small", notes: "Finely chopped, optional", orderIndex: 3, recipe: tatale)
        createIngredient(name: "All-purpose flour", quantity: 0.25, unit: "cup", notes: "If needed for binding", orderIndex: 4, recipe: tatale)
        createIngredient(name: "Salt", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 5, recipe: tatale)
        createIngredient(name: "Ground nutmeg", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 6, recipe: tatale)
        createIngredient(name: "Vegetable oil", quantity: 0.5, unit: "cup", notes: "For frying", orderIndex: 7, recipe: tatale)

        // Add steps for Tatale
        createStep(instruction: "Peel plantains and mash in a large bowl until smooth with some small chunks.", duration: 300, imageName: "tatale_step1", orderIndex: 0, recipe: tatale)
        createStep(instruction: "Add chopped onion, grated ginger, scotch bonnet pepper, salt, and nutmeg. Mix well.", duration: 180, imageName: "tatale_step2", orderIndex: 1, recipe: tatale)
        createStep(instruction: "If mixture is too wet, add flour gradually until you can form patties.", duration: 120, imageName: "tatale_step3", orderIndex: 2, recipe: tatale)
        createStep(instruction: "Let mixture rest for 10 minutes to allow flavors to meld.", duration: 600, imageName: "tatale_step4", orderIndex: 3, recipe: tatale)
        createStep(instruction: "Heat oil in a frying pan over medium heat.", duration: 180, imageName: "tatale_step5", orderIndex: 4, recipe: tatale)
        createStep(instruction: "Scoop portions of mixture and flatten into small pancakes. Fry for 3-4 minutes per side.", duration: 480, imageName: "tatale_step6", orderIndex: 5, recipe: tatale)
        createStep(instruction: "Fry until golden brown and crispy on both sides. Drain on paper towels.", duration: 240, imageName: "tatale_step7", orderIndex: 6, recipe: tatale)
        createStep(instruction: "Serve hot as a snack or side dish. Can be eaten with pepper sauce.", duration: 120, imageName: "tatale_step8", orderIndex: 7, recipe: tatale)

        // 22. Konkonte (Sides)
        let konkonte = createRecipe(
            id: "konkonte",
            name: "Konkonte (Cassava Flour Balls)",
            description: "A simple staple food made from dried cassava flour. Often served with soup or stew, especially popular during lean times.",
            prepTime: 5,
            cookTime: 15,
            servings: 4,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "konkonte",
            category: fetchCategory(name: "Sides")
        )

        // Add ingredients for Konkonte
        createIngredient(name: "Cassava flour", quantity: 2, unit: "cups", notes: "Dried and ground", orderIndex: 0, recipe: konkonte)
        createIngredient(name: "Water", quantity: 3, unit: "cups", notes: nil, orderIndex: 1, recipe: konkonte)
        createIngredient(name: "Salt", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 2, recipe: konkonte)

        // Add steps for Konkonte
        createStep(instruction: "Boil water with salt in a heavy-bottomed pot.", duration: 300, imageName: "konkonte_step1", orderIndex: 0, recipe: konkonte)
        createStep(instruction: "Gradually sprinkle cassava flour into the boiling water while stirring constantly.", duration: 180, imageName: "konkonte_step2", orderIndex: 1, recipe: konkonte)
        createStep(instruction: "Continue stirring vigorously to prevent lumps from forming.", duration: 300, imageName: "konkonte_step3", orderIndex: 2, recipe: konkonte)
        createStep(instruction: "Cook for 8-10 minutes, stirring constantly until mixture is smooth and thick.", duration: 600, imageName: "konkonte_step4", orderIndex: 3, recipe: konkonte)
        createStep(instruction: "The consistency should be firm enough to shape but not too dry.", duration: 60, imageName: "konkonte_step5", orderIndex: 4, recipe: konkonte)
        createStep(instruction: "Using wet hands, shape into smooth balls and serve immediately with soup or stew.", duration: 300, imageName: "konkonte_step6", orderIndex: 5, recipe: konkonte)
        
        // 24. Ampesi (Sides)
        let ampesi = createRecipe(
            id: "ampesi",
            name: "Ampesi",
            description: "A simple, healthy dish of boiled plantains, yam, and cocoyam served with stew or soup. A classic Ghanaian comfort food.",
            prepTime: 15,
            cookTime: 30,
            servings: 6,
            difficulty: "Easy",
            region: "Nationwide",
            imageName: "ampesi",
            category: fetchCategory(name: "Sides")
        )

        // Add ingredients for Ampesi
        createIngredient(name: "Yam", quantity: 500, unit: "g", notes: "Peeled and cut into chunks", orderIndex: 0, recipe: ampesi)
        createIngredient(name: "Plantains", quantity: 3, unit: "medium", notes: "Semi-ripe, peeled and cut", orderIndex: 1, recipe: ampesi)
        createIngredient(name: "Cocoyam", quantity: 300, unit: "g", notes: "Peeled and cut, optional", orderIndex: 2, recipe: ampesi)
        createIngredient(name: "Sweet potatoes", quantity: 2, unit: "medium", notes: "Peeled and cut, optional", orderIndex: 3, recipe: ampesi)
        createIngredient(name: "Water", quantity: 6, unit: "cups", notes: "Enough to cover vegetables", orderIndex: 4, recipe: ampesi)
        createIngredient(name: "Salt", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 5, recipe: ampesi)

        // Add steps for Ampesi
        createStep(instruction: "Wash and peel all vegetables. Cut into similar-sized chunks for even cooking.", duration: 900, imageName: "ampesi_step1", orderIndex: 0, recipe: ampesi)
        createStep(instruction: "Bring salted water to boil in a large pot.", duration: 300, imageName: "ampesi_step2", orderIndex: 1, recipe: ampesi)
        createStep(instruction: "Add yam and cocoyam first as they take longer to cook. Boil for 10 minutes.", duration: 600, imageName: "ampesi_step3", orderIndex: 2, recipe: ampesi)
        createStep(instruction: "Add plantains and sweet potatoes. Continue boiling for 15-20 minutes.", duration: 1200, imageName: "ampesi_step4", orderIndex: 3, recipe: ampesi)
        createStep(instruction: "Test with a fork - vegetables should be tender but not mushy.", duration: 120, imageName: "ampesi_step5", orderIndex: 4, recipe: ampesi)
        createStep(instruction: "Drain water and arrange on serving platter.", duration: 180, imageName: "ampesi_step6", orderIndex: 5, recipe: ampesi)
        createStep(instruction: "Serve hot with kontomire stew, garden egg stew, or palm nut soup.", duration: 120, imageName: "ampesi_step7", orderIndex: 6, recipe: ampesi)

        // 25. Shito (Sides)
        let shito = createRecipe(
            id: "shito",
            name: "Shito (Black Pepper Sauce)",
            description: "A spicy Ghanaian condiment made with dried fish, shrimp, peppers, and spices. Perfect accompaniment to many dishes.",
            prepTime: 30,
            cookTime: 45,
            servings: 20,
            difficulty: "Medium",
            region: "Ga/Nationwide",
            imageName: "shito",
            category: fetchCategory(name: "Sides")
        )

        // Add ingredients for Shito
        createIngredient(name: "Dried chili peppers", quantity: 200, unit: "g", notes: "Mixed varieties", orderIndex: 0, recipe: shito)
        createIngredient(name: "Dried shrimp", quantity: 100, unit: "g", notes: "Cleaned", orderIndex: 1, recipe: shito)
        createIngredient(name: "Dried fish", quantity: 150, unit: "g", notes: "Smoked, cleaned and deboned", orderIndex: 2, recipe: shito)
        createIngredient(name: "Ginger", quantity: 3, unit: "thumb-sized", notes: "Peeled", orderIndex: 3, recipe: shito)
        createIngredient(name: "Garlic", quantity: 1, unit: "whole bulb", notes: "Peeled", orderIndex: 4, recipe: shito)
        createIngredient(name: "Onions", quantity: 2, unit: "large", notes: "Roughly chopped", orderIndex: 5, recipe: shito)
        createIngredient(name: "Tomatoes", quantity: 4, unit: "medium", notes: "Fresh", orderIndex: 6, recipe: shito)
        createIngredient(name: "Vegetable oil", quantity: 2, unit: "cups", notes: "For frying", orderIndex: 7, recipe: shito)
        createIngredient(name: "Palm oil", quantity: 0.25, unit: "cup", notes: "Optional, for color", orderIndex: 8, recipe: shito)
        createIngredient(name: "Stock cubes", quantity: 3, unit: "", notes: "Crushed", orderIndex: 9, recipe: shito)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 10, recipe: shito)

        // Add steps for Shito
        createStep(instruction: "Soak dried peppers in hot water for 15 minutes, then drain.", duration: 900, imageName: "shito_step1", orderIndex: 0, recipe: shito)
        createStep(instruction: "Blend peppers, ginger, garlic, onions, and tomatoes together until smooth.", duration: 600, imageName: "shito_step2", orderIndex: 1, recipe: shito)
        createStep(instruction: "Grind dried shrimp and fish separately into powder using a food processor.", duration: 300, imageName: "shito_step3", orderIndex: 2, recipe: shito)
        createStep(instruction: "Heat vegetable oil in a large, heavy-bottomed pot over medium heat.", duration: 180, imageName: "shito_step4", orderIndex: 3, recipe: shito)
        createStep(instruction: "Add the blended pepper mixture and fry, stirring constantly for 20 minutes.", duration: 1200, imageName: "shito_step5", orderIndex: 4, recipe: shito)
        createStep(instruction: "Add ground shrimp and fish powder. Continue frying for 15 minutes, stirring frequently.", duration: 900, imageName: "shito_step6", orderIndex: 5, recipe: shito)
        createStep(instruction: "Add palm oil (if using), stock cubes, and salt. Fry for 10 more minutes.", duration: 600, imageName: "shito_step7", orderIndex: 6, recipe: shito)
        createStep(instruction: "Cool completely and store in sterilized jars. Keeps for months in refrigerator.", duration: 1800, imageName: "shito_step8", orderIndex: 7, recipe: shito)
        
        // 27. Fried Rice (Rice Dishes)
        let friedRice = createRecipe(
            id: "ghanaian_fried_rice",
            name: "Ghanaian Fried Rice",
            description: "A flavorful fried rice with mixed vegetables, curry powder, and your choice of protein. Popular at parties and celebrations.",
            prepTime: 20,
            cookTime: 25,
            servings: 6,
            difficulty: "Medium",
            region: "Nationwide",
            imageName: "friedRice",
            category: riceDishes
        )

        // Add ingredients for Fried Rice
        createIngredient(name: "Long grain rice", quantity: 3, unit: "cups", notes: "Cooked and cooled", orderIndex: 0, recipe: friedRice)
        createIngredient(name: "Chicken", quantity: 400, unit: "g", notes: "Diced", orderIndex: 1, recipe: friedRice)
        createIngredient(name: "Shrimp", quantity: 200, unit: "g", notes: "Peeled and deveined", orderIndex: 2, recipe: friedRice)
        createIngredient(name: "Carrots", quantity: 2, unit: "medium", notes: "Diced", orderIndex: 3, recipe: friedRice)
        createIngredient(name: "Green beans", quantity: 1, unit: "cup", notes: "Chopped", orderIndex: 4, recipe: friedRice)
        createIngredient(name: "Green peas", quantity: 0.5, unit: "cup", notes: "Fresh or frozen", orderIndex: 5, recipe: friedRice)
        createIngredient(name: "Bell peppers", quantity: 2, unit: "medium", notes: "Mixed colors, diced", orderIndex: 6, recipe: friedRice)
        createIngredient(name: "Onions", quantity: 2, unit: "medium", notes: "Chopped", orderIndex: 7, recipe: friedRice)
        createIngredient(name: "Garlic", quantity: 4, unit: "cloves", notes: "Minced", orderIndex: 8, recipe: friedRice)
        createIngredient(name: "Ginger", quantity: 1, unit: "thumb-sized", notes: "Grated", orderIndex: 9, recipe: friedRice)
        createIngredient(name: "Curry powder", quantity: 2, unit: "teaspoons", notes: nil, orderIndex: 10, recipe: friedRice)
        createIngredient(name: "Soy sauce", quantity: 3, unit: "tablespoons", notes: nil, orderIndex: 11, recipe: friedRice)
        createIngredient(name: "Vegetable oil", quantity: 3, unit: "tablespoons", notes: nil, orderIndex: 12, recipe: friedRice)
        createIngredient(name: "Stock cubes", quantity: 2, unit: "", notes: "Crushed", orderIndex: 13, recipe: friedRice)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 14, recipe: friedRice)

        // Add steps for Fried Rice
        createStep(instruction: "Cook rice until tender, drain and spread on tray to cool completely.", duration: 1800, imageName: "fried_rice_step1", orderIndex: 0, recipe: friedRice)
        createStep(instruction: "Season chicken with salt, curry powder, and cook until done. Set aside.", duration: 600, imageName: "fried_rice_step2", orderIndex: 1, recipe: friedRice)
        createStep(instruction: "Cook shrimp quickly until pink, about 2 minutes. Set aside.", duration: 180, imageName: "fried_rice_step3", orderIndex: 2, recipe: friedRice)
        createStep(instruction: "Heat oil in a large wok or pan over high heat.", duration: 120, imageName: "fried_rice_step4", orderIndex: 3, recipe: friedRice)
        createStep(instruction: "Add onions, garlic, and ginger. Stir-fry for 2 minutes until fragrant.", duration: 120, imageName: "fried_rice_step5", orderIndex: 4, recipe: friedRice)
        createStep(instruction: "Add carrots and green beans. Stir-fry for 3 minutes until slightly tender.", duration: 180, imageName: "fried_rice_step6", orderIndex: 5, recipe: friedRice)
        createStep(instruction: "Add bell peppers and peas. Stir-fry for 2 minutes.", duration: 120, imageName: "fried_rice_step7", orderIndex: 6, recipe: friedRice)
        createStep(instruction: "Add cooled rice, breaking up clumps. Stir-fry for 5 minutes until heated through.", duration: 300, imageName: "fried_rice_step8", orderIndex: 7, recipe: friedRice)
        createStep(instruction: "Add cooked chicken, shrimp, soy sauce, and stock cubes. Toss everything together for 3 minutes.", duration: 180, imageName: "fried_rice_step9", orderIndex: 8, recipe: friedRice)
        createStep(instruction: "Adjust seasoning and serve hot. Garnish with chopped spring onions if desired.", duration: 120, imageName: "fried_rice_step10", orderIndex: 9, recipe: friedRice)

        // 28. Pito (Drinks)
        let pito = createRecipe(
            id: "pito",
            name: "Pito (Millet Beer)",
            description: "A traditional fermented alcoholic beverage made from millet. Popular in Northern Ghana and enjoyed during festivals.",
            prepTime: 30,
            cookTime: 60,
            servings: 10,
            difficulty: "Hard",
            region: "Northern",
            imageName: "pito",
            category: fetchCategory(name: "Drinks")
        )

        // Add ingredients for Pito
        createIngredient(name: "Millet", quantity: 2, unit: "cups", notes: "Whole grains", orderIndex: 0, recipe: pito)
        createIngredient(name: "Sorghum", quantity: 1, unit: "cup", notes: "Optional, for flavor", orderIndex: 1, recipe: pito)
        createIngredient(name: "Water", quantity: 8, unit: "cups", notes: "Clean water", orderIndex: 2, recipe: pito)
        createIngredient(name: "Ginger", quantity: 2, unit: "thumb-sized", notes: "Fresh, sliced", orderIndex: 3, recipe: pito)
        createIngredient(name: "Cloves", quantity: 4, unit: "whole", notes: nil, orderIndex: 4, recipe: pito)
        createIngredient(name: "Yeast", quantity: 1, unit: "teaspoon", notes: "Active dry yeast", orderIndex: 5, recipe: pito)
        createIngredient(name: "Sugar", quantity: 0.25, unit: "cup", notes: "To aid fermentation", orderIndex: 6, recipe: pito)

        // Add steps for Pito
        createStep(instruction: "Wash millet and sorghum thoroughly. Soak in water for 24 hours.", duration: 86400, imageName: "pito_step1", orderIndex: 0, recipe: pito)
        createStep(instruction: "Drain and spread grains on clean cloth. Cover and let germinate for 2-3 days until sprouts appear.", duration: 259200, imageName: "pito_step2", orderIndex: 1, recipe: pito)
        createStep(instruction: "Dry the sprouted grains in sun for 1 day, then grind into coarse flour.", duration: 43200, imageName: "pito_step3", orderIndex: 2, recipe: pito)
        createStep(instruction: "Boil water with ginger and cloves for 10 minutes to make spiced water.", duration: 600, imageName: "pito_step4", orderIndex: 3, recipe: pito)
        createStep(instruction: "Mix ground millet with some spiced water to form thick paste. Cook for 30 minutes, stirring constantly.", duration: 1800, imageName: "pito_step5", orderIndex: 4, recipe: pito)
        createStep(instruction: "Cool to room temperature. Add remaining spiced water, yeast, and sugar. Mix well.", duration: 300, imageName: "pito_step6", orderIndex: 5, recipe: pito)
        createStep(instruction: "Cover with clean cloth and ferment in cool place for 3-5 days until bubbly and slightly sour.", duration: 432000, imageName: "pito_step7", orderIndex: 6, recipe: pito)
        createStep(instruction: "Strain through fine cloth and serve in calabashes or bottles. Consume within 2 days.", duration: 300, imageName: "pito_step8", orderIndex: 7, recipe: pito)

        // 29. Fante Fante (Desserts)
        let fanteFante = createRecipe(
            id: "fante_fante",
            name: "Fante Fante (Coconut Candy)",
            description: "Sweet coconut candy popular among the Fante people. Made with fresh coconut, sugar, and spices for special occasions.",
            prepTime: 20,
            cookTime: 30,
            servings: 16,
            difficulty: "Medium",
            region: "Central/Fante",
            imageName: "coconutCandy",
            category: fetchCategory(name: "Desserts")
        )

        // Add ingredients for Fante Fante
        createIngredient(name: "Fresh coconut", quantity: 2, unit: "medium", notes: "Grated", orderIndex: 0, recipe: fanteFante)
        createIngredient(name: "Sugar", quantity: 1.5, unit: "cups", notes: nil, orderIndex: 1, recipe: fanteFante)
        createIngredient(name: "Water", quantity: 0.5, unit: "cup", notes: nil, orderIndex: 2, recipe: fanteFante)
        createIngredient(name: "Ground ginger", quantity: 0.5, unit: "teaspoon", notes: nil, orderIndex: 3, recipe: fanteFante)
        createIngredient(name: "Ground nutmeg", quantity: 0.25, unit: "teaspoon", notes: nil, orderIndex: 4, recipe: fanteFante)
        createIngredient(name: "Vanilla extract", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 5, recipe: fanteFante)
        createIngredient(name: "Food coloring", quantity: 2, unit: "drops", notes: "Optional, red or pink", orderIndex: 6, recipe: fanteFante)

        // Add steps for Fante Fante
        createStep(instruction: "Crack coconuts and grate the white flesh finely. Set aside.", duration: 900, imageName: "fante_fante_step1", orderIndex: 0, recipe: fanteFante)
        createStep(instruction: "In a heavy-bottomed pan, combine sugar and water. Heat until sugar dissolves.", duration: 300, imageName: "fante_fante_step2", orderIndex: 1, recipe: fanteFante)
        createStep(instruction: "Bring to boil and cook until syrup reaches soft ball stage (238°F/115°C).", duration: 600, imageName: "fante_fante_step3", orderIndex: 2, recipe: fanteFante)
        createStep(instruction: "Add grated coconut, ginger, and nutmeg. Stir constantly to prevent sticking.", duration: 300, imageName: "fante_fante_step4", orderIndex: 3, recipe: fanteFante)
        createStep(instruction: "Continue cooking and stirring for 15-20 minutes until mixture is thick and pulls away from sides.", duration: 1200, imageName: "fante_fante_step5", orderIndex: 4, recipe: fanteFante)
        createStep(instruction: "Add vanilla and food coloring if using. Mix well.", duration: 60, imageName: "fante_fante_step6", orderIndex: 5, recipe: fanteFante)
        createStep(instruction: "Pour onto greased tray and spread evenly. Cool for 10 minutes.", duration: 600, imageName: "fante_fante_step7", orderIndex: 6, recipe: fanteFante)
        createStep(instruction: "Cut into squares while still warm. Cool completely before storing in airtight container.", duration: 1800, imageName: "fante_fante_step8", orderIndex: 7, recipe: fanteFante)

        // 30. Yam Balls (Street Food)
        let yamBalls = createRecipe(
            id: "yam_balls",
            name: "Yam Balls",
            description: "Crispy fried balls made from mashed yam, seasoned and coated in breadcrumbs. A popular party snack and street food.",
            prepTime: 40,
            cookTime: 30,
            servings: 12,
            difficulty: "Medium",
            region: "Nationwide",
            imageName: "yamBalls",
            category: fetchCategory(name: "Street Food")
        )

        // Add ingredients for Yam Balls
        createIngredient(name: "Yam", quantity: 1, unit: "kg", notes: "Peeled and diced", orderIndex: 0, recipe: yamBalls)
        createIngredient(name: "Eggs", quantity: 2, unit: "large", notes: "Beaten", orderIndex: 1, recipe: yamBalls)
        createIngredient(name: "Flour", quantity: 0.5, unit: "cup", notes: "All-purpose", orderIndex: 2, recipe: yamBalls)
        createIngredient(name: "Breadcrumbs", quantity: 2, unit: "cups", notes: "Fine", orderIndex: 3, recipe: yamBalls)
        createIngredient(name: "Onion", quantity: 1, unit: "medium", notes: "Finely chopped", orderIndex: 4, recipe: yamBalls)
        createIngredient(name: "Scotch bonnet pepper", quantity: 1, unit: "small", notes: "Finely chopped", orderIndex: 5, recipe: yamBalls)
        createIngredient(name: "Curry powder", quantity: 1, unit: "teaspoon", notes: nil, orderIndex: 6, recipe: yamBalls)
        createIngredient(name: "Thyme", quantity: 0.5, unit: "teaspoon", notes: "Dried", orderIndex: 7, recipe: yamBalls)
        createIngredient(name: "Stock cube", quantity: 1, unit: "", notes: "Crushed", orderIndex: 8, recipe: yamBalls)
        createIngredient(name: "Salt", quantity: 1, unit: "to taste", notes: nil, orderIndex: 9, recipe: yamBalls)
        createIngredient(name: "Vegetable oil", quantity: 3, unit: "cups", notes: "For deep frying", orderIndex: 10, recipe: yamBalls)

        // Add steps for Yam Balls
        createStep(instruction: "Boil yam pieces in salted water until very tender, about 20 minutes. Drain well.", duration: 1200, imageName: "yam_balls_step1", orderIndex: 0, recipe: yamBalls)
        createStep(instruction: "Mash yam until completely smooth with no lumps. Let cool slightly.", duration: 300, imageName: "yam_balls_step2", orderIndex: 1, recipe: yamBalls)
        createStep(instruction: "Mix in chopped onion, scotch bonnet, curry powder, thyme, stock cube, and salt.", duration: 180, imageName: "yam_balls_step3", orderIndex: 2, recipe: yamBalls)
        createStep(instruction: "Add a little flour if mixture is too soft to shape. Let mixture cool completely.", duration: 1200, imageName: "yam_balls_step4", orderIndex: 3, recipe: yamBalls)
        createStep(instruction: "Shape mixture into golf ball-sized portions with wet hands.", duration: 600, imageName: "yam_balls_step5", orderIndex: 4, recipe: yamBalls)
        createStep(instruction: "Set up coating station: flour, beaten eggs, and breadcrumbs in separate bowls.", duration: 180, imageName: "yam_balls_step6", orderIndex: 5, recipe: yamBalls)
        createStep(instruction: "Roll each ball in flour, then egg, then breadcrumbs. Coat thoroughly.", duration: 600, imageName: "yam_balls_step7", orderIndex: 6, recipe: yamBalls)
        createStep(instruction: "Heat oil to 350°F (175°C). Fry balls in batches for 3-4 minutes until golden brown.", duration: 480, imageName: "yam_balls_step8", orderIndex: 7, recipe: yamBalls)
        createStep(instruction: "Drain on paper towels and serve hot with pepper sauce or ketchup.", duration: 180, imageName: "yam_balls_step9", orderIndex: 8, recipe: yamBalls)
        
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
