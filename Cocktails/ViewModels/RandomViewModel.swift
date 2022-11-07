//
//  RandomViewModel.swift
//  Cocktails
//
//  Created by Consultant on 7/11/22.
//

import Foundation

class RandomViewModel{
    var showLoading: (()->())?
    var hideLoading: (()->())?
    var showDetailsPage: (()->())?
    var showError: ((_ error: String)->())?

}
