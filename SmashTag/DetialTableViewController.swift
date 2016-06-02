//
//  DetialTableViewController.swift
//  SmashTag
//
//  Created by Yifan on 5/31/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import UIKit
import Twitter

class DetialTableViewController: UITableViewController {
    
    var tweet: Twitter.Tweet? {
        didSet {
            if tweet != nil {
                tweetMentions.removeAll()
                //addDisplayItems(MentionTypes.Poster, Items: [tweet!.user])
                addDisplayItems(MentionTypes.Images, Items: tweet!.media)
                addDisplayItems(MentionTypes.Urls, Items: tweet!.urls)
                
                var userMentions = tweet!.userMentions as [AnyObject]
                userMentions.insert(tweet!.user, atIndex: 0)
                
                addDisplayItems(MentionTypes.Users, Items: userMentions)
                addDisplayItems(MentionTypes.Hashtags, Items: tweet!.hashtags)
                tableView.reloadData()
            }
        }
    }
    
    
    
    private func addDisplayItems(Name: MentionTypes, Items: [AnyObject]) {
        if Items.count > 0 {
            tweetMentions.append(
                DetailedSection(Name: Name, Items: Items)
            )
        }
        
    }
    
    private var tweetMentions = [DetailedSection]()
    
    private enum MentionTypes : String {
        case Images
        case Urls
        case Users
        case Hashtags
        case Poster
    }

    private struct DetailedSection {
        var Name: MentionTypes
        var Items: [AnyObject]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweetMentions.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetMentions[section].Items.count
    }
    
    private struct Storyboard {
        static let Mentions = "Mentions"
        static let Images = "Images"
        static let Search = "Search Tweets"
        static let ShowImage = "Show Image"
    }

    private func getColoredDetails(name: MentionTypes, mention: String) -> NSMutableAttributedString
    {
        var myMutableLabelString = NSMutableAttributedString()
        
        var color = UIColor.redColor()
        if !mention.isEmpty
        {
            myMutableLabelString = NSMutableAttributedString(string: mention)
            switch name {
            case .Urls : color = UIColor.blueColor()
            case .Users : color = UIColor.greenColor()
            case .Hashtags : color = UIColor.redColor()
            default:
                break
            }
            myMutableLabelString.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location:0,length: myMutableLabelString.length))
        }
        return myMutableLabelString
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let detail = tweetMentions[indexPath.section].Items[indexPath.row]
        let name = tweetMentions[indexPath.section].Name
        var cellIdentifier = String()
        var cell = UITableViewCell()
        
        switch name {
        case .Urls, .Users, .Hashtags, .Poster:
            cellIdentifier = Storyboard.Mentions
        case .Images:
            cellIdentifier = Storyboard.Images
        }
        if (!cellIdentifier.isEmpty) {
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            
            if let mention = detail as? Twitter.Mention {
                cell.textLabel?.attributedText = getColoredDetails(name, mention: mention.keyword)
            }
            
            if let poster = detail as? Twitter.User {
                cell.textLabel?.attributedText = getColoredDetails(name, mention: "@"+poster.name)
            }
            
            if let mention = detail as? Twitter.MediaItem {
                if let imageCell = cell as? ImageTableViewCell {
                    imageCell.imageURL = mention.url
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let detail = tweetMentions[indexPath.section].Items[indexPath.row]
        var height: CGFloat = UITableViewAutomaticDimension
        if let mediaItem = detail as? MediaItem {
            height = self.tableView.frame.width / CGFloat(mediaItem.aspectRatio)
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detail = tweetMentions[indexPath.section].Items[indexPath.row]
        let name = tweetMentions[indexPath.section].Name
        
        switch name {
        case .Hashtags, .Users:
            performSegueWithIdentifier(Storyboard.Search, sender: detail)
        case .Urls:
            if let urlMention = detail as? Twitter.Mention {
                UIApplication.sharedApplication().openURL(NSURL(string: urlMention.keyword)!)
            }
        case .Images :
            performSegueWithIdentifier(Storyboard.ShowImage, sender: detail)
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let a = tweetMentions[section].Name
        return a.rawValue
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Search {
            if let tcv = segue.destinationViewController.contentViewController as? TweetTableViewController {
                if let searchText = sender! as? Mention {
                    var originalName = searchText.keyword
                    if originalName.containsString("@"){
                        originalName.removeAtIndex(originalName.startIndex)
                        tcv.searchText = "@" + originalName + " OR from:" + originalName
                    } else {
                        tcv.searchText = originalName
                    }
                }
                if let searchText = sender! as? Twitter.User {
                    let originalName = searchText.name
                    tcv.searchText = "@" + originalName + " OR from:" + originalName
                }
            }
        }
        
        if segue.identifier == Storyboard.ShowImage {
            if let mediaItem = sender as? Twitter.MediaItem {
                if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                    ivc.imageUrl = mediaItem.url
                }
            }
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

    */

}
