//
//  AWSPinpointDialogViewController.swift
//  AWSPinpoint
//
//  Created by Guan, Zhinan on 4/15/20.
//

import UIKit

@available(iOS 9.0, *)
public class AWSPinpointDialogViewController: UIViewController {
    private let model: AWSPinpointIAMModel
    private let delegate: InAppMessagingDelegate
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton()
    private let secondaryButton = UIButton()
    private var backgroundImage = UIImageView()
    private let contentStackView = UIStackView()
    private let buttonStackView = UIStackView()
    private let contentBackgroundView = UIView()
    private var userDismissed = true
    
    @objc public init(model: AWSPinpointIAMModel, delegate: InAppMessagingDelegate) {
        self.model = model
        self.delegate = delegate

        super.init(nibName: nil, bundle: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        titleLabel.text = model.title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        messageLabel.text = model.message
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.numberOfLines = 0
        
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFit
        backgroundImage.backgroundColor = UIColor.from(hex: model.backgroundHexColor)
        if let imageURL = model.backgroundImageURL {
            backgroundImage.downloaded(from: imageURL)
        }
        
        primaryButton.setTitle(model.primaryButtonText, for: .normal)
        primaryButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
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
        secondaryButton.titleLabel?.font = .systemFont(ofSize: 15)
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
        contentStackView.spacing = 2
        contentStackView.isLayoutMarginsRelativeArrangement = true
        contentStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .center
        buttonStackView.spacing = 2
        
        contentBackgroundView.backgroundColor = .white
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(tap)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setConstraints() {
        view.addSubview(contentBackgroundView)
        view.addSubview(contentStackView)
        
        buttonStackView.addArrangedSubview(secondaryButton)
        buttonStackView.addArrangedSubview(primaryButton)
        
        contentStackView.addArrangedSubview(backgroundImage)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(buttonStackView)
        let constraints = [
            contentStackView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.8),
            contentStackView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            contentStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            contentBackgroundView.topAnchor.constraint(equalTo: contentStackView.topAnchor),
            contentBackgroundView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor),
            contentBackgroundView.leftAnchor.constraint(equalTo: contentStackView.leftAnchor),
            contentBackgroundView.rightAnchor.constraint(equalTo: contentStackView.rightAnchor),
            
            backgroundImage.heightAnchor.constraint(equalToConstant: 300),
            backgroundImage.widthAnchor.constraint(equalToConstant: 300),
            backgroundImage.leftAnchor.constraint(equalTo: contentStackView.leftAnchor),
            backgroundImage.rightAnchor.constraint(equalTo: contentStackView.rightAnchor),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 60),
            titleLabel.leftAnchor.constraint(equalTo: contentStackView.leftAnchor, constant:10),
            titleLabel.rightAnchor.constraint(equalTo: contentStackView.rightAnchor, constant:-10),
            
            messageLabel.heightAnchor.constraint(equalToConstant: 80),
            messageLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            messageLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            
            buttonStackView.bottomAnchor.constraint(equalTo: contentStackView.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40),
            buttonStackView.leftAnchor.constraint(equalTo: contentStackView.leftAnchor, constant: 10),
            buttonStackView.rightAnchor.constraint(equalTo: contentStackView.rightAnchor, constant: -10),
            
            primaryButton.widthAnchor.constraint(equalToConstant: 120),
            primaryButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            primaryButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            
            secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor),
            secondaryButton.topAnchor.constraint(equalTo: buttonStackView.topAnchor),
            secondaryButton.bottomAnchor.constraint(equalTo: buttonStackView.bottomAnchor)
        ]
        buttonStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc func primaryButtonPressed() {
        userDismissed = false
        delegate.primaryButtonClicked(message: model)
        dismiss(animated: true, completion: nil)
    }

    @objc func secondaryButtonPressed() {
        userDismissed = false
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
    
    @objc func handleBackgroundTap(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: nil)
    }
}
