

import UIKit

class CountryTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    func setupCell(_ countryData: Country) {
        countryLabel.adjustsFontSizeToFitWidth = true
        countryLabel.minimumScaleFactor = 0.7

        confirmedLabel.adjustsFontSizeToFitWidth = true
        deathLabel.adjustsFontSizeToFitWidth = true
        recoveredLabel.adjustsFontSizeToFitWidth = true
        
        countryLabel.text = countryData.country
        confirmedLabel.text = countryData.confirmed.formatNumber()
        deathLabel.text = countryData.deaths.formatNumber()
        recoveredLabel.text = countryData.recovered.formatNumber()
    }
    
}
