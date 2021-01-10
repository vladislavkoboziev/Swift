//
//  BreachesViewController.swift
//  Armor
//
//  Created by John on 11/6/19.
//  Copyright © 2019 evolutn.io. All rights reserved.
//

import UIKit
import CoreData
import Network
import LocalAuthentication
import MaterialShowcase

class BreachesViewController: UIViewController {
    
    let mainGrayColor = ColorBook.apgGray
    let mainLightGrayColor = ColorBook.apgGray
    let mainWhiteColor = ColorBook.apgGreen
    
    let primaryColor =  ColorBook.apgLightGray
    let backgroundColor = ColorBook.apgBlack
    
    var screenSizeType = ScreenSize()
    var breachedEmailsTableRowHeight : CGFloat!
    var breachesTableRowHeight : CGFloat!
    var breachedEmailsTableViewHeight : CGFloat!
    var breachesTableViewHeight : CGFloat!
    var buttonSize : CGFloat!
    
    var alertOkIsSelected : Bool! = false
    var breachedEmails = [BreachedEmails]()
    var breaches = [Breaches]()
    var breachedEmailsTableView : UITableView = UITableView()
    var breachesTableView : UITableView = UITableView()
    var checkWifi = false
    var deleteButton : UIButton!
    var deleteButtonInBreaches : UIButton!
    var inputEmail : String! = ""
    let networkingService = NetworkingService.shared
    let persistenceService = PersistenseService.shared
    
    var selectedIndexPath : IndexPath?
    let sequenceBreaches = MaterialShowcaseSequence()
    let firstLaunchedKey = "BreachesFirstLaunche"
    let defaults = UserDefaults.standard
    
