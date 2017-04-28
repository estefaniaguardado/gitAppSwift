//
//  MenuCollectionViewController.swift
//  gitApp
//
//  Created by Estefania Guardado on 03.04.17.
//  Copyright © 2017 Larsecg. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import JDStatusBarNotification
import Kingfisher
import CoreData

private let reuseIdentifier = "Cell"
private let blueDarkColor = UIColor.init(red: 0.101, green: 0.321, blue: 0.462, alpha: 0) //26.82.118

class MenuCollectionViewController: UICollectionViewController, UITextFieldDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    private let gitService = GitService()
    private let coreDataHandler = CoreDataHandler()
    private var repositoriesData = [Repository]()
    private var queryObject: NSManagedObject!

    private var pageNumber = 1
    private var isLoading = false
    private var searchActive = false
    private var searchTerm = String()
    private var resultsCount = Int()
    private let loadingCollection = DispatchGroup()

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet var searchButton: UIBarButtonItem!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)

        self.title = String.init("JDStatusBarNotification")

        JDStatusBarNotification.addStyleNamed("statusLoading") {
            style in

            style?.barColor = UIColor.gray
            style?.textColor = UIColor.white
            style?.animationType = .bounce
            style?.progressBarHeight = 5.0
            style?.progressBarPosition = .below

            return style
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchTextField.delegate = self
        collectionView?.emptyDataSetSource = self
        collectionView?.emptyDataSetDelegate = self
        navigationController?.navigationBar.barTintColor = blueDarkColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.repositoriesData = coreDataHandler.fetchRepositoriesData()
        if repositoriesData.count > 0 {
            self.collectionView?.reloadData()
        }
    }

    @IBAction func tappedSearch(_ sender: UIBarButtonItem) {
        self.isLoading = false
        self.searchActive = false
        self.searchTextField.resignFirstResponder()
        let query = searchTextField.text?.trimmingCharacters(in: .whitespaces)
        if (query?.isEmpty)! {
            self.presentAlertWhenAccessToData(title: "Empty search",
                    message: "Complete with search term for the researching")
        } else {
            searchTerm = (query?.replacingOccurrences(of: " ", with: "-"))!
            searchTextField.text = searchTerm
            customizationOutlets(isEnable: false, color: .gray)
            self.repositoriesData.removeAll()
            self.resultsCount = 0
            queryObject = coreDataHandler.saveQueryTerm(term: searchTerm)
            coreDataHandler.deleteRepositoriesData()
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache()
            getGitData()
        }
    }

    func presentAlertWhenAccessToData(title: String, message: String) {
        let alert = UIAlertController.init(title: title,
                message: message,
                preferredStyle: .alert)

        let defaultAction = UIAlertAction.init(title: "Ok",
                style: .default)

        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }

    func customizationOutlets(isEnable: Bool, color: UIColor) {
        self.searchTextField.isUserInteractionEnabled = isEnable
        self.searchTextField.textColor = color
        self.searchButton.isEnabled = isEnable
    }

    func getGitData() -> Void {

        JDStatusBarNotification.show(withStatus: "Loading...")

        gitService.getRepositories(searchTerm: searchTerm, pageNumber: String(pageNumber)) {
            results, error in

            DispatchQueue.main.async {

                self.loadingCollection.enter()

                let isEmptyResults = (results?.isEmpty)! && !self.searchActive
                let existResults = isEmptyResults == false ? true : false
                let isSearchFinished = (results?.isEmpty)! && self.searchActive

                if let error = error {
                    return print("Error searching : \(error)")
                }

                if (isEmptyResults) {
                    return self.presentAlertOfEmptyResults()
                }

                if (isSearchFinished) {
                    return self.enableElementsInView()
                }

                if (existResults) {
                    let lastIndexResults: Int = self.resultsCount
                    return self.reloadRepositoriesData(byLastIndex: lastIndexResults, dataResults: results!)
                }
            }
        }
    }

    func presentAlertOfEmptyResults() {
        loadingCollection.leave()
        loadingCollection.notify(queue: .main) {
            self.presentAlertWhenAccessToData(title: "Don't found results", message: "")
            self.customizationOutlets(isEnable: true, color: .black)
            JDStatusBarNotification.dismiss()
        }
    }

    func enableElementsInView() {
        self.loadingCollection.leave()
        self.loadingCollection.notify(queue: .main) {
            self.searchActive = false
            JDStatusBarNotification.dismiss()
            self.customizationOutlets(isEnable: true, color: .black)
        }
    }

    func arrayIndexPath(by: Int) -> [IndexPath] {
        var array = [IndexPath]()

        for index in by...self.resultsCount - 1 {
            array.append((IndexPath.init(row: index, section: 0)))
        }

        return array
    }

    func reloadRepositoriesData(byLastIndex: Int, dataResults: [Repository]) {

        for (_, dataRepository) in dataResults.enumerated() {
            coreDataHandler.saveRepositoriesData(data: dataRepository)
        }

        self.resultsCount += (dataResults.count)
        self.repositoriesData += dataResults

        if (byLastIndex > 0) {
            self.collectionView?.insertItems(at: self.arrayIndexPath(by: byLastIndex))
            self.isLoading = false
        } else {
            self.collectionView?.reloadData()
            collectionViewLayout.collectionView?.scrollToItem(at: IndexPath.init(row: 0, section: 0),
                    at: .top, animated: true)
        }

        self.loadingCollection.leave()
        self.loadingCollection.notify(queue: .main) {
            self.searchActive = true
            JDStatusBarNotification.dismiss()
            self.customizationOutlets(isEnable: true, color: .black)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return repositoriesData.count
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as! RepositoryCollectionViewCell).ownerImage.kf.cancelDownloadTask()
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let viewCellData = repositoriesData[indexPath.row]
        let urlAvatar = URL.init(string: viewCellData.ownerAvatar)

        _ = (cell as! RepositoryCollectionViewCell).ownerImage.kf.setImage(with: urlAvatar,
                placeholder: nil, options: [.transition(ImageTransition.fade(1))],
                progressBlock: { receivedSize, totalSize in
                    print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")
                },
                completionHandler: { image, error, cacheType, imageURL in
                    print("\(indexPath.row + 1): Finished")
                })
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let viewCellData = repositoriesData[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! RepositoryCollectionViewCell
        cell.setData(repositoryData: viewCellData)
        cell.ownerImage.kf.indicatorType = .activity

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
