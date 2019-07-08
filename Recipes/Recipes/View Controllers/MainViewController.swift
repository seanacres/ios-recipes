//
//  MainViewController.swift
//  Recipes
//
//  Created by Sean Acres on 7/8/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    let networkClient = RecipesNetworkClient()
    var allRecipes: [Recipe] = [] {
        didSet {
            filterRecipes()
        }
    }
    
    var recipesTableViewController: RecipesTableViewController? {
        didSet {
            self.recipesTableViewController?.recipes = filteredRecipes
        }
    }

    var filteredRecipes: [Recipe] = [] {
        didSet {
            recipesTableViewController?.recipes = self.filteredRecipes
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        networkClient.fetchRecipes { (recipes, error) in
            if let error = error {
                NSLog("error fetching recipes: \(error)")
            } else {
                guard let recipes = recipes else { return }
                DispatchQueue.main.async {
                    self.allRecipes = recipes
                }
            }
        }
    }
    
    private func filterRecipes() {
        guard let searchTerm = searchBar.text, searchTerm != "" else {
            filteredRecipes = allRecipes
            return
        }
        
        filteredRecipes = allRecipes.filter({ $0.name.contains(searchTerm) || $0.instructions.contains(searchTerm)})
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecipeTableViewEmbed" {
            recipesTableViewController = segue.destination as? RecipesTableViewController
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filterRecipes()
        resignFirstResponder()
    }
}
