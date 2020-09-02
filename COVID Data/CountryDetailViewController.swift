

import UIKit

class CountryDetailViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Vars
    var country: Country?

    
    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(self.backAction))

        cardBackgroundView.layer.cornerRadius = 8
        if country != nil {
            presentCountryData()
        }
    }
    
    //MARK: - UpdateUI
    private func presentCountryData() {
        
        self.navigationItem.title = country!.country
        
        
    }

    //MARK: - Actions
    @objc func backAction() {
        self.navigationController?.popToRootViewController(animated: true)
    }


}


extension CountryDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return country != nil ? 6 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryDetailTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.setupCell("Confirmed", _subTitle: country!.confirmed.formatNumber(), _color: .label)
        case 1:
            cell.setupCell("Critical", _subTitle: country!.critical.formatNumber(), _color: .systemOrange)
        case 2:
            cell.setupCell("Death", _subTitle: country!.deaths.formatNumber(), _color: .systemRed)
        case 3:
            cell.setupCell("Death %", _subTitle: String(format: "%.2f", country!.fatalityRate) + "%", _color: .systemRed)
        case 4:
            cell.setupCell("Recovered", _subTitle: country!.recovered.formatNumber(), _color: .systemGreen)
        default:
            cell.setupCell("Recovered %", _subTitle: String(format: "%.2f", country!.recoveryRate) + "%", _color: .systemGreen)
        }
        
        return cell
    }
    
    
    
}
