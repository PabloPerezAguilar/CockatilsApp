//
//  UIImageLoader.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//

import UIKit

class UIImageLoader{
    static let loader = UIImageLoader()
    
    private var imageLoader = ImageLoader()
    private var uuidMap = [UIImageView: UUID]()
    
    private init(){}
    
    func load(_ url: URL, for imageView: UIImageView){
        let token = imageLoader.loadImage(url){ result in
            //When load is completed remove the imageview from the uuidMap
            defer { self.uuidMap.removeValue(forKey: imageView) }
            do{
                let image = try result.get()
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }catch{
                print(error)
            }
            
        }
        
        //Save token so we can remove it if its cancelled
        if let token = token{
            uuidMap[imageView] = token
        }
    }
    
    func cancel(for imageView: UIImageView){
        if let uuid = uuidMap[imageView]{
            imageLoader.cancelLoad(uuid)
            uuidMap.removeValue(forKey: imageView)
        }
    }
    
}
