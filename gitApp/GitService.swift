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
        let items = [[dictionary.value(forKey: "items")][0]][0] as! Array<NSDictionary>
        
        for (index, item) in items.enumerated(){
            let itemName = item.value(forKey: "name") as! String
            let itemLanguage = item.value(forKey: "language") as! String
            let itemForks = item.value(forKey: "forks_count") as! Int
            let owner = item.value(forKey: "owner") as! NSDictionary
            let loginOwner = owner.value(forKey: "login") as! String
            let avatarOwner = owner.value(forKey: "avatar_url") as! String
            
            print(item, index)
            
            
            
        }
        
        return []
    }
    
    func initializeRepositoryData(data:Dictionary<String, AnyObject>) -> Repository {
        let repository = Repository.init(name: "", repoLanguage: "", forks: 0, owner: "", imageURL: URL.init(string: "")!)
        
        return repository
    }

}
