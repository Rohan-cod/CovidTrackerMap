

import UIKit

class CountryDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupCell(_ title: String, _subTitle: String, _color: UIColor) {
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.9

        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.textColor = _color
        
        subtitleLabel.text = _subTitle
        titleLabel.text = title
    }


}
