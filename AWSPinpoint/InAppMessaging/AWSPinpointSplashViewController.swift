//
//  AWSPinpointSplashViewController.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/9/20.
//

import Foundation

@objc public class AWSPinpointIAMModel: NSObject, Codable {
    @objc public let id: String
    @objc public let name: String
    @objc public let campaignId: String
    @objc public let title: String
    @objc public let message: String
    @objc public let backgroundHexColor: String
    @objc public let backgroundImageURL: URL? // solid background color if nil
    
    @objc public let primaryButtonText: String
    @objc public let primaryButtonTextColor: String? // system default
    @objc public let primaryButtonHexColor: String? // system default
    //@objc public let primaryButtonURL: URL
    
    @objc public let secondaryButtonText: String? // not shown if nil
    @objc public let secondaryButtonTextColor: String? // system default
    @objc public let secondaryButtonHexColor: String? // default transparent
    //@objc public let secondaryButtonURL: URL? // default dismiss
    @objc public let priority: Int
    
    @objc public let customParam: [String: String]
    
    init?(data: [String: Any]) {
        self.id = data["id"] as! String
        self.name = data["name"] as! String
        self.campaignId = data["campaignId"] as! String
        let uiConfiguration = data["uiConfiguration"] as! [String: Any]
        self.title = uiConfiguration["title"] as! String
        self.message = uiConfiguration["message"] as! String
        self.backgroundHexColor = uiConfiguration["backgroundHexColor"] as! String
        self.backgroundImageURL = URL(string: uiConfiguration["backgroundImageURL"] as! String)
        
        self.primaryButtonText = uiConfiguration["primaryButtonText"] as! String
        self.primaryButtonTextColor = uiConfiguration["primaryButtonTextColor"] as! String
        self.primaryButtonHexColor = uiConfiguration["primaryButtonHexColor"] as! String

        self.secondaryButtonText = uiConfiguration["secondaryButtonText"] as! String
        self.secondaryButtonTextColor = uiConfiguration["secondaryButtonTextColor"] as! String
        self.secondaryButtonHexColor = uiConfiguration["secondaryButtonHexColor"] as! String

        self.priority = data["priority"] as? Int ?? 50
        self.customParam = data["customParam"] as! [String: String]
    }
}

@available(iOS 9.0, *)
public class AWSPinpointSplashViewController: UIViewController {
    public let model: AWSPinpointIAMModel
    private let delegate: InAppMessagingDelegate
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton()
    private let secondaryButton = UIButton()
    private var backgroundImage = UIImageView()
    private let contentStackView = UIStackView()
    private var userDismissed = true
    
    @objc public init(model: AWSPinpointIAMModel, delegate: InAppMessagingDelegate) {
        self.model = model
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.from(hex: model.backgroundHexColor)
        contentStackView.backgroundColor = .clear
        titleLabel.text = model.title
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        messageLabel.text = model.message
        messageLabel.font = .systemFont(ofSize: 18)
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        
        backgroundImage.contentMode = UIView.ContentMode.scaleToFill
        
        primaryButton.setTitle(model.primaryButtonText, for: .normal)
        primaryButton.layer.cornerRadius = 3
        primaryButton.clipsToBounds = true
        if let primaryButtonTextColor = model.primaryButtonTextColor {
            primaryButton.setTitleColor(UIColor.from(hex: primaryButtonTextColor), for: .normal)
        }
        if let primaryButtonHexColor = model.primaryButtonHexColor {
            primaryButton.backgroundColor = UIColor.from(hex: primaryButtonHexColor)
        }
        primaryButton.addTarget(self, action: #selector(primaryButtonPressed), for: .touchUpInside)
        
        secondaryButton.setTitle(model.secondaryButtonText, for: .normal)
        secondaryButton.layer.cornerRadius = 3
        secondaryButton.clipsToBounds = true
        if let secondaryButtonTextColor = model.secondaryButtonTextColor {
            secondaryButton.setTitleColor(UIColor.from(hex: secondaryButtonTextColor), for: .normal)
        }
        if let secondaryButtonHexColor = model.secondaryButtonHexColor {
            secondaryButton.backgroundColor = UIColor.from(hex: secondaryButtonHexColor)
        }
        secondaryButton.addTarget(self, action: #selector(secondaryButtonPressed), for: .touchUpInside)
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 8
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchImage(completion: @escaping (Bool) -> ()) {
        if let imageURL = model.backgroundImageURL {
            backgroundImage.download(from: imageURL) { success in
                completion(success)
            }
        }
    }
    
    private func setConstraints() {
        view.addSubview(backgroundImage)
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(primaryButton)
        contentStackView.addArrangedSubview(secondaryButton)
        let windowFrame = UIApplication.shared.keyWindow!.frame
        let constraints = [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-20),
            contentStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:20),
            contentStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-20),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.leftAnchor.constraint(equalTo: contentStackView.leftAnchor, constant:10),
            titleLabel.rightAnchor.constraint(equalTo: contentStackView.rightAnchor, constant:-10),
            messageLabel.heightAnchor.constraint(equalToConstant: 80),
            messageLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            messageLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            primaryButton.heightAnchor.constraint(equalToConstant: 40),
            primaryButton.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            primaryButton.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            secondaryButton.heightAnchor.constraint(equalToConstant: 40),
            secondaryButton.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            secondaryButton.rightAnchor.constraint(equalTo: titleLabel.rightAnchor)
        ]
        contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func primaryButtonPressed() {
        userDismissed = false
        //UIApplication.shared.openURL(model.primaryButtonURL)
        delegate.primaryButtonClicked(message: model)
        dismiss(animated: true, completion: nil)
    }

    @objc func secondaryButtonPressed() {
        userDismissed = false
//        if let secondaryButtonURL = model.secondaryButtonURL {
//            UIApplication.shared.openURL(secondaryButtonURL)
//        }
        delegate.secondaryButtonClicked(message: model)
        dismiss(animated: true, completion: nil)
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        print("userDismissed: \(userDismissed)")
        if userDismissed {
            delegate.messageDismissed(message: model)
        }
        super.viewDidDisappear(animated)
    }
}
