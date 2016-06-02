//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Yifan on 5/30/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import UIKit
import Twitter
import CoreData

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    
    var managedObjectContext: NSManagedObjectContext? =
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext

    private let prefs = NSUserDefaults.standardUserDefaults()
    
    private var searchHistory = [String]() {
        didSet {
            if !searchHistory.isEmpty {
                prefs.setObject(searchHistory, forKey: Storyboard.SearchHistory)
            }
        }
    }

    
    var tweets = [Array<Twitter.Tweet>]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var searchText: String? {
        didSet {
            tweets.removeAll()
            searchForTweets()
            //super.navigationController?.topViewController
            navigationItem.title = searchText
            if (searchText != nil) {
                addHistory(searchText!)
            }
        }
    }
    
    private func addHistory(text: String) {
        var index : Int?
        repeat {
            index = searchHistory.indexOf(text)
            if index != nil {
                searchHistory.removeAtIndex(index!)
            }
        } while (index != nil)

        searchHistory.insert(text, atIndex: 0)
        if searchHistory.count>100 {
            searchHistory.removeLast()
        }
    }
    
    private var twitterRequest: Twitter.Request? {
        if let query = searchText where !query.isEmpty {
            return Twitter.Request(search: query + " -filter:retweets", count: 100)
        }
        return nil
    }
    
    private var lastTwitterRequest : Twitter.Request?
    
    private func searchForTweets()
    {
        if let request = twitterRequest {
            lastTwitterRequest = request
            request.fetchTweets { [weak weakSelf = self] newTweets in
                dispatch_async(dispatch_get_main_queue()) {
                    if request == weakSelf?.lastTwitterRequest {
                        if !newTweets.isEmpty {
                            weakSelf?.tweets.insert(newTweets, atIndex: 0)
                            weakSelf?.updataDatabase(newTweets)
                        }
                    }
                }
            }
        }
    }
    
    private func printDatabaseStatistics() {
        managedObjectContext?.performBlock {
            if let results = try? self.managedObjectContext!.executeFetchRequest(NSFetchRequest(entityName: "TwitterUser")) {
                print("\(results.count) TwitterUser")
            }
            
            let tweetCount = self.managedObjectContext!.countForFetchRequest(NSFetchRequest(entityName: "Tweet"), error: nil)
            print("\(tweetCount) Tweets")
        }
    }
    
    private func updataDatabase(newTweets: [Twitter.Tweet]) {
        managedObjectContext?.performBlock {
            for twitterInfo in newTweets {
                // create a new, unique Tweet with
                _ = Tweet.tweetWithTwitterInfo(twitterInfo, inManagedObjectContext: self.managedObjectContext!)
            }
            
            do {
                try self.managedObjectContext?.save()
            } catch let error {
                print("Core Data Error : \(error)")
            }
        }
        printDatabaseStatistics()
        print("done printing database statistics")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        if let history = prefs.arrayForKey(Storyboard.SearchHistory) as? [String] {
            searchHistory = history
        } else {
            prefs.setObject(searchHistory, forKey: Storyboard.SearchHistory)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }

    private struct Storyboard {
        static let TweetCellIdentifier = "Tweet"
        static let ShowMentionsDetails = "ShowDetails"
        static let SearchHistory = "TweetSearchHistory"
        static let TweetersMentioningSearchTerm = "TweetersMentioningSearchTerm"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.TweetCellIdentifier, forIndexPath: indexPath)

        let tweet = tweets[indexPath.section][indexPath.row]
        
        if let tweetCell = cell as? TweetTableViewCell {
            tweetCell.tweet = tweet
        }

        return cell
    }
    
    @IBOutlet weak var searchTextField: UITextField!
        {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchText = textField.text
        return true
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Storyboard.ShowMentionsDetails {
            if let tweetCell = sender as? TweetTableViewCell {
                if let tvc = segue.destinationViewController as? DetialTableViewController {
                    tvc.tweet = tweetCell.tweet
                }
            }
        }
        
        if segue.identifier == Storyboard.TweetersMentioningSearchTerm {
            if let tweetersTVC = segue.destinationViewController as? TweetersTableViewController {
                tweetersTVC.mention = searchText
                tweetersTVC.managedObjectConetext = managedObjectContext
            }
        }
    }
}

extension UIViewController {
    var contentViewController : UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.contentViewController ?? self
        } else {
            return self
        }
    }
}
