//
//  IRepositoryDataSource.swift
//  gitApp
//
//  Created by Estefania Guardado on 08.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

protocol IRepositoryDataSource {
    
    func getRepositories(completion:@escaping (_ repositories: Array<Repository>?, _ error:NSError?) -> Void) -> Void

}
