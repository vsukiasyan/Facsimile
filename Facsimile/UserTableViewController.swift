//
//  UserTableViewController.swift
//  Facsimile
//
//  Created by Vic Sukiasyan on 5/8/18.
//  Copyright © 2018 Vic Sukiasyan. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController {
    
    var usernames = [String]()
    var objectIds = [String]()
    var isFollowing = [String:Bool]()
    
    var refresher: UIRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        updateTable()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(updateTable), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
    }
    
    @objc func updateTable() {
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: PFUser.current()?.username)
        query?.findObjectsInBackground(block: { (users, error) in
            if error != nil {
                print(error)
            } else if let users = users {
                for object in users {
                    if let user = object as? PFUser {
                        if let username = user.username {
                            if let objectId = user.objectId {
                                let usernameArray = username.components(separatedBy: "@")
                                self.usernames.append(usernameArray[0])
                                self.objectIds.append(objectId)
                                
                                let query = PFQuery(className: "Following")
                                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                                query.whereKey("following", equalTo: objectId)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                    if let objects  = objects {
                                        if objects.count > 0 {
                                            self.isFollowing[objectId] = true
                                        } else {
                                            self.isFollowing[objectId] = false
                                        }
                                        if self.usernames.count == self.isFollowing.count {
                                            self.tableView.reloadData()
                                            
                                            self.refresher.endRefreshing()
                                        }
                                        
                                    }
                                })
                            }
                        }
                    }
                }
                
            }
        })
    }

   
    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if let followsBoolean = isFollowing[objectIds[indexPath.row]] {
            if followsBoolean {
                isFollowing[objectIds[indexPath.row]] = false
                cell?.accessoryType = UITableViewCellAccessoryType.none
                
                let query = PFQuery(className: "Following")
                query.whereKey("follower", equalTo: PFUser.current()?.objectId)
                query.whereKey("following", equalTo: objectIds[indexPath.row])
                
                query.findObjectsInBackground(block: { (objects, error) in
                    if let objects = objects {
                        for object in objects {
                            object.deleteInBackground()
                        }
                      
                    }
                })
            } else {
                isFollowing[objectIds[indexPath.row]] = true
                cell?.accessoryType = UITableViewCellAccessoryType.checkmark
                
                let following = PFObject(className: "Following")
                following["follower"] = PFUser.current()?.objectId
                following["following"] = objectIds[indexPath.row]
                following.saveInBackground()
            }
        }
    }
        
    }
    



