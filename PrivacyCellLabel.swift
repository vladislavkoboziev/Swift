//
//  PrivacyCellLabel.swift
//  Armor
//
//  Created by John on 08.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class PrivacyCellLabel : UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    func setupParameters(labelIsOn: Bool, labelTextColor: UIColor, labelTag: Int) {
        self.tag = labelTag
        if labelIsOn == true {
            self.text = "on"
            self.textColor = ColorBook.apgGreen
        } else {
            self.text = "off"
            self.textColor = labelTextColor
        }
    }
    
    func setupView() {
        self.font = FontBook.MontserratRegular.of(size: 16)
        self.isUserInteractionEnabled = true
       
        self.textAlignment = .center
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
}
