//
//  GitService.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

class GitService{

    func getResults() {
        
        let searchTerm = "helloWorld"
        
        var requestURL = URLRequest (url: URL (string: "https://api.github.com/search/repositories?q=topic:" + searchTerm + "&sort=stars&order=desc")!)
        
        //"https://api.github.com/search/repositories?q=topic:helloworld&sort=stars&order=desc"
        
        requestURL.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: requestURL) {
            data, response, error in
        
            if (error != nil) {
                print("ERROR=\(error)")
                return
            }
            
            let response = String (data: data!, encoding: String.Encoding.utf8)
            print("RESPONSE = \(response)")
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    _ = self.getArrayOfRepositories(dictionary: convertedJsonIntoDict)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }

            task.resume()
    }
    
    func getArrayOfRepositories(dictionary:NSDictionary) -> Array<Repository> {
        let items:Array<Dictionary<String, AnyObject>> = [[dictionary.value(forKey: "items")][0]][0] as! Array<Dictionary<String, AnyObject>>
        
        return []
    }

}
