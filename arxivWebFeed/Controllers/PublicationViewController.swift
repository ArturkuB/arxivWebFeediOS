//
//  PublicationViewController.swift
//  arxivWebFeed
//
//  Created by Artur-PC on 24/04/2022.
//

import Foundation
import UIKit
import SwiftSoup
import RealmSwift
import Alamofire

class PublicationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
}

class PublicationViewController: UITableViewController, URLSessionDelegate {
    
    
    var progressView: UIProgressView?
    var indicator = UIActivityIndicatorView()
    var alertView = UIAlertController()
    var noInternetFlag: Bool = false
    var pdfURL: URL?
    var filename: String?
    var parsingDone = false
    let realm = try! Realm()
    var publications: Results<Publication>?
    var publicationsArray: [Publication] = []
    var subscriptionFlag = false
    var selectedSubcategory: Subcategory?{
        didSet {
            if let flag = selectedSubcategory?.subscribed {
                subscriptionFlag = flag
            }
            if Connectivity.isConnectedToInternet {
                let start = CFAbsoluteTimeGetCurrent()
                parsePublications(link: selectedSubcategory!.link, title: selectedSubcategory!.title) { publicationsList, result in
                    if(result == "Success"){
                        if(self.subscriptionFlag == true)
                        {
                            DispatchQueue.main.async {
                                var count = 0
                                publicationsList.forEach{ e in
                                    if self.savePublication(publication: e) {
                                        count+=1
                                    }
                                }
                                self.parsingDone = true
                                let diff = CFAbsoluteTimeGetCurrent() - start
                                print("Parsing with use of database took \(diff) seconds")
                                self.showAlert(counter: count)
                            }
                            self.loadPublications()
                        }
                        else
                        {
                            self.publicationsArray = publicationsList
                            self.parsingDone = true
                            self.loadPublications()
                        }
                    }
                    else
                    {
                        print("PARSING MALFUNCTION")
                        self.loadPublications()
                        self.parsingDone = true
                    }
                }
            }
            else
            {
                noInternetFlag = true
                self.loadPublications()
            }
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadPublications() {
        DispatchQueue.main.async {
            if(self.subscriptionFlag == true)
            {
                self.publications = self.selectedSubcategory?.publications.sorted(byKeyPath: "dateCreated", ascending: true)
            }
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            self.tableView.reloadData()
        }
    }
    
    // MARK: TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(subscriptionFlag == true)
        {
            if(publications?.count == 0)
            {
                return 1
            }
            return publications?.count ?? 0
        }
        else
        {
            if(publicationsArray.count == 0 && (noInternetFlag || parsingDone)){
                return 1
            }
            return publicationsArray.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "publicationCell", for: indexPath) as! PublicationTableViewCell
        
        if subscriptionFlag == true
        {
            if publications != nil {
                if publications?.count != 0 {
                    if let publication = publications?[indexPath.row] {
                        if publication.title != "" && publication.author != "" {
                            cell.titleLabel.text = publication.title
                            cell.authorsLabel.text = publication.author
                        }
                    }
                }
                else
                {
                    cell.titleLabel.text = "Error"
                    cell.authorsLabel.text = "Check internet connection or selectors"
                    tableView.allowsSelection = false
                }
            }
        }
        else
        {
            if publicationsArray.count != 0 {
                
                if publicationsArray[indexPath.row].title != "" && publicationsArray[indexPath.row].author != "" {
                    cell.titleLabel.text = publicationsArray[indexPath.row].title
                    cell.authorsLabel.text = publicationsArray[indexPath.row].author
                }
            }
            else
            {
                if(parsingDone || noInternetFlag){
                    cell.titleLabel.text = "Error"
                    cell.authorsLabel.text = "Check internet connection or selectors"
                    tableView.allowsSelection = false
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var urlPath = ""
        if subscriptionFlag == true {
            urlPath = "https://arxiv.org" + publications![indexPath.row].link
            filename = String(publications![indexPath.row].link.dropFirst(5))
            
        }
        else
        {
            urlPath = "https://arxiv.org" + publicationsArray[indexPath.row].link
            filename = String(publicationsArray[indexPath.row].link.dropFirst(5))
        }
        choiceOptionAlert(link: urlPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Alerts methods
    
    func choiceOptionAlert(link: String) {
        let alert = UIAlertController(title: "Choose a way of displaying PDF", message: "", preferredStyle: .alert)
        
        let downloadAction = UIAlertAction(title: "Download/Open", style: .default) { (downloadAction) in
            if Connectivity.isConnectedToInternet {
                self.checkAndLoad(with: link)
            }
            else
            {
                let alert = UIAlertController(title: "No internet connection", message: "", preferredStyle: .alert)
                self.present(alert,animated: true, completion:{Timer.scheduledTimer(withTimeInterval: 3, repeats:false, block: {_ in
                    self.dismiss(animated: true, completion: nil)
                })})
            }
        }
        let openAction = UIAlertAction(title: "Open with Safari", style: .default) { (openAction) in
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            action in
        }))
        
        
        alert.addAction(downloadAction)
        alert.addAction(openAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(counter: Int){
        let alert = UIAlertController(title: "Added \(counter) new publications", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func showDownloadingAlert(){
        alertView = UIAlertController(title: "Please wait", message: "Downloading pdf.", preferredStyle: .alert)
        
        //  Show it to your users
        present(alertView, animated: true, completion: {
            //  Add your progressbar after alert is shown (and measured)
            let margin:CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: self.alertView.view.frame.width - margin * 2.0 , height: 2.0)
            self.progressView = UIProgressView(frame: rect)
            self.progressView!.progress = 0
            self.progressView!.tintColor = self.view.tintColor
            self.alertView.view.addSubview(self.progressView!)
        })
    }
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 60))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PDFViewController
        destinationVC.pdfURL = pdfURL
    }
}

// MARK: UrlSession methods

extension PublicationViewController:  URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        guard (downloadTask.originalRequest?.url) != nil else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("\(filename).pdf")
        
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            self.pdfURL = destinationURL
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "publicationToPdf", sender: self)
            }
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error ?? "")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64){
        let uploadProgress:Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if(uploadProgress == 1.0){
            alertView.dismiss(animated: true)
        }
        progressView?.progress = uploadProgress
        print(uploadProgress)
    }
}


