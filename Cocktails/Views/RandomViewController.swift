//
//  RandomViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/11/22.
//

import UIKit

class RandomViewController: UIViewController {

    @IBOutlet weak var randomButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let viewModel = RandomViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        setupUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dvc = segue.destination as? DetailsViewController{
            dvc.configure()
        }
    }
    
    func setupUI(){
        title = "Random"
        randomButton.layer.cornerRadius = 50
        randomButton.clipsToBounds = true
    }
    
    func  initViewModel(){
        viewModel.showLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.randomButton.isEnabled = false
            }
        }
        viewModel.hideLoading = {
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
                self.randomButton.isEnabled = true
            }
        }
        viewModel.showError = { error in
            DispatchQueue.main.async {
                self.showAlert(error, title: "Ups, something went wrong.")
            }
        }
    }
    
    

    @IBAction func didTapRandomButton(_ sender: Any) {
        self.performSegue(withIdentifier: "randomDetailsSegue", sender: nil)
    }
}
