//
//  RecipeController.swift
//  Recipes
//
//  Created by Sean Acres on 7/8/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import Foundation

class RecipeController {
    var recipes: [Recipe] = []
    var recipesURL: URL? {
        let fileManager = FileManager.default
        guard let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documents.appendingPathComponent("Recipes.plist")
    }
    static let recipesURL = URL(string: "https://lambdacookbook.vapor.cloud/recipes")!
    
    func loadRecipes(completion: @escaping ([Recipe]?, Error?) -> Void) {
        do {
            guard let url = recipesURL else { return }
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let decodedRecipes = try decoder.decode([Recipe].self, from: data)
            self.recipes = decodedRecipes
            completion(recipes, nil)
            print("loaded recipes from store")
        } catch {
            fetchRecipes { (recipes, error) in
                if let error = error {
                    NSLog("error fetching recipes: \(error)")
                    completion(nil, error)
                } else {
                    guard let recipes = recipes else { return }
                    print("fetched recipes")
                    self.recipes = recipes
                    self.saveToPersistentStore()
                    completion(recipes, nil)
                }
            }
        }
    }
    
    func saveToPersistentStore() {
        guard let url = recipesURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let recipesData = try encoder.encode(recipes)
            try recipesData.write(to: url)
        } catch {
            print("error saving to store: \(error)")
        }
    }
    
    func fetchRecipes(completion: @escaping ([Recipe]?, Error?) -> Void) {
        URLSession.shared.dataTask(with: RecipeController.recipesURL) { (data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError())
                return
            }
            
            do {
                let recipes = try JSONDecoder().decode([Recipe].self, from: data)
                completion(recipes, nil)
            } catch {
                completion(nil, error)
                return
            }
            }.resume()
    }
    
    func updateRecipe(for recipe: Recipe, newInstructions: String) {
        guard let index = recipes.firstIndex(of: recipe) else { return }
        recipes[index].instructions = newInstructions
        saveToPersistentStore()
    }
}
