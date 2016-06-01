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
                addDisplayItems("Medias", Items: tweet!.media)
                addDisplayItems("Urls", Items: tweet!.urls)
                addDisplayItems("UserMentions", Items: tweet!.userMentions)
                addDisplayItems("Hashtags", Items: tweet!.hashtags)
                
                tableView.reloadData()
            }
        }
    }
    
    
    
    private func addDisplayItems(Name: String, Items: [AnyObject]) {
        if Items.count > 0 {
            tweetMentions.append(
                DetailedSection(Name: Name, Items: Items)
            )
        }
        
    }
    
    private var tweetMentions = [DetailedSection]()
    
    private enum TypeNames : String {
        case Image
        case Url
        case Users
        case Hashtags
    }

    private struct DetailedSection {
        var Name: String
        var Items: [AnyObject]
    }
    
    private enum TweetMentions {
        case Medias([Twitter.MediaItem])
        case Urls([Twitter.Mention])
        case Hashtags([Twitter.Mention])
        case UserMentions([Twitter.Mention])
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

    private func getColoredDetails(name: String, mention: Twitter.Mention) -> NSMutableAttributedString
    {
        var myMutableLabelString = NSMutableAttributedString()
        
        var color = UIColor.redColor()
        if !mention.keyword.isEmpty
        {
            myMutableLabelString = NSMutableAttributedString(string: mention.keyword)
            switch name {
            case "Urls" : color = UIColor.blueColor()
            case "UserMentions" : color = UIColor.greenColor()
            case "Hashtags" : color = UIColor.redColor()
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
        case "Urls", "UserMentions", "Hashtags":
            cellIdentifier = Storyboard.Mentions
        case "Medias":
            cellIdentifier = Storyboard.Images
        default:
            break
        }
        if (!cellIdentifier.isEmpty) {
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            
            if let mention = detail as? Twitter.Mention {
                cell.textLabel?.attributedText = getColoredDetails(name, mention: mention)
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
        case "Hashtags", "UserMentions":
            performSegueWithIdentifier(Storyboard.Search, sender: detail)
        case "Urls":
            if let urlMention = detail as? Twitter.Mention {
                UIApplication.sharedApplication().openURL(NSURL(string: urlMention.keyword)!)
            }
        case "Medias" :
            performSegueWithIdentifier(Storyboard.ShowImage, sender: detail)
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tweetMentions[section].Name
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Storyboard.Search {
            if let searchText = sender! as? Mention {
                if let tcv = segue.destinationViewController.contentViewController as? TweetTableViewController {
                    tcv.searchText = searchText.keyword
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
