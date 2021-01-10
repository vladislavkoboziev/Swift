//
//  InfoButtonAlertView.swift
//  Armor
//
//  Created by John on 2/6/20.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class AlertService: UIView {
    
    func alert(title: String, body: String) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        
        alertVC.alertBody = body
        
        return alertVC
    }
    
    func alertWithOkAction(title: String, body: String, completion: @escaping () -> Void) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "AlertStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        
        alertVC.alertBody = body
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertWithCancel(title: String, body: String, completion: @escaping () -> Void) -> AlertWithCancelViewController {
        
        let storyboard = UIStoryboard(name: "AlertWithCancelStoryboard", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertWithCancelVC") as! AlertWithCancelViewController
        
        alertVC.alertTitle = title
        
        alertVC.alertBody = body
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func tutorialAlert(title: String, body: String, imageName: String, completion: @escaping () -> Void) -> TutorialAlertViewController {
        
        let storyboard = UIStoryboard(name: "TutorialAlert", bundle: .main)
        
        let alertVC = storyboard.instantiateViewController(withIdentifier: "TutorialAlert") as! TutorialAlertViewController
        
        alertVC.alertTitle = title
        
        alertVC.alertBody = body
        
        alertVC.buttonAction = completion
        
        alertVC.imageName = imageName
        
        return alertVC
    }
    
    func addBlurToView(mainView: UIView) {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.alpha = 0.8
        visualEffectView.frame = mainView.frame
        
        mainView.addSubview(visualEffectView)
    }
    
    func removeBlurFromView(mainView: UIView) {
        for subview in mainView.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
}
