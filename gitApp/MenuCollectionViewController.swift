//
//  MenuCollectionViewController.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    private let gitService = GitService()
    private var repositoriesData = [Repository]()
    private var viewModel = [NSDictionary]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        repositoriesData = gitService.getRepositories()
        updateCollectionViewModel()

    }
    
    func updateCollectionViewModel() {
        for (_, repository) in repositoriesData.enumerated() {
            
            let model:NSDictionary = [
                "nib" : "ResultCollectionViewCell",
                "data" : repository
            ]
            
            viewModel.append(model)
        }
        
        registerNibs()
        
    }
    
    func registerNibs() {
        let collectionView = self.collectionView
        let registeredNibs = NSMutableSet()
        
        for (_, cellViewModel) in viewModel.enumerated() {
            
            let nibFile = cellViewModel.value(forKey: "nib") as! String
            
            if registeredNibs.contains(nibFile) {
                registeredNibs.add(nibFile)
                
                let nib = UINib.init(nibName: nibFile, bundle: nil)
                collectionView?.register(nib, forCellWithReuseIdentifier: reuseIdentifier)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //let cellViewModel:NSDictionary = viewModel[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        //if cellM.responds(to: #selector("data")){
        //    cellM.perform(#selector("data"), with: cellViewModel.value(forKey: "data"))
        //}

        cell.backgroundColor = UIColor .blue
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
