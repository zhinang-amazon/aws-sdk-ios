//
//  InAppMessagingModule.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/14/20.
//

import UIKit

@objc public protocol InAppMessagingDelegate {
    @objc func primaryButtonClicked(message: AWSPinpointSplashModel)
    @objc func secondaryButtonClicked(message: AWSPinpointSplashModel)
    //@objc func messageClicked(message: AWSPinpointSplashModel)
    @objc func messageDismissed(message: AWSPinpointSplashModel)
}

@objc public class InAppMessagingModule: NSObject {
    var enabled: Bool = true
    let delegate: InAppMessagingDelegate
    var rootViewController: UIViewController?
    
    @objc public init(delegate: InAppMessagingDelegate) {
        rootViewController = UIApplication.shared.keyWindow?.rootViewController
        self.delegate = delegate
        super.init()
    }
    
    @objc public func displayIAM(data: [String: Any]) {
        if rootViewController == nil {
            rootViewController = UIApplication.shared.keyWindow?.rootViewController
        }
        guard let rootVC = rootViewController else {
            print("IAM rootViewController not configured")
            return
        }
        guard let splashModel = AWSPinpointSplashModel(data: data["splash"] as! [String : Any]) else {
            print("invalid IAM data")
            return
        }
        guard #available(iOS 9.0, *) else {
            print("iOS version below 9.0")
            return
        }
        let splashVC = AWSPinpointSplashViewController(model: splashModel,
                                                       delegate: delegate)
        rootVC.present(splashVC, animated: true, completion: {
            print("splash IAM shown")
        })
    }
}
