//
//  WithoutImageTableViewCell.swift
//  News
//
//  Created by Ankush Kumar Singh on 19/08/15.
//  Copyright (c) 2015 Citi. All rights reserved.
//

import UIKit

class WithoutImageTableViewCell: UITableViewCell {

    @IBOutlet weak var headLine: UILabel!

    @IBOutlet weak var date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
