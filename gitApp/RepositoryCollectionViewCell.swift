//
//  RepositoryCollectionViewCell.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit

class RepositoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ownerImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var forkCount: UILabel!
    
    
    func setData(repositoryData:Repository, imageOwner:UIImage) {
        nameLabel.text = repositoryData.repoName
        ownerName.text = repositoryData.ownerName
        forkCount.text = "\(repositoryData.forksCount)"
        ownerImage.image = imageOwner
    }
    

}
