//
//  AlertsViewController.swift
//  Armor
//
//  Created by John on 11/6/19.
//  Copyright © 2019 evolutn.io. All rights reserved.
//

import UIKit
import Firebase
import WebKit
import CoreData
import UserNotifications
import MaterialShowcase

class AlertsViewController: UIViewController, WKUIDelegate {
    
    let mainGrayColor = ColorBook.apgGray
    
    let backgroundColor = ColorBook.apgBlack
    let primaryColor = ColorBook.apgLightGray
    
    var alertsTableView: UITableView = UITableView()
    var alertsData = [Alerts]()
    var maxDateData = [MaxID]()
    var contentHeights = [CGFloat](repeating: 0.0, count: 100)
    var databaseReference: DatabaseReference = Database.database().reference()
    let persistenceService = PersistenseService.shared
    var currentIndexPath: Int = 0
    var webView = WKWebView()
    
    var timerCellSwipeButton: Timer?
    
    var screenSizeType = ScreenSize()
    var buttonSize : CGFloat!
    
    var tutorialStep = 1
    let sequence = MaterialShowcaseSequence()
    let firstLaunchedKey = "AlertsViewFirstLaunche"
    let defaults = UserDefaults.standard
    
    let iapManager = IAPManager.shared
    let userDefaults = UserDefaults.standard
    
    lazy var informationButton : UIButton = {
        let button = InformationButton()
        button.addTarget(self, action: #selector(PrivacyViewController.infoButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var appSettingsButton : UIButton = {
        let button = AppSettingsButton()
        button.addTarget(self, action: #selector(PrivacyViewController.serviceButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var topLabel : UILabel = {
        let label = TopLabel()
        label.labelText(text: NSLocalizedString("Alerts top label text", comment: ""))
        label.labelTextColor(textColor: primaryColor)
        return label
    }()
    
    lazy var webViewFullScreen: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        
        self.view.addSubview(topLabel)
        self.view.addSubview(informationButton)
        self.view.addSubview(appSettingsButton)
        
        UNUserNotificationCenter.current().delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "reloadAlerts"), object: nil)
        
        databaseObserveValue(reference: databaseReference)
        databaseObserveChildAdded(reference: databaseReference)
        databaseObserveChildChanged(reference: databaseReference)
        databaseObserveChildRemoved(reference: databaseReference)
        
        fetchAlerts()
        alertsTableView.backgroundColor = mainGrayColor
        self.persistenceService.fetch(MaxID.self) { [weak self] (maxDateIn) in
            self?.maxDateData = maxDateIn
        }
        
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        webView.navigationDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        screenSizeType.checkParameters()
        setupHeightParameters()
        
        setupAlertsTableView()
        
        view.addSubview(webViewFullScreen)
        webViewFullScreen.isHidden = true
        
        setupConstraints()
        
        fetchAlerts()
        deleteBadgeInTabBarItem()
        
