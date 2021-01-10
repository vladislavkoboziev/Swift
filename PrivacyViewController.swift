//
//  PrivacyViewController.swift
//  Armor
//
//  Created by John on 11/6/19.
//  Copyright © 2019 evolutn.io. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import Network
import UserNotifications
import CoreMotion
import AVFoundation
import MaterialShowcase

class PrivacyViewController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate {
    
    let primaryColor = ColorBook.apgLightGray
    let backgroundColor = ColorBook.apgBlack
    
    var tableRowHeight : CGFloat = 50.0
    var tableHeaderHeight : CGFloat = 60.0
    var tableViewHeight : CGFloat = 660.0
    
    var privacyTableView : UITableView = UITableView()
    
    var privacySettings : [PrivacySettings] = [PrivacySettings]()
    
    var bluetoothManager : CBCentralManager!
    var checkMobileData = false
    var checkWifi = false
    
    var timer = Timer()
    var notificationBody : String!
    var notificationBoolArray = [Bool](repeating: false, count: 20)
    var isLastNotification = false
    var isLongTime = false
    var isWifiButtonTapped = false
    var isLocationButtonTapped = false
    var isMicrophoneButtonTapped = false
    var isCameraButtonTapped = false
    var isBluetoothButtonTapped = false
    var isMobileDataButtonTapped = false
    var tutorialStep = 1
    let sequence = MaterialShowcaseSequence()
    var tableView: UITableView!
    
    let motionManager = CMMotionManager()
    var microphoneTimer: Timer!
    var isRecording = false
    
    var camPreview: UIView!
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var cameraTimer: Timer!
    var isCameraRecording = false
    
    var standbyBluetoothCentralManager: CBCentralManager!
    var standbyBluetoothPeripheralManager: CBPeripheralManager?
    
    let filename: String = ""
    var audioRecorder: AVAudioRecorder!
    
    let firstLaunchedKey = "PrivacyFirstLaunche"
    let defaults = UserDefaults.standard
    
    lazy var appSettingsButton : UIButton = {
        let button = AppSettingsButton()
        button.addTarget(self, action: #selector(PrivacyViewController.serviceButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var bottomLabel : UILabel = {
        let label = WhiteLabel()
        label.text = NSLocalizedString("Privacy bottom label text", comment: "")
        return label
    }()
    
    lazy var informationButton : UIButton = {
        let button = InformationButton()
        button.addTarget(self, action: #selector(PrivacyViewController.infoButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var topLabel : UILabel = {
        let label = TopLabel()
        label.labelText(text: NSLocalizedString("Privacy top label text", comment: ""))
        label.labelTextColor(textColor: primaryColor)
        return label
    }()
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = backgroundColor
        
        self.bluetoothManager = CBCentralManager.init(delegate: self, queue: .main, options: [CBCentralManagerOptionShowPowerAlertKey: false])
        
        self.standbyBluetoothCentralManager = CBCentralManager(delegate: self, queue: nil)
        
        self.view.addSubview(informationButton)
        self.view.addSubview(appSettingsButton)
        self.view.addSubview(topLabel)
        
        wifiMonitor()
        
        
        
        // comment lines 132-134 to start in virtual devices without camera
       // if setupCameraSession() {
       //     startCameraSession()
       // }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wifiMonitor()
        
        createSettingsArray()
        
        setupTableView()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addSubview(privacyTableView)
        stackView.addSubview(bottomLabel)
        
        setupConstraints()
        
        configureUserNotificationsCenter()
        mobileDataMonitor()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // MARK: - Tutorials {
        let hasLaunched = defaults.bool(forKey: firstLaunchedKey)
        
        if !hasLaunched {
            privacyTutorials()
            defaults.set(true, forKey: firstLaunchedKey)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    
    
    @objc func appMovedToBackground() {
        
        stopMicAndCameraTimer()
        
        var bgTask = UIBackgroundTaskIdentifier(rawValue: 1)
        bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            UIApplication.shared.endBackgroundTask(bgTask)
        })
        notificationBody = setNotificationBody()
        privacySettings.removeAll()
        
        stopScanBluetoothCentralManager()
    }
    
    @objc func appMovedToForeground() {
        wifiMonitor()
        mobileDataMonitor()
        isMicrophoneButtonTapped = false
        isCameraButtonTapped = false
        createSettingsArray()
        notificationBoolArray = [Bool](repeating: false, count: 20)
        notificationBody = setNotificationBody()
        privacyTableView.reloadData()
        stopTimer()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            break
        case .resetting:
            break
        case .unauthorized:
            break
        case .unsupported:
            break
        case .unknown:
            break
        default:
            break
        }
    }
    
