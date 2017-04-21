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

extension Repository: Hashable {
    
    var hashValue: Int {
        return id.hashValue | repoName.hashValue | ownerName.hashValue
    }
}

extension Repository: Equatable {
    
    public static func ==(lhs: Repository, rhs: Repository) -> Bool {
        var equatable = false
        
        equatable = lhs.id == rhs.id ? true : false
        equatable = lhs.repoName == rhs.repoName ? true : false
        equatable = lhs.ownerName == rhs.ownerName ? true : false

        return equatable
    }
    

}
