//
//  RecipeDetailViewController.swift
//  Recipes
//
//  Created by Sean Acres on 7/8/19.
//  Copyright © 2019 Lambda Inc. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {

    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeInstructions: UITextView!
    var recipeController: RecipeController?
    
    var recipe: Recipe? {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeInstructions.delegate = self
        updateViews()
    }
    
    func updateViews() {
        guard let recipe = recipe, isViewLoaded else { return }
        recipeName.text = recipe.name
        recipeInstructions.text = recipe.instructions
    }
    
    @IBAction func saveChangesTapped(_ sender: Any) {
        guard let recipeController = recipeController, let recipe = recipe else { return }
        recipeController.updateRecipe(for: recipe, newInstructions: recipeInstructions.text)
        navigationController?.popViewController(animated: true)
    }
}

extension RecipeDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