//MARK: Parsing and Data Manipulation methods

extension PublicationViewController {
    
    func parsePublications(link: String, title: String, completion: @escaping ([Publication], String) -> Void) {
        DispatchQueue.global(qos: .background).async {
            var publicationList: [Publication] = []
            do {
                if let url = URL(string: link) {
                    let start = CFAbsoluteTimeGetCurrent()
                    let html = try String(contentsOf: url)
                    let document = try SwiftSoup.parse(html)
                    let defaults = UserDefaults.standard
                    let titleSelector = defaults.string(forKey: "titleSelector")
                    let authorsSelector = defaults.string(forKey: "authorsSelector")
                    let pdfLinkSelector = defaults.string(forKey: "pdfLinkSelector")
                    let titles: SwiftSoup.Elements = try document.select(titleSelector!)
                    let authors: SwiftSoup.Elements = try document.select(authorsSelector!)
                    let pdfLinks: SwiftSoup.Elements = try document.select(pdfLinkSelector!)
                    
                    if titles.count != 0 {
                        for i in 0...titles.count - 1{
                            let publication = Publication()
                            publication.title = try titles[i].text().replacingOccurrences(of: "Title: ", with: "")
                            publication.author = try authors[i].text()
                            publication.link = try pdfLinks[i].attr("href")
                            publication.publicationTag = publication.link + title
                            publication.dateCreated = Date()
                            publicationList.append(publication)
                        }
                    }
                    // run your work
                    let diff = CFAbsoluteTimeGetCurrent() - start
                    print("Parsing without use of database took \(diff) seconds")
                    completion(publicationList, "Success")
                }
            } catch Exception.Error(_, let message) {
                print(message)
                completion(publicationList, "Error")
            } catch {
                completion(publicationList, "Error")
            }
        }
    }
    
    func checkAndLoad(with url: String){
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent("\(filename).pdf")
        print(destinationURL.path)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            pdfURL = destinationURL
            print("FILE EXISTS")
            self.performSegue(withIdentifier: "publicationToPdf", sender: self)
        }
        else
        {
            print("FILE DOESNT EXISTS")
            guard let url = URL(string: url) else { return }
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
            showDownloadingAlert()
        }
    }
    
    func savePublication(publication: Publication) -> Bool{
        var added = false
        if let currentSubcategory = self.selectedSubcategory {
            do {
                try realm.write {
                    let publ = realm.object(ofType: Publication.self, forPrimaryKey: publication.publicationTag)
                    if publ != nil {
                        print("Duplikat w bazie")
                    }
                    else
                    {
                        currentSubcategory.publications.append(publication)
                        added = true
                    }
                }
            } catch {
                print("Error saving new items, \(error)")
            }
        }
        return added
    }
}
