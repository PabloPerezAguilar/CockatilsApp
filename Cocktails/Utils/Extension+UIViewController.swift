//
//  Extension+ViewController.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//
import UIKit

extension UIViewController{
    func showAlert( _ message: String, title: String = "" ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
