//
//  Repositorie.swift
//  gitApp
//
//  Created by Estefania Guardado on 06.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

struct Repository {
    var id: Int
    var repoName: String
    var language: String
    var forksCount: Int
    var ownerName: String
    var ownerAvatar: URL

    init(identifier: Int, name: String, repoLanguage: String, forks: Int, owner: String, imageURL: URL) {
        id = identifier
        repoName = name
        language = repoLanguage
        forksCount = forks
        ownerName = owner
        ownerAvatar = imageURL
    }

}
