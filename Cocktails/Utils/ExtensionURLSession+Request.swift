//
//  ExtensionURLSession+Request.swift
//  Cocktails
//
//  Created by Consultant on 7/2/22.
//

import Foundation

extension URLSession{
    
    func getRequest<T: Codable>(components: URLComponents?, decoding: T.Type, completion: @escaping(Result<T, Error>) -> ()){
        
        guard let url = components?.url else {
                completion(.failure(RequestError.invalidUrl))
                return
        }
        let urlRequest = URLRequest(url: url, timeoutInterval: 10)
        URLSession.shared.dataTask(with: urlRequest){ data, response, error in
            if let error = error {
                completion(.failure(RequestError.failed(error: error)))
            }
            
            guard data != nil else{
                completion(.failure(RequestError.unknownError))
                return
            }
            
            do{
                let jsonResult = try JSONDecoder().decode(decoding, from: data!)
                completion(.success(jsonResult))
            }catch{
                completion(.failure(RequestError.errorDecode))
            }
        }.resume()
    }
}

