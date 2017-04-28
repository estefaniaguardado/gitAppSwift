//
// Created by Estefania Guardado on 24.04.17.
// Copyright (c) 2017 Larsecg. All rights reserved.
//

import UIKit
import CoreData

class DAO: ICoreDatasource {

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

    func saveQueryTerm(term: String) -> NSManagedObject {
        let queriesCoreData = fetchQueries()

        for (_, queryObject) in queriesCoreData.enumerated() {
            let queryTerm = queryObject.value(forKey: "queryTerm") as! String
            if queryTerm == term {
                return queryObject
            }
        }

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return NSManagedObject()
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Query", in: managedContext)!

        let query = NSManagedObject.init(entity: entity, insertInto: managedContext)

        query.setValue(term, forKey: "queryTerm")

        do {
            try managedContext.save()
            return query
        } catch let error as NSError {
            print("Could dont save: \(error), \(error.userInfo)")
            return NSManagedObject()
        }

    }

    func fetchQueries() -> [NSManagedObject] {
        var objects = [NSManagedObject]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return objects
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Query")

        do {
            objects = try managedContext.fetch(fetchRequest)
            return objects
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return objects
        }

    }

}