    lazy var appSettingsButton : UIButton = {
        let button = AppSettingsButton()
        button.addTarget(self, action: #selector(BreachesViewController.serviceButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton : UIButton = {
        let button = BackButton()
        button.addTarget(self, action: #selector(BreachesViewController.backButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var informationButton : UIButton = {
        let button = InformationButton()
        button.addTarget(self, action: #selector(BreachesViewController.infoButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    var imageForSwipingAction = UIImage(named: "delete_button_for_breaches_swiping.png")
    
    lazy var inputEmailTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.accessibilityIdentifier = "InputEmailOrLogin"
        textField.textColor = ColorBook.apgLightGray
        textField.font = FontBook.MontserratRegular.of(size: 16)
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        textField.attributedPlaceholder = NSAttributedString(string:NSLocalizedString("Text field placeholder", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: ColorBook.apgBlack])
        textField.addTarget(self, action: #selector(inputTextFieldIsClicked), for: .touchDown)
        return textField
    }()
    
    lazy var addButton : UIButton = {
        let button = AddButton()
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(BreachesViewController.checkEmail(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var topLabel : UILabel = {
        let label = TopLabel()
        label.labelText(text: NSLocalizedString("Breaches top label text", comment: ""))
        label.labelTextColor(textColor: primaryColor)
        return label
    }()
    
    lazy var backgroundForTextField : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgLightGrayTwo
        view.layer.cornerRadius = 15.0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        
        self.view.addSubview(topLabel)
        self.view.addSubview(informationButton)
        self.view.addSubview(appSettingsButton)
        self.view.addSubview(backButton)
        self.view.addSubview(addButton)
        self.view.addSubview(backgroundForTextField)
        self.view.addSubview(inputEmailTextField)
        backButton.isHidden = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("PersistedDataUpdated"), object: nil, queue: .main) { (_) in
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "reloadTableViews"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        fetchBreachedEmails()
        fetchBreaches()
        inputEmailTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        screenSizeType.checkParameters()
        setupHeightParameters()
        
        monitorWifiConnection()
        onResetButtonTouchUpInside()
        checkPasscode()
        selectedIndexPath = IndexPath(item: -1, section: 0)
        
        setupAccountsTableView()
        
        setupBreachesTableView()
        
        setupConstraints()
        
        fetchBreachedEmails()
        self.breachedEmailsTableView.reloadData()
        
        fetchBreaches()
        self.sortArrayByDate()
        
        checkForDeleteBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let hasLaunched = defaults.bool(forKey: firstLaunchedKey)
        if !hasLaunched {
            breachesTutorials()
            defaults.set(true, forKey: firstLaunchedKey)
        }
    }
    
    func addBadgeToTabBarItem() {
        self.tabBarItem.badgeValue = ""
    }
    
    func alertForDeleteBreachedEmail(indexPath: IndexPath) {
        let alertService = AlertService()
        let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Delete account alert title", comment: ""), body: NSLocalizedString("Delete account alert body", comment: "")) {
            let currentEmail = self.breachedEmails[indexPath.row].basedEmail!
            self.persistenceService.updateIsDeleteInBreachedEmail(basedEmail: currentEmail)
            self.breachedEmails.remove(at: indexPath.row)
            self.breachedEmailsTableView.deleteRows(at: [indexPath], with: .fade)
            self.fetchBreaches()
            self.checkForDeleteBadge()
            alertService.removeBlurFromView(mainView: self.view)
        }
        alertService.addBlurToView(mainView: self.view)
        present(alertVC, animated: true)
        alertVC.cancelButtonAction = {
            alertService.removeBlurFromView(mainView: self.view)
        }
    }
    
    func alertForDeleteBreaches(indexPath: IndexPath) {
        let alertService = AlertService()
        let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Delete breach alert title", comment: ""), body: NSLocalizedString("Delete breach alert body", comment: "")) {
            let breachDescription = self.breaches[indexPath.row].descriptions!
            let breachGeneralEmail = self.breaches[indexPath.row].generalEmail!
            self.persistenceService.updateIsDeleteInBreaches(descriptions: breachDescription, generalEmail: breachGeneralEmail)
            self.breaches.remove(at: indexPath.row)
            self.breachesTableView.deleteRows(at: [indexPath], with: .fade)
            self.checkForDeleteBadge()
            alertService.removeBlurFromView(mainView: self.view)
        }
        alertService.addBlurToView(mainView: self.view)
        present(alertVC, animated: true)
        alertVC.cancelButtonAction = {
            alertService.removeBlurFromView(mainView: self.view)
        }
    }
    
    @objc func appMovedToForeground() {
        checkPasscode()
    }
    
    @objc func backButtonIsClicked(sender: UIButton) {
        backButton.isHidden = true
        appSettingsButton.isHidden = false
        inputEmailTextField.endEditing(true)
    }
    
    func breachedEmailsCell(cell: BreachedEmailsCell, didTappped button: UIButton) {
        let alertService = AlertService()
        let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Delete account alert title", comment: ""), body: NSLocalizedString("Delete account alert body", comment: "")) {
            let buttonPosition: CGPoint = button.convert(.zero, to: self.breachedEmailsTableView)
            let indexPath: IndexPath = self.breachedEmailsTableView.indexPathForRow(at: buttonPosition)!
            let currentEmail = self.breachedEmails[indexPath.row].basedEmail!
            self.persistenceService.updateIsDeleteInBreachedEmail(basedEmail: currentEmail)
            self.breachedEmails.remove(at: indexPath.row)
            self.breachedEmailsTableView.deleteRows(at: [indexPath], with: .fade)
            self.fetchBreaches()
            self.checkForDeleteBadge()
            alertService.removeBlurFromView(mainView: self.view)
        }
        alertService.addBlurToView(mainView: self.view)
        present(alertVC, animated: true)
        alertVC.cancelButtonAction = {
            alertService.removeBlurFromView(mainView: self.view)
        }
    }
    
    func breachesCell(cell: BreachesCell, didTappped button: UIButton) {
        let alertService = AlertService()
        let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Delete breach alert title", comment: ""), body: NSLocalizedString("Delete breach alert body", comment: "")) {
            let buttonPosition: CGPoint = button.convert(.zero, to: self.breachesTableView)
            let indexPath: IndexPath = self.breachesTableView.indexPathForRow(at: buttonPosition)!
            let breachDescription = self.breaches[indexPath.row].descriptions!
            let breachGeneralEmail = self.breaches[indexPath.row].generalEmail!
            self.persistenceService.updateIsDeleteInBreaches(descriptions: breachDescription, generalEmail: breachGeneralEmail)
            self.breaches.remove(at: indexPath.row)
            self.breachesTableView.deleteRows(at: [indexPath], with: .fade)
            self.checkForDeleteBadge()
            alertService.removeBlurFromView(mainView: self.view)
        }
        alertService.addBlurToView(mainView: self.view)
        present(alertVC, animated: true)
        alertVC.cancelButtonAction = {
            alertService.removeBlurFromView(mainView: self.view)
        }
    }
    
    func breachesTutorials() {
        let showcaseBreachesAdd = MaterialShowcase()
        showcaseBreachesAdd.setTargetView(button: addButton)
        showcaseBreachesAdd.primaryText = NSLocalizedString("Primary text input email or username", comment: "")
        showcaseBreachesAdd.secondaryText = NSLocalizedString("Description tutorials input email or username", comment: "")
        setupMaterialShowcaseParameters(showcase: showcaseBreachesAdd, holderRadius: 40)
        
        let showcaseBreachesAccounts = MaterialShowcase()
        let currentBreachesAccountsView = breachedEmailsTableView.headerView(forSection: 0)?.viewWithTag(3000) ?? breachedEmailsTableView
        showcaseBreachesAccounts.setTargetView(view: currentBreachesAccountsView)
        showcaseBreachesAccounts.primaryText = NSLocalizedString("Primary text accounts", comment: "")
        showcaseBreachesAccounts.secondaryText = NSLocalizedString("Description tutorials accounts", comment: "")
        setupMaterialShowcaseParameters(showcase: showcaseBreachesAccounts, holderRadius: 50)
        
        let showcaseBreachesBr = MaterialShowcase()
        let currentBreachesView = breachesTableView.headerView(forSection: 0)?.viewWithTag(3003) ?? breachesTableView
        showcaseBreachesBr.setTargetView(view: currentBreachesView)
        showcaseBreachesBr.primaryText = NSLocalizedString("Primary text breaches", comment: "")
        showcaseBreachesBr.secondaryText = NSLocalizedString("Description tutorials breachesOne", comment: "")
        setupMaterialShowcaseParameters(showcase: showcaseBreachesBr, holderRadius: 50)
        
        showcaseBreachesAdd.delegate = self
        showcaseBreachesAccounts.delegate = self
        showcaseBreachesBr.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.sequenceBreaches.temp(showcaseBreachesAdd).temp(showcaseBreachesAccounts).temp(showcaseBreachesBr).start()
        })
    }
    
