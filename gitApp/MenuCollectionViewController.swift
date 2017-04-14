//
//  MenuCollectionViewController.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit
import MBProgressHUD

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController, UITextFieldDelegate {
    
    private let gitService = GitService()
    private var repositoriesData = [Repository]()
    private var downloadedImages = [UIImage]()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
    }

    @IBAction func tappedSearch(_ sender: UIBarButtonItem) {
        self.searchTextField.resignFirstResponder()
        let query = searchTextField.text?.trimmingCharacters(in: .whitespaces)
        if (query?.isEmpty)!{
            self.presentAlertIncompleteInformation()
        } else {
            let searchTerm = query?.replacingOccurrences(of: " ", with: "-")
            searchTextField.text = searchTerm
            customizationOutlets(isEnable: false, color: UIColor.gray)
            getGitData(term: searchTerm!)
        }
    }
    
    func presentAlertIncompleteInformation(){
        let alert = UIAlertController.init(title: "Empty search",
                                           message: "Complete with search term for the researching",
                                           preferredStyle: .alert)
        
        let defaultAction = UIAlertAction.init(title: "Ok",
                                               style: .default)
        
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func customizationOutlets(isEnable:Bool, color:UIColor) {
        self.searchTextField.isUserInteractionEnabled = isEnable
        self.searchTextField.textColor = color
        self.searchButton.isEnabled = isEnable
        self.searchButton.tintColor = color
    }

    func getGitData(term: String) -> Void {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = "Searching"
        progressHUD.mode = .indeterminate

        gitService.getRepositories(searchTerm: term) {
            results, error in
            
            if let error = error {
                print("Error searching : \(error)")
            } else {
                self.repositoriesData = results!
                
                self.downloadedImages.removeAll()
                
                let loadingCollection = DispatchGroup()
                loadingCollection.enter()
                
                DispatchQueue.main.async{
                    for (_, repository) in self.repositoriesData.enumerated() {
                        self.downloadImageFromURL(imageURL: repository.ownerAvatar)
                    }
                    
                    self.collectionView?.reloadData()

                    loadingCollection.leave()
                }
                
                loadingCollection.notify(queue: .main){
                    self.customizationOutlets(isEnable: true, color: .black)
                    progressHUD.hide(animated: true)
                }
            }
        }
        
    }
    
    func downloadImageFromURL(imageURL: URL) {
        let imageData = NSData(contentsOf: imageURL)!
        downloadedImages.append(UIImage(data: imageData as Data)!)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return repositoriesData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let viewCellData = repositoriesData[indexPath.row]
        let imageOwnerRepository = downloadedImages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RepositoryCollectionViewCell
        cell.setData(repositoryData: viewCellData, imageOwner: imageOwnerRepository)
        
        return cell
    }
}
