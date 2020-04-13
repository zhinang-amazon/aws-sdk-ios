//
//  AWSPinpointSplashView.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/9/20.
//

import Foundation

@objc public class AWSPinpointSplashModel: NSObject, Codable {
    let title: String
    let message: String
    let backgroundHexColor: String
    let backgroundImageURL: URL? // solid background color if nil
    
    let primaryButtonText: String
    let primaryButtonTextColor: String? // system default
    let primaryButtonHexColor: String? // system default
    let primaryButtonURL: URL
    
    let secondaryButtonText: String? // not shown if nil
    let secondaryButtonTextColor: String? // system default
    let secondaryButtonHexColor: String? // default transparent
    let secondaryButtonURL: URL? // default dismiss
    
    init?(data: [String: Any]) {
        self.title = data["title"] as! String
        self.message = data["message"] as! String
        self.backgroundHexColor = data["backgroundHexColor"] as! String
        self.backgroundImageURL = URL(string: data["backgroundImageURL"] as! String)
        
        self.primaryButtonText = data["primaryButtonText"] as! String
        self.primaryButtonTextColor = data["primaryButtonTextColor"] as! String
        self.primaryButtonHexColor = data["primaryButtonHexColor"] as! String
        self.primaryButtonURL = URL(string: data["primaryButtonURL"] as! String)!

        self.secondaryButtonText = data["secondaryButtonText"] as! String
        self.secondaryButtonTextColor = data["secondaryButtonTextColor"] as! String
        self.secondaryButtonHexColor = data["secondaryButtonHexColor"] as! String
        self.secondaryButtonURL = URL(string: data["secondaryButtonURL"] as! String)
    }
}

@available(iOS 11.0, *)
public class AWSPinpointSplashViewController: UIViewController {
    private let model: AWSPinpointSplashModel
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton()
    private let secondaryButton = UIButton()
    private var backgroundImage = UIImageView()
    private let contentStackView = UIStackView()
    
    @objc public init?(data: Dictionary<String, Any>) {
        if let m = AWSPinpointSplashModel(data: data) {
            self.model = m
        } else {
            return nil
        }
        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.from(hex: model.backgroundHexColor)
        titleLabel.text = model.title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        messageLabel.text = model.message
        messageLabel.font = .systemFont(ofSize: 14)
        
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFit
        if let imageURL = model.backgroundImageURL {
            backgroundImage.downloaded(from: imageURL)
        }
        
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
    
    private func setConstraints() {
        view.addSubview(backgroundImage)
        view.addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(primaryButton)
        contentStackView.addArrangedSubview(secondaryButton)
        let windowFrame = UIApplication.shared.keyWindow!.frame
        let constraints = [
            //view.widthAnchor.constraint(equalToConstant: 400),
            //view.heightAnchor.constraint(equalToConstant: 600),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            //contentStackView.topAnchor.constraint(equalTo: view.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-20),
            contentStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant:20),
            contentStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant:-20),
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.leftAnchor.constraint(equalTo: contentStackView.leftAnchor, constant:10),
            titleLabel.rightAnchor.constraint(equalTo: contentStackView.rightAnchor, constant:-10),
            messageLabel.heightAnchor.constraint(equalToConstant: 40),
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
    
//    public override func willMove(toSuperview newSuperview: UIView?) {
//        let constraints = [
//            topAnchor.constraint(equalTo: newSuperview!.topAnchor),
//            bottomAnchor.constraint(equalTo: newSuperview!.bottomAnchor),
//            leftAnchor.constraint(equalTo: newSuperview!.leftAnchor),
//            rightAnchor.constraint(equalTo: newSuperview!.rightAnchor)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
    
//    public override func viewWillLayoutSubviews() {
//        view.updateConstraints()
//        super.viewWillLayoutSubviews()
//    }
    
    @objc func primaryButtonPressed() {
        UIApplication.shared.openURL(model.primaryButtonURL)
    }

    @objc func secondaryButtonPressed() {
        if let secondaryButtonURL = model.secondaryButtonURL {
            UIApplication.shared.openURL(secondaryButtonURL)
        } else {
            
        }
    }
}
