//
//  HomeViewController.swift
//  InstagramClone
//
//  Created by Violet Wei on 2018-12-27.
//  Copyright © 2018 Violet Wei. All rights reserved.
//

import UIKit
import SDWebImage
import ImagePicker

class HomeViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    fileprivate var isLoadingPost = false
    let refreshControl = UIRefreshControl()
    
    var posts = [Post]()
    var users = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 521
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        tableView.refreshControl = refreshControl
        activityIndicatorView.startAnimating()
        loadPosts()
    }
    
    @objc func refresh() {
        posts.removeAll()
        users.removeAll()
        loadPosts()
    }
    
    func loadPosts() {
        isLoadingPost = true
        Api.Feed.getRecentFeed(withId: Api.User.CURRENT_USER!.uid, start: posts.first?.timestamp, limit: 3  ) { (results) in
            if results.count > 0 {
                results.forEach({ (result) in
                    self.posts.append(result.0)
                    self.users.append(result.1)
                })
            }
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            self.isLoadingPost = false
        
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }

    }
    private func displayNewPosts(newPosts posts: [Post]) {
        guard posts.count > 0 else {
            return
        }        
        var indexPaths:[IndexPath] = []
        self.tableView.beginUpdates()
        for post in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: post, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .none)
        self.tableView.endUpdates()
    }
    
    
    @IBAction func cameraBtnDidTapped(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        guard let profileImg = images.first else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        ProgressHUD.show("Waiting...", interaction: false)
        if let imageData = UIImageJPEGRepresentation(profileImg, 0.1) {
            let ratio = profileImg.size.width / profileImg.size.height
            HelperService.uploadDataToServer(data: imageData, videoUrl: nil, ratio: ratio, caption: "", onSuccess: {
                self.dismiss(animated: true, completion: nil)
                self.posts.removeAll()
                self.users.removeAll()
                self.loadPosts()
            })
            
        } else {
            ProgressHUD.showError("Profile Image can't be empty")
        }
        
    }
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CommentSegue" {
            let commentVC = segue.destination as! CommentViewController
            let postId = sender  as! String
            commentVC.postId = postId
        }
        
        if segue.identifier == "Home_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender  as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Home_HashTagSegue" {
            let hashTagVC = segue.destination as! HashTagViewController
            let tag = sender  as! String
            hashTagVC.tag = tag
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.isEmpty {
            return 0
        }
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! HomeTableViewCell
        if posts.isEmpty {
            return UITableViewCell()
        }
        let post = posts[indexPath.row]
        let user = users[indexPath.row]
        cell.post = post
        cell.user = user
        cell.delegate = self
        return cell
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
           
            guard !isLoadingPost else {
                return
            }
            isLoadingPost = true

            guard let lastPostTimestamp = self.posts.last?.timestamp else {
                isLoadingPost = false
                return
            }
            Api.Feed.getOldFeed(withId: Api.User.CURRENT_USER!.uid, start: lastPostTimestamp, limit: 5) { (results) in
                if results.count == 0 {
                    return
                }
                for result in results {
                    self.posts.append(result.0)
                    self.users.append(result.1)
                }
                self.tableView.reloadData()

                self.isLoadingPost = false
            }

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name.init("stopVideo"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: NSNotification.Name.init("playVideo"), object: nil)

    }
}

extension HomeViewController: HomeTableViewCellDelegate {
    
    func goToCommentVC(postId: String) {
        performSegue(withIdentifier: "CommentSegue", sender: postId)
    }
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Home_ProfileSegue", sender: userId)
    }
    
    func goToHashTag(tag: String) {
        performSegue(withIdentifier: "Home_HashTagSegue", sender: tag)
    }
}
