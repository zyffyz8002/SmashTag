//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Yifan on 5/30/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell
{
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetProfileImageView: UIImageView!
 
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func changeColor(text:NSMutableAttributedString, mentions: [Twitter.Mention], color: UIColor) -> NSMutableAttributedString {
     
        for i in 0..<mentions.count {
            text.addAttribute(NSForegroundColorAttributeName, value: color, range: mentions[i].nsrange)
        }
        return text
    }
    
    private func getColoredText(tweet : Twitter.Tweet) -> NSMutableAttributedString
    {
        var MutableTweetText = tweet.text
        let colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor()]
        if (!MutableTweetText.isEmpty) {
            for _ in tweet.media {
                MutableTweetText += " 📷"
            }
            
            var myMutableLabelString = NSMutableAttributedString(string: MutableTweetText)
            myMutableLabelString = changeColor(myMutableLabelString, mentions: tweet.hashtags, color: colors[0])
            myMutableLabelString = changeColor(myMutableLabelString, mentions: tweet.urls, color: colors[1])
            myMutableLabelString = changeColor(myMutableLabelString, mentions: tweet.userMentions, color: colors[2])
            
            return myMutableLabelString
        }

        return NSMutableAttributedString()
    }
    
    private func updateUI()
    {
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            tweetTextLabel?.attributedText = getColoredText(tweet)

            
            if let profileImageURL = tweet.user.profileImageURL {
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                    [weak weakSelf = self] in
                    if let imageData = NSData(contentsOfURL: profileImageURL) {
                        dispatch_async(dispatch_get_main_queue()) {
                            if profileImageURL == tweet.user.profileImageURL {
                                weakSelf?.tweetProfileImageView?.image = UIImage(data: imageData)
                            }
                        }
                    }
                }
            }
            
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
        
    }
}