    func checkBluetooth() -> Bool {
        var checkBluetooth = false
        if bluetoothManager.state == .poweredOn {
            checkBluetooth = true
        }
        if bluetoothManager.state == .poweredOff {
            checkBluetooth = false
        }
        return checkBluetooth
    }
    
    func checkLocation() -> Bool {
        var checkLocation = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                checkLocation = true
            case .authorizedAlways, .authorizedWhenInUse:
                checkLocation = true
            @unknown default:
                print(Error.self)
            }
        } else {
            checkLocation = false
        }
        return checkLocation
    }
    
    func checkMicrophoneAccess() {
        let session = AVAudioSession.sharedInstance()
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    AccessBool.access = true
                } else {
                    AccessBool.access = false
                }
            })
        }
    }
    
    private func configureUserNotificationsCenter() {
        UNUserNotificationCenter.current().delegate = self
        
        let actionNext = UNNotificationAction(identifier: Notification.Action.nextAction, title: NSLocalizedString("Next button label", comment: ""), options: [])
        let actionBackToApp = UNNotificationAction(identifier: Notification.Action.backToApp, title: NSLocalizedString("Back to app button label", comment: ""), options: [.foreground])
        let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionNext, actionBackToApp], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([tutorialCategory])
    }
    
    func createSettingsArray() {
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Wi-Fi", comment: ""), settingIsOn: checkWifi, settingLabelTag: 10, settingButtonTag: 110, settingAutoButtonTag: 0, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Location", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 11, settingButtonTag: 111, settingAutoButtonTag: 1, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Microphone", comment: ""), settingIsOn: AccessBool.access ?? true, settingLabelTag: 12, settingButtonTag: 112, settingAutoButtonTag: 2, settingLabelColor: primaryColor, settingIsAuto: true, settingHasInfo: true))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Camera", comment: ""), settingIsOn: true, settingLabelTag: 13, settingButtonTag: 113, settingAutoButtonTag: 3, settingLabelColor: primaryColor, settingIsAuto: true, settingHasInfo: true))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Bluetooth", comment: ""), settingIsOn: checkBluetooth(), settingLabelTag: 14, settingButtonTag: 114, settingAutoButtonTag: 4, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Mobile Data", comment: ""), settingIsOn: checkMobileData, settingLabelTag: 15, settingButtonTag: 115, settingAutoButtonTag: 5, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Share My Location", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 16, settingButtonTag: 116, settingAutoButtonTag: 6, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Significant Locations", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 17, settingButtonTag: 117, settingAutoButtonTag: 7,  settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name iPhone Analytics", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 18, settingButtonTag: 118, settingAutoButtonTag: 8, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Popular Near Me", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 19, settingButtonTag: 119, settingAutoButtonTag: 9, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
        privacySettings.append(PrivacySettings(settingName: NSLocalizedString("Setting name Routing & Traffic", comment: ""), settingIsOn: checkLocation(), settingLabelTag: 20, settingButtonTag: 120, settingAutoButtonTag: 10, settingLabelColor: primaryColor, settingIsAuto: false, settingHasInfo: false))
    }
    
    @objc func infoButtonIsClicked(sender: UIButton) {
        let infoVC = InfoButtonAnimationViewController()
        infoVC.topInfoHeaderLabelText(text: NSLocalizedString("Privacy info header", comment: ""))
        infoVC.topInfoBodyLabelText(text: NSLocalizedString("Privacy info body", comment: ""))
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
    
    fileprivate func mobileDataMonitor() {
        let monitor = NWPathMonitor(requiredInterfaceType: .cellular)
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.usesInterfaceType(.cellular) {
                if pathUpdateHandler.status == .satisfied {
                    self.checkMobileData = true
                }
            } else {
                self.checkMobileData = false
            }
        }
        let queue = DispatchQueue(label: "MobileData")
        monitor.start(queue: queue)
    }
    
    func privacyTutorials() {
        let showcasePrivacyInfButton = MaterialShowcase()
        showcasePrivacyInfButton.setTargetView(button: informationButton)
        showcasePrivacyInfButton.primaryText = NSLocalizedString("Primary text information", comment: "")
        showcasePrivacyInfButton.secondaryText = NSLocalizedString("Description tutorials information", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacyInfButton, holderRadius: 40)
        
        let showcasePrivacySittings = MaterialShowcase()
        showcasePrivacySittings.setTargetView(button: appSettingsButton)
        showcasePrivacySittings.primaryText = NSLocalizedString("Primary text settings", comment: "")
        showcasePrivacySittings.secondaryText = NSLocalizedString("Description tutorials settings", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacySittings, holderRadius: 40)
        
        let showcasePrivacyTableView = MaterialShowcase()
        showcasePrivacyTableView.setTargetView(tableView: privacyTableView.self, section: 0, row: 0)
        showcasePrivacyTableView.primaryText = NSLocalizedString("Primary text auto settings", comment: "")
        showcasePrivacyTableView.secondaryText = NSLocalizedString("Description tutorials auto settings", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacyTableView, holderRadius: 190)
        showcasePrivacyTableView.targetHolderColor = .clear
        
        let showcasePrivacyMicrophon = MaterialShowcase()
        let micAutoButtonView = privacyTableView.cellForRow(at: IndexPath(row: 2, section: 0))?.viewWithTag(2)
        showcasePrivacyMicrophon.setTargetView(view: micAutoButtonView!)
        showcasePrivacyMicrophon.primaryText = NSLocalizedString("Primary text microphone", comment: "")
        showcasePrivacyMicrophon.secondaryText = NSLocalizedString("Description tutorials microphone", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacyMicrophon, holderRadius: 30)
        
        let showcasePrivacyCamera = MaterialShowcase()
        let cameraAutoButtonView = privacyTableView.cellForRow(at: IndexPath.init(row: 3, section: 0))?.viewWithTag(3)
        showcasePrivacyCamera.setTargetView(view: cameraAutoButtonView!)
        showcasePrivacyCamera.primaryText = NSLocalizedString("Primary text camera", comment: "")
        showcasePrivacyCamera.secondaryText = NSLocalizedString("Description tutorials camera", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacyCamera, holderRadius: 30)
        
        let showcasePrivacyPrivacyStandby = MaterialShowcase()
        let standbySwitchView = privacyTableView.cellForRow(at: IndexPath.init(row: 4, section: 0))?.viewWithTag(1000)
        showcasePrivacyPrivacyStandby.setTargetView(view: standbySwitchView!)
        showcasePrivacyPrivacyStandby.primaryText = NSLocalizedString("Primary text privacy standby", comment: "")
        showcasePrivacyPrivacyStandby.secondaryText = NSLocalizedString("Description tutorials privacy standby", comment: "")
        setupMaterialShowcaseParameters(showcase: showcasePrivacyPrivacyStandby, holderRadius: 30)
        
        showcasePrivacyInfButton.delegate = self
        showcasePrivacyTableView.delegate = self
        showcasePrivacyMicrophon.delegate = self
        showcasePrivacySittings.delegate = self
        showcasePrivacyCamera.delegate = self
        showcasePrivacyPrivacyStandby.delegate = self
        
         DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.sequence.temp(showcasePrivacyInfButton).temp(showcasePrivacySittings).temp(showcasePrivacyTableView).temp(showcasePrivacyMicrophon).temp(showcasePrivacyCamera).temp(showcasePrivacyPrivacyStandby).start()
        })
    }
    
    func sendNotification(body: String) {
        if isLastNotification == true {
            createLastNotification(body: body, timeInterval: 0.001, requestIdentifier: "lastNotification")
        } else {
            createNotification(body: body, timeInterval: 0.001, requestIdentifier: "notificationOne")
        }
    }
    
    @objc func serviceButtonIsClicked(sender: UIButton) {
        self.present(NotifServiceViewController(), animated: true, completion: nil)
    }
    
    func setNotificationBody() -> String {
        var currentNotificationBody = String()
        if isWifiButtonTapped || isBluetoothButtonTapped || isMobileDataButtonTapped {
            if notificationBoolArray[0] == true && notificationBoolArray[1] == false && isLastNotification == false {
                currentNotificationBody = NSLocalizedString("Tutorials Step Zero", comment: "")
            } else if notificationBoolArray[0] == true && notificationBoolArray[1] == true && notificationBoolArray[2] == false {
                if isWifiButtonTapped {
                    currentNotificationBody = NSLocalizedString("Wifi Step One", comment: "")
                } else if isBluetoothButtonTapped {
                    currentNotificationBody = NSLocalizedString("Bluetooth Step One", comment: "")
                } else if isMobileDataButtonTapped {
                    currentNotificationBody = NSLocalizedString("Mobile Data Step One", comment: "")
                }
            } else if notificationBoolArray[0] == true && notificationBoolArray[1] == true && notificationBoolArray[2] == true && notificationBoolArray[3] == false {
                if isWifiButtonTapped && checkWifi {
                    currentNotificationBody = NSLocalizedString("Wifi Step Two On", comment: "")
                } else if isBluetoothButtonTapped && checkBluetooth() {
                    currentNotificationBody = NSLocalizedString("Bluetooth Step Two On", comment: "")
                } else if isMobileDataButtonTapped && checkMobileData {
                    currentNotificationBody = NSLocalizedString("Mobile Data Step Two On", comment: "")
                }
                else {
                    if isWifiButtonTapped {
                        currentNotificationBody = NSLocalizedString("Wifi Step Two Off", comment: "")
                    } else if isBluetoothButtonTapped {
                        currentNotificationBody = NSLocalizedString("Bluetooth Step Two Off", comment: "")
                    } else if isMobileDataButtonTapped {
                        currentNotificationBody = NSLocalizedString("Mobile Data Step Two Off", comment: "")
                    }
                }
            } else if notificationBoolArray[0] == true && notificationBoolArray[1] == true && notificationBoolArray[2] == true && notificationBoolArray[3] == true && notificationBoolArray[4] == false {
                currentNotificationBody = NSLocalizedString("Back Settings Step", comment: "")
            } else if notificationBoolArray[0] == true && notificationBoolArray[1] == true && notificationBoolArray[2] == true && notificationBoolArray[3] == true && notificationBoolArray[4] == true {
                currentNotificationBody = NSLocalizedString("Back To App Step", comment: "")
            }
        } else if isMicrophoneButtonTapped {
            if isLastNotification {
                currentNotificationBody = NSLocalizedString("Microphone Step", comment: "")
            }
        } else if isCameraButtonTapped {
            if isLastNotification {
                currentNotificationBody = NSLocalizedString("Camera Step", comment: "")
            }
        } else if isLocationButtonTapped {
            if notificationBoolArray[10] == true && notificationBoolArray[11] == false && isLastNotification == false {
                currentNotificationBody = NSLocalizedString("Tutorials Step Zero", comment: "")
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == false {
                currentNotificationBody = NSLocalizedString("Location Step One", comment: "")
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == true && notificationBoolArray[13] == false {
                currentNotificationBody = NSLocalizedString("Location Step Two", comment: "")
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == true  && notificationBoolArray[13] == true && notificationBoolArray[14] == false {
                if checkLocation() == true {
                    currentNotificationBody = NSLocalizedString("Location Step Three On", comment: "")
                } else {
                    currentNotificationBody = NSLocalizedString("Location Step Three Off", comment: "")
                }
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == true && notificationBoolArray[13] == true && notificationBoolArray[14]  == true && notificationBoolArray[15]  == false  {
                currentNotificationBody = NSLocalizedString("Location Step Four", comment: "")
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == true && notificationBoolArray[13] == true && notificationBoolArray[14]  == true && notificationBoolArray[15]  == true && notificationBoolArray[16]  == false {
                currentNotificationBody = NSLocalizedString("Back Settings Step", comment: "")
            } else if notificationBoolArray[10] == true && notificationBoolArray[11] == true && notificationBoolArray[12] == true && notificationBoolArray[13] == true && notificationBoolArray[14]  == true && notificationBoolArray[15]  == true && notificationBoolArray[16]  == true {
                currentNotificationBody = NSLocalizedString("Back To App Step", comment: "")
            }
        }
        return currentNotificationBody
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
        
        scrollView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 15.0).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  15.0).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -15.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        privacyTableView.topAnchor.constraint(equalTo: stackView.topAnchor).isActive = true
        privacyTableView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        privacyTableView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        privacyTableView.heightAnchor.constraint(equalToConstant: tableViewHeight).isActive = true
        
        bottomLabel.topAnchor.constraint(equalTo: privacyTableView.bottomAnchor, constant:  15.0).isActive = true
        bottomLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        bottomLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        bottomLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant:  -15.0).isActive = true
    }
    
    func setupMaterialShowcaseParameters(showcase: MaterialShowcase, holderRadius: CGFloat) {
        showcase.backgroundViewType = .circle
        showcase.primaryTextColor = ColorBook.apgGreen
        showcase.secondaryTextColor = ColorBook.mainWhite
        showcase.targetTintColor = ColorBook.mainWhite
        showcase.targetHolderColor = ColorBook.mainWhite
        showcase.backgroundPromptColor = ColorBook.apgGray
        showcase.targetHolderRadius = holderRadius
        showcase.backgroundRadius = 1900
        showcase.primaryTextSize = 18
        showcase.primaryTextFont = UIFont.systemFont(ofSize: 18)
        showcase.isTapRecognizerForTargetView = false
    }
    
    func setupTableView() {
        privacyTableView.isUserInteractionEnabled = true
        privacyTableView.separatorColor = ColorBook.apgBlack
        privacyTableView.layer.cornerRadius = 15
        privacyTableView.dataSource = self
        privacyTableView.delegate = self
        privacyTableView.tableFooterView = UIView(frame: .zero)
        privacyTableView.register(PrivacyCell.self, forCellReuseIdentifier: "myCell")
        privacyTableView.register(PrivacyStandbyCell.self, forCellReuseIdentifier: "standbyCell")
        privacyTableView.register(PrivacyHeaderView.self, forHeaderFooterViewReuseIdentifier: "header")
//        privacyTableView.allowsSelection = false
        privacyTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        privacyTableView.isScrollEnabled = false
        privacyTableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sendNotification(body: self.notificationBody)
        }
        var timeInterval = 5.8
        if isLongTime == true {
            timeInterval = 10.0
        }
        if !timer.isValid {
            timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
                self.sendNotification(body: self.notificationBody)
            })
        }
    }
    
    func stopTimer() {
        timer.invalidate()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    fileprivate func wifiMonitor() {
        let monitor = NWPathMonitor(requiredInterfaceType: .wifi)
        monitor.pathUpdateHandler = { pathUpdateHandler in
            if pathUpdateHandler.usesInterfaceType(.wifi) {
                if pathUpdateHandler.status == .satisfied {
                    self.checkWifi = true
                }
                if pathUpdateHandler.status == .requiresConnection {
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
    
}

extension PrivacyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as? PrivacyCell
        let standbyCell = tableView.dequeueReusableCell(withIdentifier: "standbyCell") as? PrivacyStandbyCell
        
        cell?.userInteractionEnabledWhileDragging = true
        cell?.isUserInteractionEnabled = true
        cell?.clipsToBounds = true
        cell?.cellDelegate = self
        standbyCell?.cellDelegate = self
        
        cell?.backgroundColor = ColorBook.apgGray
        cell?.tintColor = ColorBook.apgLightGray
        standbyCell?.backgroundColor = ColorBook.apgGray
        cell?.selectionStyle = indexPath.row == 2-4 ? .default : .none
        if indexPath.row <= 3 {
            let currentSettings = self.privacySettings[indexPath.row]
            cell?.updateCellWith(settingName: currentSettings.settingName, settingIsOn: currentSettings.settingIsOn, settingLabelTag: currentSettings.settingLabelTag, settingButtonTag: currentSettings.settingButtonTag, settingAutoButtonTag: currentSettings.settingAutoButtonTag, settingLabelColor: currentSettings.settingLabelColor, settingIsAuto: currentSettings.settingIsAuto, settingHasInfo: currentSettings.settingHasInfo)
            return cell!
        } else if indexPath.row == 4 {
            standbyCell?.updatePrivacyStandbyCellWith(settingName:  NSLocalizedString("Privacy Standby", comment: ""), settingSwitchTag: 1000)
            return standbyCell!
        } else {
            let currentSettings = self.privacySettings[indexPath.row - 1]
            cell?.updateCellWith(settingName: currentSettings.settingName, settingIsOn: currentSettings.settingIsOn, settingLabelTag: currentSettings.settingLabelTag, settingButtonTag: currentSettings.settingButtonTag, settingAutoButtonTag: currentSettings.settingAutoButtonTag, settingLabelColor: currentSettings.settingLabelColor, settingIsAuto: currentSettings.settingIsAuto, settingHasInfo: currentSettings.settingHasInfo)
            return cell!
        }
        


        
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath , animated: true)
        if indexPath.row == 2 {
        let alertService = AlertService()
        let alertVC = alertService.alertWithOkAction(title: NSLocalizedString("Info header privacy for Microphone", comment: ""), body: NSLocalizedString("Info body privacy for Microphone", comment: ""), completion: {
                   alertService.removeBlurFromView(mainView: self.view)
               })
               alertService.addBlurToView(mainView: self.view)
            self.present(alertVC, animated: true)
        } else if indexPath.row == 3 {
            let alertService = AlertService()
            let alertVC = alertService.alertWithOkAction(title: NSLocalizedString("Info header privacy for camera", comment: ""), body: NSLocalizedString("Info body privacy for camera", comment: ""), completion: {
                       alertService.removeBlurFromView(mainView: self.view)
                   })
                   alertService.addBlurToView(mainView: self.view)
                self.present(alertVC, animated: true)
        } else if indexPath.row == 4 {
            let alertService = AlertService()
            let alertVC = alertService.alertWithOkAction(title: NSLocalizedString("Info header privacy for Standby", comment: ""), body: NSLocalizedString("Info body privacy for Standby", comment: ""), completion: {
                       alertService.removeBlurFromView(mainView: self.view)
                   })
                   alertService.addBlurToView(mainView: self.view)
                self.present(alertVC, animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privacySettings.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? PrivacyHeaderView
        header?.apply(text: NSLocalizedString("Auto setting", comment: ""))
        return header
    }
    
}

struct AccessBool {
    static var access : Bool?
}