    @objc func checkEmail(sender : UIButton ) {
        appSettingsButton.isHidden = false
        backButton.isHidden = true
        selectedIndexPath = IndexPath(item: -1, section: 0)
        monitorWifiConnection()
        if checkWifi == false {
            serviceAlert(body: NSLocalizedString("Service no internet alert body", comment: ""))
        } else {
            if textFieldDidChange(textField: inputEmailTextField) == true {
                serviceAlert(body: NSLocalizedString("Service exist account alert body", comment: ""))
            } else {
                inputEmail = inputEmailTextField.text
                self.persistenceService.fetch(BreachedEmails.self) { (breachedEmails) in
                    let index = breachedEmails.first(where: { $0.basedEmail == self.inputEmail })
                    if index != nil {
                        self.serviceAlert(body: NSLocalizedString("Service early serched alert body", comment: ""))
                    } else {
                        self.searchBreachedEmail()
                        self.searchBreaches(with: self.inputEmail)
                        self.breachesTableView.reloadData()
                        self.sortArrayByDate()
                    }
                }
            }
        }
        view.endEditing(true)
    }
    
    @objc func checkForDeleteBadge() {
        let index = breaches.first(where: { $0.isViewed == 0 })
        let indexTwo = breachedEmails.first(where: { $0.isViewed == 0 })
        if index == nil && indexTwo == nil {
            deleteBadgeInTabBarItem()
        } else {
            addBadgeToTabBarItem()
        }
    }
    
