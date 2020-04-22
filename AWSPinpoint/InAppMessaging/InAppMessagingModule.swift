//
//  InAppMessagingModule.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/14/20.
//

import UIKit

enum InAppMessagingStyle {
    case splash
    case dialog
    case banner
}

@objc public protocol InAppMessagingDelegate {
    @objc func primaryButtonClicked(message: AWSPinpointIAMModel)
    @objc func secondaryButtonClicked(message: AWSPinpointIAMModel)
    //@objc func messageClicked(message: AWSPinpointSplashModel)
    @objc func messageDismissed(message: AWSPinpointIAMModel)
    @objc optional func displayInvoked(message: AWSPinpointIAMModel)
}

@objc public class InAppMessagingModule: NSObject {
    var enabled: Bool = true
    public var delegate: InAppMessagingDelegate
    var queue: [AWSPinpointIAMModel] = []
    var activeIAMShown = false
    var savedAppStartData: [String: Any]? = nil
    let toastManager = ToastManager.shared
    
    var rootViewController: UIViewController? {
        get {
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    @objc public init(delegate: InAppMessagingDelegate) {
        self.delegate = delegate
        super.init()
        toastManager.isQueueEnabled = true
    }
    
//    public func retrieveEligibleInAppMessages() {
////        if let url = URL(string: "https://google.com/getIAM?endpointID=ABC") {
////            URLSession.shared.dataTask(with: url) { data, response, error in
////                if let data = data {
////                    do {
////                        let modelDict = try JSONSerialization.jsonObject(with: data)
////                        self.displayIAM(data: modelDict as! [String : Any])
////                    } catch {
////                        print("invalid data from retrieveEligibleInAppMessages")
////                    }
////                }
////            }.resume()
////        }
//        
//        if let path = Bundle(for: InAppMessagingModule.self).path(forResource: "mock_getIAM_data", ofType: "json")
//        {
//            do {
//                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
//                let modelDict = try JSONSerialization.jsonObject(with: data)
//                self.displayIAM(data: modelDict as! [String : Any])
//            } catch {
//                print("invalid data from retrieveEligibleInAppMessages")
//            }
//        }
//    }

    public func localSplashIAM() {
        if let path = Bundle(for: InAppMessagingModule.self).path(forResource: "mock_getIAM_data_splash", ofType: "json")
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let modelDict = try JSONSerialization.jsonObject(with: data)
                self.displayIAM(data: modelDict as! [String : Any])
            } catch {
                print("invalid data from retrieveEligibleInAppMessages")
            }
        }
    }

    public func localDialogIAM() {
        if let path = Bundle(for: InAppMessagingModule.self).path(forResource: "mock_getIAM_data_dialog", ofType: "json")
        {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let modelDict = try JSONSerialization.jsonObject(with: data)
                self.displayIAM(data: modelDict as! [String : Any])
            } catch {
                print("invalid data from retrieveEligibleInAppMessages")
            }
        }
    }
    
    @objc public func saveAppStartIAM(data: [String: Any]) {
        self.savedAppStartData = data
    }
    
    @objc public func clearAppStartIAM() {
        self.savedAppStartData = nil
    }

    @objc public func displayIAM(data: [String: Any]) {
        DispatchQueue.main.async {
            guard let _ = self.rootViewController else {
                print("IAM rootViewController not configured")
                return
            }
            guard #available(iOS 9.0, *) else {
                print("iOS version below 9.0")
                return
            }
            let topVC = self.topViewController()
            var previousMessage: AWSPinpointIAMModel?
            if let topSplashVC = topVC as? AWSPinpointSplashViewController {
                previousMessage = topSplashVC.model
            }
            if let topDialogVC = topVC as? AWSPinpointDialogViewController {
                previousMessage = topDialogVC.model
            }
            if let splashData = data["splash"] as? [String: Any] {
                let model = AWSPinpointIAMModel(data: splashData)!
                if let previousMessage = previousMessage {
                    if previousMessage.priority <= model.priority {
                        topVC?.dismiss(animated: true, completion: {
                            self.displayMessage(model, style: .splash)
                        })
                    }
                    // new message priority is low, no op
                    return
                }
                self.displayMessage(model, style: .splash)
            } else if let dialogData = data["dialog"] as? [String: Any] {
                let model = AWSPinpointIAMModel(data: dialogData)!
                if let previousMessage = previousMessage {
                    if previousMessage.priority <= model.priority {
                        topVC?.dismiss(animated: true, completion: {
                            self.displayMessage(model, style: .dialog)
                        })
                    }
                    // new message priority is low, no op
                    return
                }
                self.displayMessage(model, style: .dialog)
            } else if let bannerData = data["banner"] as? [String: Any] {
                let model = AWSPinpointIAMModel(data: bannerData)!
                self.displayMessage(model, style: .banner)
            }
        }
    }
    
    public func displayAppStartIAMIfAvailable() {
        DispatchQueue.main.async {
            guard let savedAppStartData = self.savedAppStartData else {
                return
            }
            self.displayIAM(data: savedAppStartData)
            self.savedAppStartData = nil
        }
    }
    
    public func displayToast(_ message: String, duration: Double, position: ToastPosition, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.topViewController()?.view.makeToast(message,
                                                     duration: duration,
                                                     position: position,
                                                     completion: completion)
        }
    }
    
    @available(iOS 9.0, *)
    private func displayMessage(_ message: AWSPinpointIAMModel, style: InAppMessagingStyle) {
        self.delegate.displayInvoked?(message: message)
        switch style {
            case .splash:
                let iamVC = AWSPinpointSplashViewController(model: message,
                                                            delegate: self.delegate)
                iamVC.fetchImage(completion: { success in
                    if success {
                        self.topViewController()?.present(iamVC, animated: true, completion: {
                            print("\(message.name) IAM shown")
                        })
                    } else {
                        print("image fetching failed")
                    }
                })
                break
            case .dialog:
                let iamVC = AWSPinpointDialogViewController(model: message,
                                                            delegate: self.delegate)
                iamVC.fetchImage(completion: { success in
                    if success {
                        self.topViewController()?.present(iamVC, animated: true, completion: {
                            print("\(message.name) IAM shown")
                        })
                    } else {
                        print("image fetching failed")
                    }
                })
                break
            case .banner:
                self.topViewController()?.view.makeToast(message.message, duration: 5.0, position: .top, title: message.title, completion: { didTap in
                    if didTap {
                        self.delegate.primaryButtonClicked(message: message)
                    }
                })
                break
        }
    }
    
    private func topViewController() -> UIViewController? {
        var top = self.rootViewController
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else if let split = top as? UISplitViewController {
                top = split.viewControllers[0]
            } else {
                break
            }
        }
        return top
    }
}
