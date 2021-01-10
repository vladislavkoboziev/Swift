//
//  PrivacyHeaderView.swift
//  Armor
//
//  Created by John on 17.04.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

class PrivacyHeaderView: UITableViewHeaderFooterView {
    
    let bottomView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgBlack
        return view
    }()
    
    let clearView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let customBackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgGray
        return view
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorBook.apgGreen
        label.font = FontBook.MontserratRegular.of(size: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.addSubview(customBackgroundView)
        customBackgroundView.addSubview(headerLabel)
        customBackgroundView.addSubview(clearView)
        customBackgroundView.addSubview(bottomView)
        
        setupLayouts()
    }
    
    func apply(text: String) {
        headerLabel.text = text
    }
    
    func setupLayouts() {
        bottomView.topAnchor.constraint(equalTo: customBackgroundView.bottomAnchor, constant: -1.0).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        clearView.leadingAnchor.constraint(equalTo: customBackgroundView.leadingAnchor).isActive = true
        clearView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        clearView.topAnchor.constraint(equalTo: customBackgroundView.topAnchor).isActive = true
        clearView.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor).isActive = true
        
        customBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        customBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        customBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        customBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        headerLabel.leadingAnchor.constraint(equalTo: customBackgroundView.leadingAnchor, constant: 16.0).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: customBackgroundView.trailingAnchor, constant: -16.0).isActive = true
        headerLabel.topAnchor.constraint(equalTo: customBackgroundView.topAnchor).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: customBackgroundView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
