//
//  RegistroTableViewCell.swift
//  ProyectoAdrian
//
//  Created by Luis Garcia on 30/01/23.
//

import UIKit

class RegistroTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tiempo: UILabel!
    
    @IBOutlet weak var observaciones: UILabel!
    
    
    @IBOutlet weak var fecha: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
