//
//  PropertyReflectable.swift
//  Cocktails
//
//  Created by Consultant on 7/9/22.
//

import Foundation


protocol PropertyReflectable{}

extension PropertyReflectable{
    subscript(key: String) -> Any?{
        let mirror = Mirror(reflecting: self)
        return mirror.children.first { $0.label == key }?.value
    }
}
