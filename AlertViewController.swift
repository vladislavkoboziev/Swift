//
//  AlertInfoButton.swift
//  Armor
//
//  Created by John on 2/6/20.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var bodyLabel: UILabel!
    
    @IBOutlet weak var actionButton: UIButton!
    
    var alertTitle = String()
    
    var alertBody = String()
    
    var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        titleLabel.font = FontBook.MontserratRegular.of(size: 18)
        bodyLabel.text = alertBody
        bodyLabel.font = FontBook.MontserratRegular.of(size: 16)
        bodyLabel.textColor = ColorBook.apgLightGray
        actionButton.setTitle(NSLocalizedString("Ok button label", comment: ""), for: .normal)
        actionButton.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        actionButton.setTitleColor(ColorBook.apgBlack, for: .normal)
    }
    
    @IBAction func didTapActionButton(_ sender: Any) {
        dismiss(animated: true)
        buttonAction?()
    }
    
}
