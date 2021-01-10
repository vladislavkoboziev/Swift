//
//  ViewController.swift
//  Armor
//
//  Created by John on 11/5/19.
//  Copyright © 2019 evolutn.io. All rights reserved.
//

import UIKit
import CoreData
import SwiftyGif
import MaterialShowcase

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    let mainGrayColor = ColorBook.apgLightGray

    let backGroundColor = ColorBook.apgBlack
    
    let primaryColor = ColorBook.apgGreen
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.0, 1.0, 1.0, 1.0]
        bounceAnimation.duration = TimeInterval(0.1)
        bounceAnimation.calculationMode = .cubic
        return bounceAnimation
    }()
    
    var privacyViewController: PrivacyViewController!
    var alertsViewController: AlertsViewController!
    var breachesViewController: BreachesViewController!
    var feedbackViewController: FeedbackViewController!
    var tutorialStep = 1
    let sequence = MaterialShowcaseSequence()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Thread.sleep(forTimeInterval: 1.0)

        privacyViewController = PrivacyViewController()
        alertsViewController = AlertsViewController()
        breachesViewController = BreachesViewController()
        feedbackViewController = FeedbackViewController()
        
        self.delegate = self
        
        privacyViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Privacy title", comment: ""), image: UIImage(named: "privacy_icon"), selectedImage: UIImage(named: "privacy_icon_large"))
        
        alertsViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Alerts title", comment: ""), image: UIImage(named: "alerts_icon"), selectedImage: UIImage(named: "alerts_icon_large"))
        
        breachesViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Breaches title", comment: ""), image: UIImage(named: "breaches_icon"), selectedImage: UIImage(named: "breaches_icon_large"))
        
        feedbackViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("Feedback title", comment: ""), image: UIImage(named: "feedback_icon"), selectedImage: UIImage(named: "feedback_icon_large"))
        
        self.tabBar.unselectedItemTintColor = mainGrayColor
        self.tabBar.tintColor = primaryColor
        self.tabBar.backgroundColor = backGroundColor
        self.tabBar.barTintColor = backGroundColor
        
        viewControllers = [privacyViewController, alertsViewController, breachesViewController, feedbackViewController]
        
        self.selectedIndex = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appearance = UITabBarItem.appearance(whenContainedInInstancesOf: [ViewController.self])
        appearance.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: mainGrayColor,
            NSAttributedString.Key.font : FontBook.MontserratRegular.of(size: 12)
                as Any], for: .normal)
        appearance.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: primaryColor,
            NSAttributedString.Key.font : FontBook.MontserratRegular.of(size: 12)
                as Any], for: .selected)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        
        let firstLaunchedKey = "MainViewFirstLaunche"
        let defaults = UserDefaults.standard
        let hasLaunched = defaults.bool(forKey: firstLaunchedKey)
        
        if !hasLaunched {
            mainViewTutorials()
            defaults.set(true, forKey: firstLaunchedKey)
        }
    }
    
    func mainViewTutorials() {
        let showcasePrivacy = MaterialShowcase()
        showcasePrivacy.setTargetView(tabBar: tabBar, itemIndex: 0, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcasePrivacy)
        showcasePrivacy.primaryText = NSLocalizedString("Primary text Privacy", comment: "")
        showcasePrivacy.secondaryText = NSLocalizedString("Description tutorials privacy", comment: "")
        
        let showcaseAlerts = MaterialShowcase()
        showcaseAlerts.setTargetView(tabBar: tabBar, itemIndex: 1, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseAlerts)
        showcaseAlerts.primaryText = NSLocalizedString("Primary text Alerts", comment: "")
        showcaseAlerts.secondaryText = NSLocalizedString("Description tutorials alerts", comment: "")
        
        let showcaseBreaches = MaterialShowcase()
        showcaseBreaches.setTargetView(tabBar: tabBar, itemIndex: 2, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseBreaches)
        showcaseBreaches.primaryText = NSLocalizedString("Primary text Breaches", comment: "")
        showcaseBreaches.secondaryText = NSLocalizedString("Description tutorials breaches", comment: "")

        
        let showcaseFeedback = MaterialShowcase()
        showcaseFeedback.setTargetView(tabBar: tabBar, itemIndex: 3, tapThrough: false)
        setupMaterialShowcaseParameters(showcase: showcaseFeedback)
        showcaseFeedback.primaryText = NSLocalizedString("Primary text Feedback", comment: "")
        showcaseFeedback.secondaryText = NSLocalizedString("Description tutorials feedback", comment: "")
        
        showcasePrivacy.delegate = self
        showcaseAlerts.delegate = self
        showcaseBreaches.delegate = self
        showcaseFeedback.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.sequence.temp(showcasePrivacy).temp(showcaseAlerts).temp(showcaseBreaches).temp(showcaseFeedback).start()
        })
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
        showcase.primaryTextFont = UIFont.systemFont(ofSize: 18)
        showcase.isTapRecognizerForTargetView = false
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if (viewController.title == "Breaches") == true {
            let breachedEmailViewController = BreachesViewController()
            breachedEmailViewController.viewWillAppear(true)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController.isKind(of: AlertsViewController.self) {
            alertsViewController.viewWillAppear(true)
            alertsViewController.deleteBadgeInTabBarItem()
        }
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1,
            let imageView = tabBar.subviews[idx + 1].subviews.first as? UIImageView else {
                return
        }
        imageView.layer.add(bounceAnimation, forKey: nil)
    }
    
}

extension ViewController: SwiftyGifDelegate {
    
    func gifDidStop(sender: UIImageView) {

    }
    
}

extension ViewController: MaterialShowcaseDelegate {
    func showCaseDidDismiss(showcase: MaterialShowcase, didTapTarget: Bool) {
        sequence.showCaseWillDismis()
    }
}
