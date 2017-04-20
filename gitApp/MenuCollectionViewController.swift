//
//  MenuCollectionViewController.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit
import MBProgressHUD
import DZNEmptyDataSet

private let reuseIdentifier = "Cell"
private let blueDarkColor = UIColor.init(red: 0.101, green: 0.321, blue: 0.462, alpha: 0) //26.82.118

class MenuCollectionViewController: UICollectionViewController, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    private let gitService = GitService()
    private var repositoriesData = [Repository]()
    private var downloadedImages = [UIImage]()
    
    private var pageNumber = 1
    private var isLoading = false
    private var searchActive = false
    private var searchTerm = String()
    private var resultsCount = Int()
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTextField.delegate = self
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        navigationController?.navigationBar.barTintColor = blueDarkColor
    }

    @IBAction func tappedSearch(_ sender: UIBarButtonItem) {
        self.isLoading = false
        self.searchActive = false
        self.searchTextField.resignFirstResponder()
        let query = searchTextField.text?.trimmingCharacters(in: .whitespaces)
        if (query?.isEmpty)!{
            self.presentAlertWhenAccessToData(title: "Empty search",
                                         message: "Complete with search term for the researching")
        } else {
            searchTerm = (query?.replacingOccurrences(of: " ", with: "-"))!
            searchTextField.text = searchTerm
            customizationOutlets(isEnable: false, color: UIColor.gray)
            getGitData()
        }
    }
    
    func presentAlertWhenAccessToData(title:String, message: String){
        let alert = UIAlertController.init(title: title,
                                           message: message,
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

    func getGitData () -> Void {
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.label.text = "Searching"
        progressHUD.mode = .indeterminate

        gitService.getRepositories(searchTerm: searchTerm, pageNumber: String(pageNumber)) {
            results, error in
            
            let loadingCollection = DispatchGroup()
            loadingCollection.enter()
            
            if let error = error {
                print("Error searching : \(error)")
                return
                
            } else if ((results?.isEmpty)! && !self.searchActive) {
                loadingCollection.leave()
                loadingCollection.notify(queue: .main){
                    progressHUD.hide(animated: true)
                    self.customizationOutlets(isEnable: true, color: .white)
                    self.presentAlertWhenAccessToData(title: "Don't found results", message: "")
                }
                return
                
            } else if ((results?.isEmpty)! && self.searchActive) {
                loadingCollection.leave()
                loadingCollection.notify(queue: .main){
                    self.searchActive = false
                    progressHUD.hide(animated: true)
                    self.customizationOutlets(isEnable: true, color: .white)
                }
                return
                
            } else {
                
                var lastIndexResults = Int()
                
                if (self.isLoading) {
                    self.repositoriesData += results!
                    lastIndexResults = self.resultsCount
                    self.resultsCount += (results?.count)!
                } else {
                    self.repositoriesData.removeAll()
                    self.repositoriesData = results!
                    self.downloadedImages.removeAll()
                    self.resultsCount = 0
                    lastIndexResults = self.resultsCount
                    self.resultsCount = (results?.count)!
                }
                
                DispatchQueue.main.async{
                    
                    var arrayIndexPath = [IndexPath]()

                    for index in lastIndexResults...self.resultsCount - 1{
                        let repository = self.repositoriesData[index]
                        self.downloadImageFromURL(imageURL: repository.ownerAvatar)
                        arrayIndexPath.append((IndexPath.init(row: index, section: 0)))
                    }
                    
                    if (self.isLoading){
                        self.collectionView?.insertItems(at: arrayIndexPath)
                        self.isLoading = false
                    } else{
                        self.collectionView?.reloadData()
                    }

                    loadingCollection.leave()
                }
                
                loadingCollection.notify(queue: .main){
                    self.customizationOutlets(isEnable: true, color: .white)
                    progressHUD.hide(animated: true)
                    self.searchActive = true
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
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage.init(named: "repository")
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let titleText = "Not repositories to show"
        
        let attributes = [
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16),
            NSForegroundColorAttributeName: UIColor.lightGray
        ]
        
        return NSAttributedString.init(string: titleText, attributes: attributes)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maxOffset - offset) <= 0 {
            if (!isLoading && searchActive) {
                isLoading = true
                pageNumber += 1
                getGitData()
            }
        }
    }
    
}
