//
//  TSHeaderView.swift
//  AppVerifyDemo
//
//  Created by Plivo on 6/18/18.
//  Copyright © 2018 Plivo. All rights reserved.
//

import UIKit

/**
    A consistent header view with logo and title for the sample app.
 */
class HeaderView: UIView {
    
    let properties : Properties
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    lazy var logoImageView: UIImageView = {
        let logo = UIImageView()
        logo.image = properties.logo
        logo.contentMode = .scaleAspectFit
        return logo
    }()
    
    init(properties: Properties,title : String) {
        self.properties = properties
        super.init(frame: .zero)
        
        self.titleLabel.text = title
        self.titleLabel.font = properties.titleFont
        self.titleLabel.textColor = properties.titleColor

        applyStyling()
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyStyling() {
        backgroundColor = .clear
    }
    
    private func setupSubviews() {
        [logoImageView, titleLabel].forEach(self.addSubview)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
        logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
        logoImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1, constant: 0),
        logoImageView.heightAnchor.constraint(equalToConstant: self.properties.logoHeight)
            ])
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
        titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor,constant : 10),
        titleLabel.widthAnchor.constraint(equalToConstant: 250),
        titleLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
}
