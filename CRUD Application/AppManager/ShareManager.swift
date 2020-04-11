//
//  ShareManager.swift
//  BoilerCode
//
//  Created by Asif Newaz on 11/4/20.
//  Copyright © 2020 Nasim Newaz. All rights reserved.
//

import Foundation
import UIKit

class ShareManager {
    
    
    class func shareTheApp(_ fromVC: UIViewController, sender: UIView?, image: UIImage? = nil, text: String? = nil, url: NSURL? = nil) {
        
        var activityItems: [Any] = []
        
        if let text = text {
            activityItems.append(text)
        } else {
            activityItems.append("")
        }
        
        if let url = url {
            activityItems.append(url)
        } else {
            activityItems.append(NSURL(string: URLManager.shareAppURL)) // need to fix
        }
        if let image = image {
            activityItems.append(image)
        }
        
        //        if let url = url {
        //            activityItems.append(url)
        //        } else {
        //            activityItems.append(NSURL(string: "https://www.jayeshkawli.ghost.io")!)
        //        }
        
        
        // let avc = UIActivityViewController(activityItems:things, applicationActivities:nil)
        let avc = UIActivityViewController(activityItems:activityItems, applicationActivities:[])
        // new in iOS 8, completionHander replaced by completionWithItemsHandlers
        // the reason is that an extension, using this same API, can return values
        // type is (UIActivityType?, Bool, [Any]?, Error?) -> Swift.Void
        avc.completionWithItemsHandler = {
            type, ok, items, err in
            // print("completed \(type) \(ok) \(items) \(err)")
        }
        avc.excludedActivityTypes = [
            .postToWeibo,
            .assignToContact,
            .addToReadingList,
            .postToVimeo,
            .postToTencentWeibo,
            .openInIBooks
        ]
        // avc.excludedActivityTypes = nil
        fromVC.present(avc, animated:true)
        // on iPad this will be an action sheet and will need a source view or bar button item
        if let pop = avc.popoverPresentationController {
            if let sender = sender {
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
            }
        }
    }
    
    class func share(_ fromVC: UIViewController, sender: UIView?, image: UIImage? = nil, text: String? = nil, url: NSURL? = nil) {
        
        var activityItems: [Any] = []
        
        if let text = text {
            activityItems.append(text)
        } else {
            //activityItems.append(Message.shareText) // Need to fix
        }
        if let image = image {
            activityItems.append(image)
        }
        
    
        let avc = UIActivityViewController(activityItems:activityItems, applicationActivities:[])
        // new in iOS 8, completionHander replaced by completionWithItemsHandlers
        // the reason is that an extension, using this same API, can return values
        // type is (UIActivityType?, Bool, [Any]?, Error?) -> Swift.Void
        avc.completionWithItemsHandler = {
            type, ok, items, err in
            // print("completed \(type) \(ok) \(items) \(err)")
        }
        avc.excludedActivityTypes = [
            .postToWeibo,
            .assignToContact,
            .addToReadingList,
            .postToVimeo,
            .postToTencentWeibo,
            .openInIBooks
        ]
        
        // on iPad this will be an action sheet and will need a source view or bar button item
        if let pop = avc.popoverPresentationController {
            if let sender = sender {
                pop.sourceView = sender
                pop.sourceRect = sender.bounds
            }
        }
        
        // avc.excludedActivityTypes = nil
        fromVC.present(avc, animated:true)
    }
}
