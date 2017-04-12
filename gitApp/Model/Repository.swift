//
//  Repositorie.swift
//  gitApp
//
//  Created by Estefania Guardado on 06.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import Foundation

struct Repository {
    var repoName: String
    var language: String
    var forksCount: Int
    var ownerName: String
    var ownerAvatar: URL

    init(name:String, repoLanguage: String, forks: Int, owner: String, imageURL: URL) {
        repoName = name
        language = repoLanguage
        forksCount = forks
        ownerName = owner
        ownerAvatar = imageURL
    }

}
