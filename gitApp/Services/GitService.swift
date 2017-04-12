//
//  GitService.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

class GitService: IRepositoryDataSource{

    func getRepositories(searchTerm:String, completion:@escaping (_ repositoriesData: Array<Repository>?, _ error:NSError?) -> Void) -> Void {
        
        var repositories = [Repository]()
        
        var requestURL = URLRequest (url: URL (string: "https://api.github.com/search/repositories?q=topic:" + searchTerm + "&sort=stars&order=desc")!)
        
        //"https://api.github.com/search/repositories?q=topic:helloworld&sort=stars&order=desc"
        
        requestURL.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: requestURL) {
            data, response, error in
        
            if (error != nil) {
                print("ERROR=\(error)")
                completion(repositories, error as NSError?)
            }
            
            let response = String (data: data!, encoding: String.Encoding.utf8)
            print("RESPONSE = \(response)")
            
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    repositories = self.getArrayOfRepositories(dictionary: convertedJsonIntoDict)
                    completion(repositories, error as NSError?)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }

        task.resume()
    }
    
    func getArrayOfRepositories(dictionary:NSDictionary) -> Array<Repository> {
        let items = [[dictionary.value(forKey: "items")][0]][0] as! Array<NSDictionary>
        
        var repositoryArray = [Repository]()
        
        for (_, item) in items.enumerated(){
            repositoryArray.append(self.initializeRepositoryData(data: item))
        }
        
        return repositoryArray
    }
    
    func initializeRepositoryData(data:NSDictionary) -> Repository {
        let itemName = data.value(forKey: "name") as! String
        let itemLanguage = (data.value(forKey: "language") as? String != nil) ?
                            data.value(forKey: "language") as! String : ""
        let itemForks = data.value(forKey: "forks_count") as! Int
        let owner = data.value(forKey: "owner") as! NSDictionary
        let loginOwner = owner.value(forKey: "login") as! String
        let avatarOwner = (owner.value(forKey: "avatar_url") as? String != nil) ?
                           owner.value(forKey: "avatar_url") as! String : ""
        
        return Repository.init(name: itemName,
                               repoLanguage: itemLanguage,
                               forks: itemForks,
                               owner: loginOwner,
                               imageURL: URL.init(string: avatarOwner)!)
        
    }

}
