//
// Created by Estefania Guardado on 24.04.17.
// Copyright (c) 2017 Larsecg. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler: ICoreDatasource {

    func save(data: Repository) {
        guard let appDelegate =
        UIApplication.shared.delegate as? AppDelegate else {
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

}