//
//  ImageViewController.swift
//  SmashTag
//
//  Created by Yifan on 5/31/16.
//  Copyright © 2016 Yifan. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageUrl : NSURL? {
        didSet {
            image = nil
  //          if view.window != nil {
                fetchImage()
    //        }
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    {
        didSet {
            scrollView?.contentSize = imageView.frame.size
            scrollView.delegate = self
            adjustImageRatio()
            print("scrollviewseted")
        }
    }
    
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private func fetchImage() {
        if let url = imageUrl  {
            spinner?.startAnimating()
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
                [weak weakSelf = self] in
                if let contents = NSData(contentsOfURL: url) {
                    dispatch_async(dispatch_get_main_queue()) {
                        if weakSelf?.imageUrl == url {
                            weakSelf?.image = UIImage(data: contents)
                        } else {
                            print("image ignored")
                            weakSelf?.spinner?.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    private var image : UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            spinner?.stopAnimating()
            scrollView?.contentSize = imageView.frame.size
            adjustImageRatio()
            print("image setted")
        }
    }
    
    var imageView = UIImageView()
    var imageScale : CGFloat = 1.0

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    private func adjustImageRatio() {
        
        if let realImage = image {
            let imageRatio = realImage.size.height / realImage.size.width
            let imageViewRatio = scrollView.frame.size.height / scrollView.frame.size.width
            
            if imageRatio > imageViewRatio {
                imageScale = scrollView.frame.size.width / realImage.size.width 
            } else {
                imageScale = scrollView.frame.size.height / realImage.size.height
            }
        }
        
        scrollView?.minimumZoomScale = 0.5 * imageScale
        scrollView?.maximumZoomScale = 1.5 * imageScale
        scrollView?.setZoomScale(imageScale, animated: false)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print("view did apear")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
        imageView.sizeToFit()
        print("view loaded!")

    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        adjustImageRatio()
    }
}
