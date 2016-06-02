//
//  TwitterUser.swift
//  SmashTag
//
//  Created by Yifan on 6/2/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import Foundation
import CoreData
import Twitter


class TwitterUser: NSManagedObject
{
    
    class func twitterUserWithTwitterInfo(twitterInfo: Twitter.User, inManagedObjectContext context : NSManagedObjectContext) -> TwitterUser?
    {
        let request = NSFetchRequest(entityName: "TwitterUser")
        request.predicate = NSPredicate(format: "screenName = %@", twitterInfo.screenName)
        if let twitterUser = (try? context.executeFetchRequest(request))?.first as? TwitterUser {
            return twitterUser
        } else if let twitterUser = NSEntityDescription.insertNewObjectForEntityForName("TwitterUser", inManagedObjectContext: context) as? TwitterUser {
            twitterUser.screenName = twitterInfo.screenName
            twitterUser.name = twitterInfo.name
            return twitterUser
        }
        return nil
    }

// Insert code here to add functionality to your managed object subclass

}
