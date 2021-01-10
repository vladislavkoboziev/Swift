//
//  NotifServiceViewController.swift
//  Armor
//
//  Created by John on 2/13/20.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class NotifServiceViewController: UIViewController {
    
    let mainGrayColor = ColorBook.mainGray
    let mainWhiteColor = ColorBook.mainWhite
    
    var breachedEmails = [BreachedEmails]()
    var breaches = [Breaches]()
    var notifServiceTableView : UITableView = UITableView()
    var textLabelText = [NSLocalizedString("Reload breaches cell title", comment: ""), NSLocalizedString("Reload alerts cell title", comment: ""), NSLocalizedString("Alerts notifications", comment: "")]
    var notifCenterSwitch : UISwitch!
    let persistenceService = PersistenseService.shared
    let userDefaults = UserDefaults.standard
    var reloadBreachesButton : UIButton!
    var reloadAlertsButton : UIButton!
    
    var tableRowHeight : CGFloat = 50.0
    var tableViewHeight : CGFloat = 200.0
    
    lazy var backToPrivacyButton : UIButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(NotifServiceViewController.onTapCloseButton(sender:)), for: .touchUpInside)
        return button
    }()
    
    var firstTimeAppLaunch: Bool {
        get {
            return userDefaults.bool(forKey: "firstTimeAppLaunch")
        }
        set {}
    }
    
    lazy var informationButton : UIButton = {
        let button = InformationButton()
        button.addTarget(self, action: #selector(NotifServiceViewController.infoButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var soomzImageView : UIImageView = {
        let soomzImageView = UIImageView()
        soomzImageView.translatesAutoresizingMaskIntoConstraints = false
        soomzImageView.image = UIImage(named: "feedback_soomzik")
        return soomzImageView
    }()
    
    lazy var topLabel : UILabel = {
        let label = TopLabel()
        let heightOne = UIApplication.shared.statusBarFrame.height
        label.labelText(text: NSLocalizedString("Settings top label text", comment: ""))
        label.labelTextColor(textColor: ColorBook.apgLightGray)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !firstTimeAppLaunch {
            userDefaults.set(true, forKey: "firstTimeAppLaunch")
            userDefaults.set(true, forKey: "mySwitchValue")
        }
        self.view.backgroundColor = ColorBook.apgBlack
        self.title = NSLocalizedString("Settings title", comment: "")
        
        self.view.addSubview(topLabel)
        self.view.addSubview(informationButton)
        self.view.addSubview(backToPrivacyButton)
        self.view.addSubview(soomzImageView)
        
        notifServiceTableView.dataSource = self
        notifServiceTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupServiceTableView()
        notifServiceTableView.reloadData()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        notifCenterSwitch.isOn = userDefaults.bool(forKey: "mySwitchValue")
    }
    
    @objc func actionButtonIsClicked(sender : UIButton){
        if sender.tag == 110 {
            let alertService = AlertService()
            let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Reload breaches alert title", comment: ""), body: NSLocalizedString("Reload breaches alert body", comment: "")) {
                self.persistenceService.updateIsDeleteToReload()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableViews"), object: nil)
                alertService.removeBlurFromView(mainView: self.view)
            }
            alertService.addBlurToView(mainView: self.view)
            present(alertVC, animated: true)
            alertVC.cancelButtonAction = {
                alertService.removeBlurFromView(mainView: self.view)
            }
        } else if sender.tag == 111 {
            let alertService = AlertService()
            let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Reload alerts alert title", comment: ""), body: NSLocalizedString("Reload alerts alert body", comment: "")) {
                self.persistenceService.updateIsDeleteToReloadInAlerts()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAlerts"), object: nil)
                alertService.removeBlurFromView(mainView: self.view)
            }
            alertService.addBlurToView(mainView: self.view)
            present(alertVC, animated: true)
            alertVC.cancelButtonAction = {
                alertService.removeBlurFromView(mainView: self.view)
            }
        }
        
    }
    
    @objc func infoButtonIsClicked(sender: UIButton) {
        let infoVC = InfoOkButtonViewController()
        infoVC.topInfoHeaderLabelText(text: NSLocalizedString("Settings info header", comment: ""))
        infoVC.topInfoBodyLabelText(text: NSLocalizedString("Settings info body", comment: ""))
        present(infoVC, animated: true)
        
        infoVC.okAction = infoOkButtonIsClicked
    }
    
    func infoOkButtonIsClicked() {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func onTapCloseButton(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupConstraints() {
        topLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10.0).isActive = true
        topLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        topLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        topLabel.heightAnchor.constraint(equalToConstant: 55.0).isActive = true
        
        backToPrivacyButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        backToPrivacyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  20.0).isActive = true
        backToPrivacyButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        backToPrivacyButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        informationButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        informationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20.0).isActive = true
        informationButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        informationButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        notifServiceTableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        notifServiceTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        notifServiceTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        notifServiceTableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
        
        soomzImageView.topAnchor.constraint(equalTo: notifServiceTableView.bottomAnchor, constant: 15.0).isActive = true
        soomzImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        soomzImageView.widthAnchor.constraint(equalToConstant: 216.0).isActive = true
        soomzImageView.heightAnchor.constraint(equalToConstant: 275.0).isActive = true
    }
    
    func setupServiceTableView() {
        notifServiceTableView.separatorColor = ColorBook.apgBlack
        notifServiceTableView.translatesAutoresizingMaskIntoConstraints = false
        notifServiceTableView.layer.cornerRadius = 15
        notifServiceTableView.tableFooterView = UIView(frame: .zero)
        notifServiceTableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        notifServiceTableView.register(PrivacyHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
        notifServiceTableView.allowsSelection = false
        view.addSubview(notifServiceTableView)
    }
    
    @objc func toggleChanged(_ sender: UISwitch){
        userDefaults.set(sender.isOn, forKey: "mySwitchValue")
        NotificationServiceButton.alertsSwitchIsOn = sender.isOn
        switch sender.isOn {
        case true:
            sender.onTintColor = ColorBook.apgBlack
            sender.thumbTintColor = ColorBook.apgGreen
            sender.tintColor = ColorBook.apgBlack
        case false:
            sender.thumbTintColor = ColorBook.apgGray
            sender.subviews[0].subviews[0].backgroundColor = ColorBook.apgBlack
            sender.layer.cornerRadius = sender.frame.height / 2
        }
    }
    
}

