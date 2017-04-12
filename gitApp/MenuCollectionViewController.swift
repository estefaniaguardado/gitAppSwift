//
//  MenuCollectionViewController.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController, UITextFieldDelegate {
    
    private let gitService = GitService()
    private var repositoriesData = [Repository]()
    private var viewModel = [NSDictionary]()
    private var downloadedImages = [UIImage]()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        
    }

    @IBAction func tappedSearch(_ sender: UIBarButtonItem) {
        self.searchTextField.resignFirstResponder()
        
        if (searchTextField.text?.trimmingCharacters(in: .whitespaces).isEmpty)!{
            self.presentAlertIncompleteInformation()
        } else{
            let searchTerm:String = (searchTextField.text!).replacingOccurrences(of: " ", with: "-")
            searchTextField.text = searchTerm
            self.searchTextField.isUserInteractionEnabled = false
            self.searchTextField.textColor = UIColor.gray
            self.searchButton.isEnabled = false
            self.searchButton.tintColor = UIColor.gray
            getGitData(term: searchTerm)
        }
    }
    
    func presentAlertIncompleteInformation(){
        let alert = UIAlertController.init(title: "Empty search",
                                           message: "Complete with search term for the researching",
                                           preferredStyle: UIAlertControllerStyle.alert)
        
        let defaultAction = UIAlertAction.init(title: "Ok",
                                               style: UIAlertActionStyle.default)
        
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    func getGitData(term:String) -> Void {
        gitService.getRepositories(searchTerm: term){
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
            }
                
            else {
                self.repositoriesData = results!
                
                let loadingCollection = DispatchGroup()
                loadingCollection.enter()
                
                DispatchQueue.main.async{
                    for (_, repository) in self.repositoriesData.enumerated() {
                        self.downloadImageFromURL(imageURL: repository.ownerAvatar!)
                    }
                    
                    self.collectionView?.reloadData()

                    loadingCollection.leave()
                }
                
                loadingCollection.notify(queue: .main){
                    self.searchTextField.isUserInteractionEnabled = true
                    self.searchTextField.textColor = UIColor.black
                    self.searchButton.isEnabled = true
                    self.searchButton.tintColor = UIColor.blue
                }
            }
        }
        
    }
    
    func downloadImageFromURL(imageURL:URL) {
        let imageData:NSData = NSData(contentsOf: imageURL)!
        downloadedImages.append(UIImage(data: imageData as Data)!)
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
        return repositoriesData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCellData:Repository = repositoriesData[indexPath.row]
        let imageOwnerRepository:UIImage = downloadedImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RepositoryCollectionViewCell
        cell.setData(repositoryData: viewCellData, imageOwner: imageOwnerRepository)
        
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
