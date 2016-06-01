//
//  ImageTableViewCell.swift
//  SmashTag
//
//  Created by Yifan on 5/31/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var imageContent: UIImageView!
    
    private func updateUI() {
        if let url = imageURL {
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                [weak weakSelf = self] in
                if let imageData = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if weakSelf?.imageURL == url {
                            weakSelf?.imageOfCell = UIImage(data:imageData)
                        }
                    }
                }
            }
        }
    }
    
    private var imageOfCell: UIImage? {
        get {
            return imageContent.image
        }
        set {
            imageContent.image = newValue
            imageContent.sizeToFit()
        }
    }
    

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
