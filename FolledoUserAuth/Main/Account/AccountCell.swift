//
//  AccountCell.swift
//  FolledoUserAuth
//
//  Created by Macbook Pro 15 on 10/14/19.
//  Copyright © 2019 SamuelFolledo. All rights reserved.
//

import UIKit

struct CellData {
    let cellImage: UIImage?
    let cellTitle: String?
}

class AccountCell: UITableViewCell {
    var cellTitle: String?
    var cellImage: UIImage?
    
    var cellTitleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    var cellImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.rounded()
        return imageView
    }()
    
//initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(cellImageView)
        self.addSubview(cellTitleLabel)
        cellImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        cellImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        cellImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        cellImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        cellImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        cellTitleLabel.leftAnchor.constraint(equalTo: self.cellImageView.rightAnchor, constant: 10).isActive = true
        cellTitleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cellTitleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 5).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() { //now we add information into them, but u cant do it in the initializer because those information are not initially provided, it is added after initialization
        super.layoutSubviews()
        if let cellTitle = cellTitle { //unwrap first
            cellTitleLabel.text = cellTitle
        }
        if let image = cellImage {
            cellImageView.image = image
        }
    } //now that we have this, it is time to put it in our table view. First register it with ur table view cell, so it has an identifier (reuseIdentifier) so we can reuse it over and over again
}
