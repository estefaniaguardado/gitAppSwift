//
// Created by Estefania Guardado on 24.04.17.
// Copyright (c) 2017 Larsecg. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler: ICoreDatasource {

    func saveRepositoriesData(data: Repository) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "RepositoryData", in: managedContext)!

        let repository = NSManagedObject.init(entity: entity, insertInto: managedContext)

        repository.setValuesForKeys(["id": data.id, "repoName": data.repoName, "ownerName": data.ownerName,
                                     "ownerAvatar": data.ownerAvatar, "language": data.language, "forksCount": data.forksCount])

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could dont save: \(error), \(error.userInfo)")
        }
    }

    func deleteRepositoriesData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RepositoryData")
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Could dont save: \(error), \(error.userInfo)")
        }

    }

    func fetchRepositoriesData() -> [Repository] {
        var objects = [NSManagedObject]()
        var repositories = [Repository]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return repositories
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RepositoryData")

        do {
            objects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        for (_, object) in objects.enumerated() {
            let repository = Repository.init(identifier: object.value(forKey: "id") as! Int,
                    name: object.value(forKey: "repoName") as! String,
                    repoLanguage: object.value(forKey: "language") as! String,
                    forks: object.value(forKey: "forksCount") as! Int,
                    owner: object.value(forKey: "ownerName") as! String,
                    imageURL: object.value(forKey: "ownerAvatar") as! String)
            repositories.append(repository)
        }

        return repositories
    }

}