        // comment lines from 114 to 117 if you want to use virtual simulator
        /*
        if !userDefaults.bool(forKey: "Purchased") {
            let identifier = iapManager.products[0].productIdentifier
            iapManager.purchase(productWith: identifier)
        }
 */
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timerCellSwipeButton?.invalidate()
    }
    
    func alertForDeleteAlert(indexPath: IndexPath) {
        let alertService = AlertService()
        let alertVC = alertService.alertWithCancel(title: NSLocalizedString("Delete alert title", comment: ""), body: NSLocalizedString("Delete alert body", comment: "")) {
            let currentId = self.alertsData[indexPath.row].id
            self.persistenceService.updateIsDeleteInAlerts(withId: currentId)
            self.alertsData.remove(at: indexPath.row)
            self.contentHeights.remove(at: indexPath.row)
            self.alertsTableView.deleteRows(at: [indexPath], with: .fade)
            self.fetchAlerts()
            alertService.removeBlurFromView(mainView: self.view)
        }
        alertService.addBlurToView(mainView: self.view)
        present(alertVC, animated: true)
        alertVC.cancelButtonAction = {
            alertService.removeBlurFromView(mainView: self.view)
        }
    }
    
    func fetchAlerts() {
        persistenceService.fetch(Alerts.self) { [weak self] (allAlerts) in
            self?.alertsData = allAlerts
            self?.alertsTableView.reloadData()
        }
        persistenceService.filterAlerts(currentIsDelete: 0, completion: {
            [weak self] (allAlerts) in
            self?.alertsData = allAlerts as! [Alerts]
            self?.alertsTableView.reloadData()
        })
    }
    
    @objc func infoButtonIsClicked(sender: UIButton) {
        let infoVC = InfoButtonAnimationViewController()
        infoVC.topInfoHeaderLabelText(text: NSLocalizedString("Alerts info header", comment: ""))
        infoVC.topInfoBodyLabelText(text: NSLocalizedString("Alerts info body", comment: ""))
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
        mainViewTutorials()
    }
    
    func mainViewTutorials() {
        let showcasePrivacy = MaterialShowcase()
        showcasePrivacy.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 0, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcasePrivacy)
        showcasePrivacy.primaryText = NSLocalizedString("Primary text Privacy", comment: "")
        showcasePrivacy.secondaryText = NSLocalizedString("Description tutorials privacy", comment: "")
        
        let showcaseAlerts = MaterialShowcase()
        showcaseAlerts.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 1, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseAlerts)
        showcaseAlerts.primaryText = NSLocalizedString("Primary text Alerts", comment: "")
        showcaseAlerts.secondaryText = NSLocalizedString("Description tutorials alerts", comment: "")
        
        let showcaseBreaches = MaterialShowcase()
        showcaseBreaches.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 2, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseBreaches)
        showcaseBreaches.primaryText = NSLocalizedString("Primary text Breaches", comment: "")
        showcaseBreaches.secondaryText = NSLocalizedString("Description tutorials breaches", comment: "")
        
        let showcaseFeedback = MaterialShowcase()
        showcaseFeedback.setTargetView(tabBar: self.tabBarController!.tabBar, itemIndex: 3, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseFeedback)
        showcaseFeedback.primaryText = NSLocalizedString("Primary text Feedback", comment: "")
        showcaseFeedback.secondaryText = NSLocalizedString("Description tutorials feedback", comment: "")
        
        showcasePrivacy.delegate = self
        showcaseAlerts.delegate = self
        showcaseBreaches.delegate = self
        showcaseFeedback.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { self.sequence.temp(showcasePrivacy).temp(showcaseAlerts).temp(showcaseBreaches).temp(showcaseFeedback).start()
        })
    }
    
    @objc func notifServiceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    @objc func refresh() {
        self.fetchAlerts()
        self.contentHeights = [CGFloat](repeating: 0.0, count: 100)
        self.alertsTableView.reloadData()
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
    
    @objc func serviceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    func setupAlertsTableView() {
        alertsTableView.isHidden = false
        
        alertsTableView.backgroundColor = backgroundColor
        alertsTableView.translatesAutoresizingMaskIntoConstraints = false
        
        alertsTableView.alwaysBounceVertical = false
        alertsTableView.showsVerticalScrollIndicator = false
        alertsTableView.separatorStyle = .none
        
        alertsTableView.delegate = self
        alertsTableView.dataSource = self
        //        alertsTableView.tableFooterView = UIView(frame: .zero)
        alertsTableView.register(AdviceTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(alertsTableView)
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
        
        informationButton.centerYAnchor.constraint(equalTo: topLabel.centerYAnchor).isActive = true
        informationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -20.0).isActive = true
        informationButton.heightAnchor.constraint(equalToConstant: 42.0).isActive = true
        informationButton.widthAnchor.constraint(equalToConstant: 42.0).isActive = true
        
        alertsTableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        alertsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        alertsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        alertsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        webViewFullScreen.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        webViewFullScreen.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webViewFullScreen.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webViewFullScreen.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setupHeightParameters() {
        if ScreenSize.largeScreen {
            buttonSize = 40.0
        } else if ScreenSize.middleScreen {
            buttonSize = 35.0
        } else if ScreenSize.smallScreen {
            buttonSize = 30.0
        }
    }
    
    func setupMaterialShowcaseParameters(showcase: MaterialShowcase) {
        showcase.backgroundViewType = .circle
        showcase.primaryTextColor = ColorBook.apgGreen
        showcase.secondaryTextColor = ColorBook.mainWhite
        showcase.targetTintColor = ColorBook.mainWhite
        showcase.targetHolderColor = .clear
        showcase.backgroundPromptColor = ColorBook.apgGray
        showcase.targetHolderRadius = 40
        showcase.backgroundRadius = 1900
        showcase.primaryTextSize = 18
        showcase.primaryTextFont = UIFont.systemFont(ofSize: 18)
        showcase.isTapRecognizerForTargetView = false
    }
    
    func setupUI() {
        self.view.backgroundColor = backgroundColor
        self.webViewFullScreen.isHidden = false
    }
    
}

extension AlertsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AdviceTableViewCell
        let htmlHeight = contentHeights[indexPath.row]
        let adviceArrayString = alertsData[indexPath.row].alert
        cell.adviceWebView.tag = indexPath.row
        cell.adviceWebView.navigationDelegate = self
        if adviceArrayString!.starts(with: "https://") {
            cell.adviceWebView.load(URLRequest(url: URL(string: adviceArrayString!)!))
            
            cell.adviceWebView.addGestureRecognizer(tapGesture())
        } else {
            cell.adviceWebView.loadHTML(fromString: adviceArrayString!)
            cell.adviceWebView.addGestureRecognizer(tapGesture())
        }
        cell.adviceWebView.frame = CGRect(x: 0, y: 0, width: cell.frame.size.width, height: htmlHeight)
        cell.labelText(text: alertsData[indexPath.row].title!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let smth = contentHeights[indexPath.row]
        sortAlertsByDate()
        return smth + 76.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alertsData.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let currentId = alertsData[indexPath.row].id
        self.persistenceService.updateIsDeleteInAlerts(withId: currentId)
        alertsData.remove(at: indexPath.row)
        contentHeights.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        fetchAlerts()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action =  UIContextualAction(style: .destructive, title: "", handler: { (action,view,completionHandler ) in
            self.alertForDeleteAlert(indexPath: indexPath)
            completionHandler(true)
        })
        action.image = UIGraphicsImageRenderer(size: CGSize(width: 22.5, height: 25)).image { _ in
            UIImage(named: "delete_button_for_alerts_swiping")?.draw(in: CGRect(x: 0, y: 0, width: 22.5, height: 25))
        }
        action.backgroundColor = .clear
        
        self.timerCellSwipeButton = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(timerCellSwipeButtonFunction), userInfo: nil, repeats: true)
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        return configuration
    }
    
    func sortAlertsByDate() {
        self.alertsData.sort { $1.id < $0.id }
    }
    
    @objc func timerCellSwipeButtonFunction() {
        let buttons = alertsTableView.allSubViews.filter { (view) -> Bool in
            String(describing: type(of: view)) == "UISwipeActionStandardButton"
        }
        for button in buttons {
            if let view = button.subviews.first(where: { !($0 is UIImageView)})
            {
                view.backgroundColor = .clear
            }
        }
        self.timerCellSwipeButton?.invalidate()
    }
    
}

struct RequestVariable {
    static var requestVariable = ""
    static var countOfBadges = 0
}
