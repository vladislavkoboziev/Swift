//
//  InfoButtonAnimationViewController.swift
//  Armor
//
//  Created by John on 12.06.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit
//import SwiftyGif

class InfoButtonAnimationViewController: UIViewController {
    
    var okAction : (() -> Void)?
    var startTutorialAction : (() -> Void)?
    
    let infoOkButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15.0
        button.layer.borderWidth = 1.0
        button.layer.borderColor = ColorBook.apgGreen.cgColor
        button.setTitle(NSLocalizedString("Ok button label", comment: ""), for: .normal)
        button.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        button.setTitleColor(ColorBook.apgGreen, for: .normal)
        button.addTarget(self, action: #selector(handleOkButton), for: .touchUpInside)
        return button
    }()
    
    let infoBottomImageView : UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setImage(UIImage(named: "armorchik.png")!)
        return imageView
    }()
    
    let infoStartTutorialButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = ColorBook.apgGreen
        button.layer.cornerRadius = 15.0
        button.setTitle(NSLocalizedString("Start tutorial button label", comment: ""), for: .normal)
        button.titleLabel?.font = FontBook.MontserratRegular.of(size: 16)
        button.setTitleColor(ColorBook.apgBlack, for: .normal)
        button.addTarget(self, action: #selector(handleStartTutorialButton), for: .touchUpInside)
        return button
    }()
    
    let infoTopView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgGray
        view.layer.cornerRadius = 15.0
        return view
    }()
    
    let topInfoBodyLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.contentMode = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.textColor = ColorBook.apgLightGray
        return label
    }()
    
    let topInfoHeaderLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontBook.MontserratRegular.of(size: 18)
        label.textColor = ColorBook.apgGreen
        return label
    }()
    
    let topLineView : UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = ColorBook.apgBlack
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = ColorBook.apgBlack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.addSubview(infoTopView)
        infoTopView.addSubview(topLineView)
        infoTopView.addSubview(topInfoHeaderLabel)
        infoTopView.addSubview(topInfoBodyLabel)
        infoTopView.addSubview(infoOkButton)
        infoTopView.addSubview(infoStartTutorialButton)
        
        view.addSubview(infoBottomImageView)
        
        setupConstraints()
    }
    
    @objc func handleOkButton() {
        okAction?()
    }
    
    @objc func handleStartTutorialButton() {
        startTutorialAction?()
    }
    
    private func setupConstraints() {
        infoTopView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 10.0).isActive = true
        infoTopView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0).isActive = true
        infoTopView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0).isActive = true
        
        topLineView.topAnchor.constraint(equalTo: infoTopView.topAnchor, constant: 60.0).isActive = true
        topLineView.leadingAnchor.constraint(equalTo: infoTopView.leadingAnchor).isActive = true
        topLineView.trailingAnchor.constraint(equalTo: infoTopView.trailingAnchor).isActive = true
        topLineView.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        
        topInfoHeaderLabel.topAnchor.constraint(equalTo: infoTopView.topAnchor).isActive = true
        topInfoHeaderLabel.leadingAnchor.constraint(equalTo: infoTopView.leadingAnchor, constant: 10.0).isActive = true
        topInfoHeaderLabel.trailingAnchor.constraint(equalTo: infoTopView.trailingAnchor, constant: -10.0).isActive = true
        topInfoHeaderLabel.bottomAnchor.constraint(equalTo: topLineView.bottomAnchor).isActive = true
        
        topInfoBodyLabel.topAnchor.constraint(equalTo: infoTopView.topAnchor, constant: 81.0).isActive = true
        topInfoBodyLabel.leadingAnchor.constraint(equalTo: infoTopView.leadingAnchor, constant: 10.0).isActive = true
        topInfoBodyLabel.trailingAnchor.constraint(equalTo: infoTopView.trailingAnchor, constant: -10.0).isActive = true
        topInfoBodyLabel.bottomAnchor.constraint(equalTo: infoStartTutorialButton.topAnchor, constant: -20.0).isActive = true
        
        infoOkButton.bottomAnchor.constraint(equalTo: infoTopView.bottomAnchor, constant: -10.0).isActive = true
        infoOkButton.leadingAnchor.constraint(equalTo: infoTopView.leadingAnchor, constant: 10.0).isActive = true
        infoOkButton.trailingAnchor.constraint(equalTo: infoTopView.centerXAnchor, constant: -10.0).isActive = true
        infoOkButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        
        infoStartTutorialButton.bottomAnchor.constraint(equalTo: infoTopView.bottomAnchor, constant: -10.0).isActive = true
        infoStartTutorialButton.trailingAnchor.constraint(equalTo: infoTopView.trailingAnchor, constant: -10.0).isActive = true
        infoStartTutorialButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        infoStartTutorialButton.leadingAnchor.constraint(equalTo: infoTopView.centerXAnchor, constant: 10.0).isActive = true
        
        infoBottomImageView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 30.0).isActive = true
        infoBottomImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoBottomImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        infoBottomImageView.heightAnchor.constraint(equalTo: infoBottomImageView.widthAnchor, multiplier: 1.84).isActive = true
    }
    
    func topInfoHeaderLabelText(text: String) {
        topInfoHeaderLabel.text = text
    }
    
    func topInfoBodyLabelText(text: String) {
        topInfoBodyLabel.text = text
    }
    
}
