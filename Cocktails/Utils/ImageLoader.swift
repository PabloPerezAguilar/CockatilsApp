//
//  ImageLoader.swift
//  Cocktails
//
//  Created by Consultant on 7/5/22.
//

import UIKit

class ImageLoader{
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    
    func loadImage(_ url:URL, _ completation: @escaping(Result<UIImage, Error>) -> Void) -> UUID?{
        //Check if image is in cache
        if let image = loadedImages[url]{
            completation(.success(image))
            return nil
        }
        
        let uuid = UUID()
        let task = URLSession.shared.dataTask(with: url){ data, result, error in
            // When data is completed remobe from running requests
            defer {self.runningRequests.removeValue(forKey: uuid)}
            
            //Convert data to UIImage
            if let data = data, let image = UIImage(data: data){
                self.loadedImages[url] = image
                completation(.success(image))
                return
            }
            
            guard let error = error else {
                return
            }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                completation(.failure(error))
                return
            }
        }
        task.resume()
        //Return uuid created and added to runningRequests (executed before converting image)
        runningRequests[uuid] = task
        return uuid
    }
    
    func cancelLoad(_ uuid:UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}
