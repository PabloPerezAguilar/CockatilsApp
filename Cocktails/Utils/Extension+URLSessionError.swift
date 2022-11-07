//
//  Extension+URLSessionError.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import Foundation

extension URLSession{
    enum RequestError:Error{
        case invalidUrl
        case errorDecode
        case failed(error: Error)
        case unknownError
    }
}