extension NotifServiceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = self.textLabelText[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.textColor = ColorBook.apgLightGray
        cell.backgroundColor = ColorBook.apgGray
        cell.textLabel?.font = FontBook.MontserratRegular.of(size: 16)
        
        if indexPath.row == 0 {
            reloadBreachesButton = createActionButton(tag: indexPath.row)
            cell.accessoryView = reloadBreachesButton
        } else if indexPath.row == 1 {
            reloadAlertsButton = createActionButton(tag: indexPath.row)
            cell.accessoryView = reloadAlertsButton
        } else if indexPath.row == 2 {
            notifCenterSwitch = UISwitch(frame: .zero)
            createSwitch(currentSwitch: notifCenterSwitch, tag: indexPath.row)
            notifCenterSwitch.subviews[0].subviews[0].backgroundColor = ColorBook.apgBlack
            cell.accessoryView = notifCenterSwitch
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textLabelText.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableRowHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? PrivacyHeaderView
        header?.apply(text: NSLocalizedString("Settings title", comment: ""))
        return header
    }
    
    func createSwitch(currentSwitch: UISwitch, tag: Int) {
        currentSwitch.frame = CGRect(x: 270, y: 20, width: 100, height: 30)
        currentSwitch.tag = tag + 10
        currentSwitch.addTarget(self, action: #selector(self.toggleChanged(_:)), for: .valueChanged)
        currentSwitch.isOn = NotificationServiceButton.alertsSwitchIsOn
        if currentSwitch.isOn {
            currentSwitch.onTintColor = ColorBook.apgBlack
            currentSwitch.thumbTintColor = ColorBook.apgGreen
            currentSwitch.tintColor = ColorBook.apgBlack
        } else {
            currentSwitch.thumbTintColor = ColorBook.apgGray
            currentSwitch.subviews[0].subviews[0].backgroundColor = ColorBook.apgBlack
            currentSwitch.layer.cornerRadius = currentSwitch.frame.height / 2
        }
    }
    
    func createActionButton(tag: Int) -> UIButton {
        let actionButton = UIButton.init(type: .detailDisclosure)
        actionButton.accessibilityIdentifier = "actionButton"
        actionButton.setImage(UIImage(named: "play_circle_button_icon"), for: .normal)
        actionButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actionButton.tag = tag + 110
        actionButton.addTarget(self, action: #selector(NotifServiceViewController.actionButtonIsClicked(sender:)), for: .touchUpInside)
        return actionButton
    }
    
}

struct NotificationServiceButton {
    static var alertsSwitchIsOn = true
}
