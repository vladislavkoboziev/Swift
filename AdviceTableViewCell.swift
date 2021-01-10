//
//  AdviceTableViewCell.swift
//  Armor
//
//  Created by John on 1/13/20.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AdviceTableViewCell: UITableViewCell {
    
    var adviceWebView : WKWebView = {
        var webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.backgroundColor = ColorBook.apgGray
        webView.clipsToBounds = true
        webView.layer.cornerRadius = 15.0
        webView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        webView.isOpaque = false
        return webView
    }()
    
    var bottomView : UIView = {
        var bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .clear
        return bottomView
    }()
    
    let headerBottomView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgBlack
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
    
    var headerView : UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgGray
        
        view.clipsToBounds = true
        view.layer.cornerRadius = 15.0
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        self.addSubview(headerView)
        self.addSubview(headerBottomView)
        headerView.addSubview(headerLabel)
        self.addSubview(adviceWebView)
        self.addSubview(bottomView)
        
        setupLayouts()
    }
    
    func labelText(text: String) {
        headerLabel.text = text
    }
    
    func setupLayouts() {
        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        headerBottomView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        headerBottomView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerBottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerBottomView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16.0).isActive = true
        headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16.0).isActive = true
        headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        
        adviceWebView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        adviceWebView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        adviceWebView.topAnchor.constraint(equalTo: headerBottomView.bottomAnchor).isActive = true
        
        bottomView.topAnchor.constraint(equalTo: adviceWebView.bottomAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

