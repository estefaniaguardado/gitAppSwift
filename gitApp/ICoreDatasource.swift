//
// Created by Estefania Guardado on 24.04.17.
// Copyright (c) 2017 Larsecg. All rights reserved.
//

import Foundation

protocol ICoreDatasource{
    func saveRepositoriesData(data: Repository)
    func deleteRepositoriesData()
    func fetchRepositoriesData() -> [Repository]

    func saveQueryTerm(term: String)
}