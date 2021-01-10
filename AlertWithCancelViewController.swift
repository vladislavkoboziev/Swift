//
//  AlertWithCancelViewController.swift
//  Armor
//
//  Created by John on 2/7/20.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class AlertWithCancelViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var alertTitle = String()
    
    var alertBody = String()
    
    var buttonAction: (() -> Void)?
    
    var cancelButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        cancelButton.layer.borderWidth = 2.0
        cancelButton.layer.borderColor = ColorBook.apgGreen.cgColor
        
        titleLabel.text = alertTitle
        titleLabel.font = FontBook.MontserratRegular.of(size: 18)
        bodyLabel.text = alertBody
        bodyLabel.font = FontBook.MontserratRegular.of(size: 16)
        bodyLabel.textColor = ColorBook.apgLightGray
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        dismiss(animated: true)
        buttonAction?()
    }
    
    @IBAction func didTapCancelButton(_ sender: Any) {
        dismiss(animated: true)
        cancelButtonAction?()
    }
    
}