    func checkPasscode() {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            return
        } else {
            let alertService = AlertService()
            let alertVC = alertService.alertWithOkAction(title: NSLocalizedString("Check passcode alert title", comment: ""), body: NSLocalizedString("Check passcode alert body", comment: "")) {
                alertService.removeBlurFromView(mainView: self.view)
                self.openPhoneSettings()
            }
            alertService.addBlurToView(mainView: self.view)
            self.present(alertVC, animated: true)
            
        }
    }
    
    func deleteBadgeInTabBarItem() {
        self.tabBarItem.badgeValue = nil
    }
    
    func fetchBreachedEmails() {
        persistenceService.fetch(BreachedEmails.self) { [weak self] (basedEmails) in
            self?.breachedEmails = basedEmails
            self?.breachedEmailsTableView.reloadData()
        }
        persistenceService.filterBreachedEmails(currentIsDelete: 0, completion: { [weak self] (breachedEmails) in
            self?.breachedEmails = breachedEmails as! [BreachedEmails]
            self?.breachedEmailsTableView.reloadData()
            self?.sortArrayByDate()
        })
    }
    
    func fetchBreaches() {
        persistenceService.fetch(Breaches.self) { [weak self] (breaches) in
            self?.breaches = breaches
            self?.breachesTableView.reloadData()
        }
        persistenceService.filterBreaches(currentIsDelete: 0, completion: { [weak self] (breaches) in
            self?.breaches = breaches as! [Breaches]
            self?.breachesTableView.reloadData()
            self?.sortArrayByDate()
        })
    }
    
    @objc func infoButtonIsClicked(sender: UIButton) {
        let infoVC = InfoButtonAnimationViewController()
        infoVC.topInfoHeaderLabelText(text: NSLocalizedString("Breaches info header", comment: ""))
        infoVC.topInfoBodyLabelText(text: NSLocalizedString("Breaches info body", comment: ""))
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
    
    @objc func inputTextFieldIsClicked(textField: UITextField) {
        appSettingsButton.isHidden = true
        backButton.isHidden = false
    }
    
    fileprivate func monitorWifiConnection() {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.usesInterfaceType(.wifi) {
                if pathUpdateHandler.status == .satisfied {
                    self.checkWifi = true
                }
            }
            else {
                self.checkWifi = false
            }
        }
        let queue = DispatchQueue(label: "Wifi")
        monitor.start(queue: queue)
    }
    
    @objc func notifServiceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    func onResetButtonTouchUpInside() {
        if let selectedIndexPaths = breachedEmailsTableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                breachedEmailsTableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func openPhoneSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func refresh() {
        self.fetchBreachedEmails()
        self.fetchBreaches()
        self.breachedEmailsTableView.reloadData()
        self.breachesTableView.reloadData()
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func searchBreachedEmail() {
        if inputEmailTextField.text != "" {
            let currentInputEmail = inputEmail
            let basedEmailOne = NSEntityDescription.insertNewObject(forEntityName: "BreachedEmails", into: self.persistenceService.context) as! BreachedEmails
            basedEmailOne.setValue(0, forKey: "isViewed")
            basedEmailOne.setValue(0, forKey: "isDelete")
            basedEmailOne.setValue(currentInputEmail, forKey: "basedEmail")
            self.breachedEmails = [basedEmailOne]
            DispatchQueue.main.async {
                self.sortArrayByName()
                self.persistenceService.save()
                self.fetchBreachedEmails()
            }
            self.inputEmailTextField.text = ""
        }
    }
    
    func searchBreaches(with email: String) {
        let urlPathFirstPart = "https://haveibeenpwned.com/unifiedsearch/"
        let urlPath = urlPathFirstPart + email
        let urlPathWithCorrect = urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlPathWithCorrect!)
        networkingService.request(urlPathWithCorrect!) { (result) in
            switch result {
            case .success( _):
                do {
                    guard let data = try? Data(contentsOf: url!) else { return }
                    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else { return }
                    guard let jsonArray = json as? [String: Any] else { return }
                    let emailsArray = jsonArray["Breaches"] as? [[String: Any]]
                    
                    let emails: [Breaches] = emailsArray!.compactMap { [weak self] in
                        guard
                            let strongSelf = self,
                            let name = $0["Name"] as? String,
                            let domain = $0["Domain"] as? String,
                            let breachDate = $0["BreachDate"] as? String,
                            let description = $0["Description"] as? String
                            else { return nil }
                        
                        let emailOne = NSEntityDescription.insertNewObject(forEntityName: "Breaches", into: strongSelf.persistenceService.context) as! Breaches
                        let generalEmail = self?.inputEmail
                        let isViewed = 0
                        let isDelete = 0
                        emailOne.setValue(name, forKey: "name")
                        emailOne.setValue(domain, forKey: "domain")
                        emailOne.setValue(breachDate, forKey: "breachDate")
                        emailOne.setValue(description, forKey: "descriptions")
                        emailOne.setValue(generalEmail, forKey: "generalEmail")
                        emailOne.setValue(isViewed, forKey: "isViewed")
                        emailOne.setValue(isDelete, forKey: "isDelete")
                        return emailOne
                    }
                    self.breaches = emails
                    DispatchQueue.main.async {
                        self.sortArrayByDate()
                        self.persistenceService.save()
                        self.fetchBreaches()
                        self.addBadgeToTabBarItem()
                    }
                }
            case .failure(let error): print(error)
            }
        }
    }
    
    func setupConstraints() {
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
        
        backgroundForTextField.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        backgroundForTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        backgroundForTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        backgroundForTextField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        inputEmailTextField.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        inputEmailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  30.0).isActive = true
        inputEmailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30.0).isActive = true
        inputEmailTextField.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        addButton.topAnchor.constraint(equalTo: backgroundForTextField.bottomAnchor, constant: 15.0).isActive = true
        addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        breachedEmailsTableView.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 15.0).isActive = true
        breachedEmailsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        breachedEmailsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        breachedEmailsTableView.heightAnchor.constraint(equalToConstant: breachedEmailsTableViewHeight).isActive = true
        
        breachesTableView.topAnchor.constraint(equalTo: breachedEmailsTableView.bottomAnchor, constant: 15.0).isActive = true
        breachesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        breachesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        breachesTableView.heightAnchor.constraint(equalToConstant: breachesTableViewHeight).isActive = true
    }
    
    func setupHeightParameters() {
        if ScreenSize.largeScreen {
            breachedEmailsTableRowHeight = 50.0
            breachedEmailsTableViewHeight = 150.0
            breachesTableRowHeight = 100.0
            breachesTableViewHeight = 350.0
            buttonSize = 40.0
        } else if ScreenSize.middleScreen {
            breachedEmailsTableRowHeight = 40.0
            breachedEmailsTableViewHeight = 120.0
            breachesTableRowHeight = 70.0
            breachesTableViewHeight = 250.0
            buttonSize = 35.0
        } else if ScreenSize.smallScreen {
            breachedEmailsTableRowHeight = 30.0
            breachedEmailsTableViewHeight = 90.0
            breachesTableRowHeight = 50.0
            breachesTableViewHeight = 180.0
            buttonSize = 30.0
        }
    }
    
    func setupAccountsTableView() {
        breachedEmailsTableView.accessibilityIdentifier = "BreachedEmails"
        breachedEmailsTableView.backgroundColor = ColorBook.apgGray
        breachedEmailsTableView.tintColor = ColorBook.apgLightGray
        breachedEmailsTableView.separatorColor = ColorBook.apgBlack
        breachedEmailsTableView.translatesAutoresizingMaskIntoConstraints = false
        breachedEmailsTableView.layer.cornerRadius = 15
        breachedEmailsTableView.delegate = self
        breachedEmailsTableView.dataSource = self
        breachedEmailsTableView.tableFooterView = UIView(frame: .zero)
        breachedEmailsTableView.register(BreachedEmailsCell.self, forCellReuseIdentifier: "CellOne")
        breachedEmailsTableView.register(PrivacyHeaderView.self, forHeaderFooterViewReuseIdentifier: "breachedEmailsHeader")
        breachedEmailsTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.view.addSubview(breachedEmailsTableView)
    }
    
    func setupBreachesTableView() {
        breachesTableView.accessibilityIdentifier = "Breaches"
        breachesTableView.backgroundColor = ColorBook.apgGray
        breachesTableView.tintColor = ColorBook.apgLightGray
        breachesTableView.separatorColor = ColorBook.apgBlack
        breachesTableView.translatesAutoresizingMaskIntoConstraints = false
        breachesTableView.layer.cornerRadius = 15
        breachesTableView.delegate = self
        breachesTableView.dataSource = self
        breachesTableView.tableFooterView = UIView(frame: .zero)
        breachesTableView.register(BreachesCell.self, forCellReuseIdentifier: "CellTwo")
        breachesTableView.register(PrivacyHeaderView.self, forHeaderFooterViewReuseIdentifier: "breachesHeader")
        breachesTableView.allowsMultipleSelection = true
        breachesTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.view.addSubview(breachesTableView)
    }
    
    func setupMaterialShowcaseParameters(showcase: MaterialShowcase, holderRadius: CGFloat) {
        showcase.primaryTextColor = ColorBook.apgGreen
        showcase.secondaryTextColor = ColorBook.mainWhite
        showcase.targetTintColor = .clear
        showcase.targetHolderColor = .clear
        showcase.backgroundPromptColor = ColorBook.apgGray
        showcase.targetHolderRadius = holderRadius
        showcase.backgroundRadius = 1900
        showcase.primaryTextSize = 18
        showcase.secondaryTextSize = 16
        showcase.primaryTextFont = UIFont.systemFont(ofSize: 18)
        showcase.isTapRecognizerForTargetView = false
    }
    
    func serviceAlert(body: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let messageText = NSAttributedString(
            string: body,
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.foregroundColor : mainWhiteColor,
                NSAttributedString.Key.font : FontBook.MontserratRegular.of(size: 16) as Any
            ]
        )
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(messageText, forKey: "attributedMessage")
        self.inputEmailTextField.text = ""
        self.present(alert, animated: true)
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.layer.cornerRadius = 1
        subview.backgroundColor = ColorBook.apgGray
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func serviceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    func sortArrayByDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.breaches.sort { dateFormatter.date(from: $1.breachDate!)! < dateFormatter.date(from: $0.breachDate!)! }
    }
    
    func sortArrayByName() {
        _ = breachedEmails.sorted { $0.basedEmail! > $1.basedEmail! }
    }
    
    func titleTextView(objectMaxY: CGFloat, text: String) -> UITextView {
        let textView = UITextView()
        textView.frame = CGRect(x: view.frame.origin.x, y: objectMaxY + 3, width: self.view.frame.width, height: 35)
        textView.backgroundColor = ColorBook.apgGray
        textView.font = FontBook.MontserratRegular.of(size: 16)
        textView.text = text
        textView.textColor = ColorBook.apgLightGray
        return textView
    }
    
}
