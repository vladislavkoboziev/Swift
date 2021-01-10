//
//  PrivacyStandbyCell.swift
//  Armor
//
//  Created by John on 28.05.2020.
//  Copyright © 2020 evolutn.io. All rights reserved.
//

import UIKit

protocol PrivacyStandbyCellDelegate: class {
    func privacyStandbyCell(cell: PrivacyStandbyCell, didTappped switchUI: UISwitch)
}

class PrivacyStandbyCell: UITableViewCell {
    
    let cellTitleLabel : UILabel = {
        let label = UILabel()
        label.textColor = ColorBook.apgLightGray
        label.font = FontBook.MontserratRegular.of(size: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let cellICharLabel: UILabel = {
        let label = UILabel()
        label.text = " \u{24D8}"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = ColorBook.apgLightGray
        
        label.sizeToFit()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    let cellSwitch = PrivacyStandbySwitch()
    
    var cellDelegate: PrivacyStandbyCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(cellTitleLabel)
        addSubview(cellICharLabel)
        addSubview(cellSwitch)
        
        cellSwitch.addTarget(self, action: #selector(PrivacyStandbyCell.cellSwitchAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            cellTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            cellTitleLabel.widthAnchor.constraint(equalTo: cellTitleLabel.widthAnchor),
            
            cellICharLabel.leadingAnchor.constraint(lessThanOrEqualTo: cellTitleLabel.trailingAnchor),
            cellICharLabel.heightAnchor.constraint(equalToConstant: 12.0),
            cellICharLabel.widthAnchor.constraint(equalToConstant: 12.0),
            cellICharLabel.bottomAnchor.constraint(equalTo: centerYAnchor, constant: -4.0),
            
            cellSwitch.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellSwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0)
        ])
    }
    
    @objc func cellSwitchAction(_ sender: UISwitch) {
        cellDelegate?.privacyStandbyCell(cell: self, didTappped: sender)
    }
    
    func updatePrivacyStandbyCellWith(settingName: String, settingSwitchTag: Int) {
        cellTitleLabel.text = settingName
        cellSwitch.tag = settingSwitchTag
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
