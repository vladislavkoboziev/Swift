//
//  FeedbackViewController.swift
//  Armor
//
//  Created by John on 11/6/19.
//  Copyright © 2019 evolutn.io. All rights reserved.
//

import UIKit
import MessageUI
import Cosmos
import MaterialShowcase

class FeedbackViewController: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {
    
    let mainGrayColor = ColorBook.apgBlack
    let mainLightGrayColor = ColorBook.apgGray
    let mainWhiteColor = ColorBook.apgLightGray
    
    let primaryColor =  ColorBook.apgLightGray
    let backgroundColor = ColorBook.apgBlack
    
    var messageToDevTeamTextView:UITextView = UITextView()
    var messageSubjectToAppDeveloper: String = ("Rating is : 3.5 stars")

    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    let textViewHeight:CGFloat = 150
    
    var screenSizeType = ScreenSize()
    var imageWidth : CGFloat!
    var imageHeight : CGFloat!
    
    let firstLaunchedKey = "FeedbackFirstLaunche"
    let defaults = UserDefaults.standard
    
    lazy var appSettingsButton : UIButton = {
        let button = AppSettingsButton()
        button.addTarget(self, action: #selector(FeedbackViewController.serviceButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton : UIButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(FeedbackViewController.backButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()

    lazy var textViewBackground : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgLightGrayTwo
        view.layer.cornerRadius = 15.0
        return view
    }()
    
    lazy var informationButton : UIButton = {
        let button = InformationButton()
        button.addTarget(self, action: #selector(PrivacyViewController.infoButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var sendButtonDevTeam: UIButton = {
        let button = SendButton()
        button.addTarget(self, action: #selector(FeedbackViewController.sendEmailToDeveloper(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var starRatingCosmosView : CosmosView = {
        var starRatingView = CosmosView()
        starRatingView.translatesAutoresizingMaskIntoConstraints = false
        starRatingView.accessibilityIdentifier = "starRatingView"
        starRatingView.settings.starSize = 40
        starRatingView.settings.fillMode = .half
        starRatingView.settings.emptyColor = ColorBook.apgGray
        starRatingView.settings.filledColor = ColorBook.apgGreen
        starRatingView.settings.emptyBorderColor = ColorBook.apgGray
        starRatingView.settings.filledBorderColor = ColorBook.apgGreen
        return starRatingView
    }()
    
    lazy var topLabel : UILabel = {
        let label = TopLabel()
        label.labelText(text: NSLocalizedString("Feedback top label text", comment: ""))
        label.labelTextColor(textColor: primaryColor)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        
        screenSizeType.checkParameters()
        setupHeightParameters()
        
        self.view.addSubview(topLabel)
        self.view.addSubview(informationButton)
        self.view.addSubview(appSettingsButton)
        self.view.addSubview(backButton)
        self.view.addSubview(textViewBackground)
        backButton.isHidden = true
        
        setupMessageToDevTeamTextView()
        
        view.addSubview(sendButtonDevTeam)
        view.addSubview(starRatingCosmosView)
        starRatingCosmosView.didTouchCosmos = { rating in
            self.messageSubjectToAppDeveloper = ("Rating is : " + "\(rating)" + " stars")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let hasLaunched = defaults.bool(forKey: firstLaunchedKey)
        
        if !hasLaunched {
            feedbackTutorials()
            defaults.set(true, forKey: firstLaunchedKey)
        }
    }
    
    @objc func backButtonIsClicked(sender: UIButton) {
        backButton.isHidden = true
        appSettingsButton.isHidden = false
        messageToDevTeamTextView.endEditing(true)
    }
    
    @objc func infoButtonIsClicked(sender: UIButton) {
        let infoVC = InfoButtonAnimationViewController()
        infoVC.topInfoHeaderLabelText(text: NSLocalizedString("Feedback info header", comment: ""))
        infoVC.topInfoBodyLabelText(text: NSLocalizedString("Feedback info body", comment: ""))
        present(infoVC, animated: true)
        
        infoVC.okAction = infoOkButtonIsClicked
        infoVC.startTutorialAction = infoStartTutorialButtonIsClicked
    }
    
    func infoOkButtonIsClicked() {
        self.dismiss(animated: false, completion: nil)
    }
    
    func infoStartTutorialButtonIsClicked() {
        self.dismiss(animated: false, completion: nil)
        defaults.set(false, forKey: firstLaunchedKey)
        viewDidAppear(true)
    }
    
    func feedbackTutorials() {
        let sequence = MaterialShowcaseSequence()
        
        let showcaseFeedback = MaterialShowcase()
        showcaseFeedback.setTargetView(button: sendButtonDevTeam)
        showcaseFeedback.primaryText = NSLocalizedString("Primary text feedback", comment: "")
        showcaseFeedback.secondaryText = NSLocalizedString("Description tutorials send", comment: "")
        showcaseFeedback.backgroundViewType = .circle
        showcaseFeedback.primaryTextColor = ColorBook.apgGreen
        showcaseFeedback.secondaryTextColor = ColorBook.mainWhite
        showcaseFeedback.targetTintColor = ColorBook.mainWhite
        showcaseFeedback.targetHolderColor = ColorBook.mainWhite
        showcaseFeedback.backgroundPromptColor = ColorBook.apgGray
        showcaseFeedback.targetHolderRadius = 40
        showcaseFeedback.backgroundRadius = 1900
        showcaseFeedback.primaryTextSize = 18
        showcaseFeedback.secondaryTextSize = 16
        showcaseFeedback.primaryTextFont = UIFont.systemFont(ofSize: 18)
        showcaseFeedback.isTapRecognizerForTargetView = false
        
        showcaseFeedback.delegate = self as? MaterialShowcaseDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        sequence.temp(showcaseFeedback).start()
        })
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func serviceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    @objc func sendEmailToDeveloper(sender : UIButton ) {
        appSettingsButton.isHidden = false
        backButton.isHidden = true
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["john.mourzik@evolutn.io"])
            mail.setSubject(messageSubjectToAppDeveloper)
            mail.setMessageBody(messageToDevTeamTextView.text, isHTML: true)
            present(mail, animated: true)
        } else {
            print(Error.self)
        }
    }
    
    func setupHeightParameters() {
        if ScreenSize.smallScreen {
            imageWidth = 117.0
            imageHeight = 150.0
        } else {
            imageWidth = 216.0
            imageHeight = 275.0
        }
    }
    
    private func setupConstraints() {
        topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        
        appSettingsButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        appSettingsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  20.0).isActive = true
        appSettingsButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        appSettingsButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        backButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  20.0).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        informationButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        informationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20.0).isActive = true
        informationButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        informationButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        textViewBackground.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        textViewBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        textViewBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        textViewBackground.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true
        
        messageToDevTeamTextView.topAnchor.constraint(equalTo: textViewBackground.topAnchor).isActive = true
        messageToDevTeamTextView.leadingAnchor.constraint(equalTo: textViewBackground.leadingAnchor, constant:  10.0).isActive = true
        messageToDevTeamTextView.trailingAnchor.constraint(equalTo: textViewBackground.trailingAnchor, constant: -10.0).isActive = true
        messageToDevTeamTextView.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true
        
        starRatingCosmosView.topAnchor.constraint(equalTo: textViewBackground.bottomAnchor, constant: 15.0).isActive = true
        starRatingCosmosView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        starRatingCosmosView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        starRatingCosmosView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        sendButtonDevTeam.topAnchor.constraint(equalTo: starRatingCosmosView.bottomAnchor, constant: 20.0).isActive = true
        sendButtonDevTeam.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        sendButtonDevTeam.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        sendButtonDevTeam.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
    }
    
    func setupMessageToDevTeamTextView(){
        messageToDevTeamTextView.translatesAutoresizingMaskIntoConstraints = false
        messageToDevTeamTextView.accessibilityIdentifier = "MessageToDevTeam"
        messageToDevTeamTextView.delegate = self
        messageToDevTeamTextView.text = NSLocalizedString("Message to app developer text", comment: "")
        messageToDevTeamTextView.textColor = ColorBook.apgBlack
        messageToDevTeamTextView.font = FontBook.MontserratRegular.of(size: 16)
        messageToDevTeamTextView.backgroundColor = .clear
        self.view.addSubview(messageToDevTeamTextView)
    }
    
}

extension FeedbackViewController: UITextFieldDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        appSettingsButton.isHidden = true
        backButton.isHidden = false
        
        if messageToDevTeamTextView.isEditable == true {
            messageToDevTeamTextView.font = FontBook.MontserratRegular.of(size: 16)
            messageToDevTeamTextView.textColor = ColorBook.apgGray
            messageToDevTeamTextView.text = NSLocalizedString("Message to app developer text", comment: "")
        }
        textView.textColor = ColorBook.apgLightGray
        textView.text = ""
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.font = FontBook.MontserratRegular.of(size: 16)
            textView.textColor = mainLightGrayColor
            textView.text = NSLocalizedString("Message to app developer text", comment: "")
        }
        appSettingsButton.isHidden = false
        backButton.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}
