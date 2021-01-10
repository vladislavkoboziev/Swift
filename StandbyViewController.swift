//
//  StandbyViewController.swift
//  Armor
//
//  Created by John on 28.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit
import LocalAuthentication

class StandbyViewController: UIViewController {
    
    lazy var topButton : UIButton = {
        let button = BackToAppButton()
        button.addTarget(self, action: #selector(StandbyViewController.topButtonIsClicked(sender:)), for: .touchUpInside)
        return button
    }()
    
    lazy var centerImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "lock.png")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorBook.apgBlack
        
        view.addSubview(topButton)
        view.addSubview(centerImageView)
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkPasscode()
    }
    
    func authenticateUser() {
        let context = LAContext()
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthentication, localizedReason: "Please authenticate to proceed.") { [weak self] (success, error) in
            guard success else {
                DispatchQueue.main.async {
                    self?.authenticateUser()
                }
                return
            }
            DispatchQueue.main.async {
                self?.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    fileprivate func checkPasscode() {
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) {
            return
        } else {
            let alertService = AlertService()
            let alertVC = alertService.alertWithOkAction(title: NSLocalizedString("Check passcode alert title", comment: ""), body: NSLocalizedString("Check passcode alert body", comment: "")) {
                self.dismiss(animated: true, completion: nil)
                alertService.removeBlurFromView(mainView: self.view)
                self.openPhoneSettings()
            }
            alertService.addBlurToView(mainView: self.view)
            present(alertVC, animated: true)
        }
    }
    
    func openPhoneSettings() {
        if let url = URL(string:UIApplication.openSettingsURLString)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func setupConstraints() {
        topButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100.0).isActive = true
        topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0).isActive = true
        topButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        topButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        centerImageView.topAnchor.constraint(equalTo: topButton.bottomAnchor, constant: 75.0).isActive = true
        centerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        centerImageView.heightAnchor.constraint(equalToConstant: 268.0).isActive = true
        centerImageView.widthAnchor.constraint(equalToConstant: 300.0).isActive = true
    }
    
    @objc func topButtonIsClicked(sender: UIButton) {
        self.authenticateUser()
    }
    
}
