

import UIKit
import CoreData

class AllResultsViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var confirmedLabel: UILabel!
    @IBOutlet weak var deathLabel: UILabel!
    @IBOutlet weak var recoveredLabel: UILabel!
    @IBOutlet weak var recoveredPercentLabel: UILabel!
    @IBOutlet weak var deathPercentLabel: UILabel!
    @IBOutlet weak var criticalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var goButtonOutlet: UIButton!
    @IBOutlet weak var searchOptionsView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var cardBackgroundView1: UIView!
    @IBOutlet weak var cardBackgroundView2: UIView!
    @IBOutlet weak var cardBackgroundView3: UIView!
    @IBOutlet weak var cardBackgroundView4: UIView!
    @IBOutlet weak var cardBackgroundView6: UIView!
    
    
    //MARK: - Vars
    var allCountries: [Country] = []
    var filteredCountries: [Country] = []

    var sortPopupView: SortPopUpMenuController!
    var isSortPopUpVisible = false
    var isSearching = false
    
    var totalStats: [Total] = []
    var lastFetchDate: Date?

    let titleLabel: UILabel = {
        
        let title = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 15))
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        title.textColor = .white
            
            
        return title
    }()
    let subTitleLabel: UILabel = {
        
        let subTitle = UILabel(frame: CGRect(x: 0, y: 20, width: 140, height: 15))
        subTitle.textAlignment = .center
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subTitle.textColor = .white

        return subTitle
    }()

    
    //MARK: - View Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkForLastFetchDate()
        
        fetchTotalStatsFromCD()
        fetchCountryStatsFromCD()
        
        if shouldFetchNew() {
            fetchTotalDataFromAPI()
            fetchCountryDataFromAPI()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

                
        setupPopUpView()

        tableView.tableFooterView = UIView()
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        setupCustomTitleView()
        updateTitleLabels()
        roundViewEdges()
    }
    
    
    //MARK: - IBActions
    
    @IBAction func sortButtonPressed(_ sender: Any) {
        isSortPopUpVisible ? hideSortPopUpView() : showSortPopUpView()
        isSortPopUpVisible.toggle()
    }

    @IBAction func searchBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        showSearchField()
    }
    
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        
        if searchTextField.text != "" {
            isSearching = true
            updateLeftBarButtonItem()
            filteredContentForSearchText(searchText: searchTextField.text!)
            emptyTextField()
            animateSearchOptionsIn()
            dismissKeyboard()
        }

    }
    
    @objc func stopSearchButtonPressed(_ sender: Any) {
        
        isSearching = false
        updateLeftBarButtonItem()
        tableView.reloadData()
    }
    
    //MARK: - Fetch from CD
    private func fetchTotalStatsFromCD() {
        
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Total")
        fetchRequest.sortDescriptors = []
        

        do {
            self.totalStats = try context.fetch(fetchRequest) as! [Total]
            
        } catch {
            print("Failed to fetch total")
        }
        

        if totalStats.count > 0 {
            updateTotalValues(self.totalStats.first!)
        }
    }
    
    private func fetchCountryStatsFromCD() {
        
        let context = AppDelegate.context

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        fetchRequest.sortDescriptors = []
        

        do {
            self.allCountries = try context.fetch(fetchRequest) as! [Country]
            
        } catch {
            print("Failed to fetch country")
        }
        

        if allCountries.count > 0 {
            sortData()
            tableView.reloadData()
        } else {
            print("no countries in db")
        }
    }


    
    //MARK: - FetchData From API
    
    private func fetchTotalDataFromAPI() {
        
        CovidFetchRequest().getCurrentTotal { (totalData) in
            
            if totalData != nil {
                
                var totalD: Total!
                
                if self.totalStats.count > 0 {

                    totalD = self.totalStats.first!
                } else {

                    let context = AppDelegate.context
                    totalD = Total(context: context)
                    
                }
                
                totalD.confirmed = totalData!.confirmed.formatNumber()
                totalD.critical = totalData!.critical.formatNumber()
                totalD.deaths = totalData!.deaths.formatNumber()
                totalD.recovered = totalData!.recovered.formatNumber()
                totalD.recoveredRate = totalData!.recoveredRate
                totalD.fatalityRate = totalData!.fatalityRate
                
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                
                self.updateTotalValues(totalD)
            }
            
        }
    }
    
    private func fetchCountryDataFromAPI() {
        
        CovidFetchRequest().getAllCountries { (_allCountries) in
            
            if _allCountries.count > 0 {
                
                self.deleteAllCountriesFromCD()
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }

            self.allCountries = _allCountries
            self.sortData()
        }
        
    }
    
    //MARK: - Setup

    private func setupCustomTitleView() {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        
        self.navigationItem.titleView = containerView
    }

    private func setupPopUpView() {
        
        sortPopupView = SortPopUpMenuController()
        sortPopupView.containerView.layer.cornerRadius = 20
        sortPopupView.delegate = self
        sortPopupView.frame = CGRect(x: 0, y: self.view.frame.height
            + 90, width: self.view.frame.width, height: 250)
                
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow!.addSubview(sortPopupView)
        
    }

    private func updateLeftBarButtonItem() {

        if isSearching {
             self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(stopSearchButtonPressed))
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func roundViewEdges() {
        cardBackgroundView.layer.cornerRadius = 8
        cardBackgroundView1.layer.cornerRadius = 8
        cardBackgroundView2.layer.cornerRadius = 8
        cardBackgroundView3.layer.cornerRadius = 8
        cardBackgroundView4.layer.cornerRadius = 8
        cardBackgroundView6.layer.cornerRadius = 8
    }
    
    //MARK: - Update UI
    
    private func updateTitleLabels() {
        
        titleLabel.text = "Recent Data"
        if lastFetchDate != nil {
            subTitleLabel.text = "Updated at " + lastFetchDate!.timeString()
        } else {
            subTitleLabel.text = "Updated at " + Date().timeString()
        }
    }


    private func updateTotalValues(_ totalData: Total) {
        
            confirmedLabel.text = totalData.confirmed
            criticalLabel.text = totalData.critical

            deathLabel.text = totalData.deaths
            deathPercentLabel.text = String(format: "%.2f", totalData.fatalityRate)
            
            recoveredLabel.text = totalData.recovered
            recoveredPercentLabel.text = String(format: "%.2f", totalData.recoveredRate)
    }
    
    private func sortData(sortBy: String = "") {
        
        switch sortBy {
        case "recovered":
            self.allCountries = allCountries.sorted(by: { $0.recovered > $1.recovered })

        case "death":
            self.allCountries = allCountries.sorted(by: { $0.deaths > $1.deaths })
        case "recoveryRate":
            self.allCountries = allCountries.sorted(by: { $0.recoveryRate > $1.recoveryRate })

        case "deathRate":
            self.allCountries = allCountries.sorted(by: { $0.fatalityRate > $1.fatalityRate })

        default:
            self.allCountries = allCountries.sorted(by: { $0.confirmed > $1.confirmed })
        }

        self.tableView.reloadData()

    }
    
    //MARK: - Helpers
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }

    private func emptyTextField() {
        searchTextField.text = ""
    }

    private func disableSearchButton() {
        goButtonOutlet.isEnabled = false
        goButtonOutlet.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    
    private func showSearchField() {
        disableSearchButton()
        emptyTextField()
        animateSearchOptionsIn()
    }

    @objc func textFieldDidChange (_ textField: UITextField) {
        
        goButtonOutlet.isEnabled = textField.text != ""
        
        if goButtonOutlet.isEnabled {
            goButtonOutlet.backgroundColor = UIColor.clear
        } else {
            disableSearchButton()
        }
        
    }
    
    private func deleteAllCountriesFromCD() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Country")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try AppDelegate.context.execute(deleteRequest)
            
        } catch let error as NSError {
            print("error, couldn't empty countries ", error)
        }

    }

    private func shouldFetchNew() -> Bool {
        
        if allCountries.count == 0 || lastFetchDate == nil {
            return true
        } else {
            if let timePass = Calendar.current.dateComponents([.hour], from: lastFetchDate!, to: Date()).hour, timePass > 5 {
                UserDefaults.standard.set(Date(), forKey: kLASTFETCHTIME)
                updateTitleLabels()
                return true
            } else {
                return false
            }
        }
    }

    
    //MARK: - Animations
    
    func showSortPopUpView() {
        UIView.animate(withDuration: 0.3) {
            self.sortPopupView.frame.origin.y = AnimationManager.screenBounds.maxY - (self.sortPopupView.frame.height - 20)
        }

    }
    
    func hideSortPopUpView() {
        UIView.animate(withDuration: 0.3) {
            self.sortPopupView.frame.origin.y = AnimationManager.screenBounds.maxY + 1
        }

    }
    
    private func animateSearchOptionsIn() {
        
        UIView.animate(withDuration: 0.5) {
            self.searchOptionsView.isHidden = !self.searchOptionsView.isHidden
        }
    }


    //MARK: - Search
     
     func filteredContentForSearchText(searchText: String) {
         
         filteredCountries = allCountries.filter({ (country) -> Bool in
             
             return country.country!.lowercased().contains(searchText.lowercased())
         })
         
         tableView.reloadData()
     }
    
    //MARK: - UserDefaults
    private func checkForLastFetchDate() {
        
        lastFetchDate = UserDefaults.standard.object(forKey: kLASTFETCHTIME) as? Date
        
        if lastFetchDate == nil {
            UserDefaults.standard.set(Date(), forKey: kLASTFETCHTIME)
            UserDefaults.standard.synchronize()
        }
    }


}

extension AllResultsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return isSearching ? filteredCountries.count : allCountries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CountryTableViewCell
        
        let countryData = isSearching ? filteredCountries[indexPath.row] : allCountries[indexPath.row]
        cell.setupCell(countryData)
        
        return cell
    }

    
    
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "countryDetailView") as! CountryDetailViewController
        
        vc.country = isSearching ? filteredCountries[indexPath.row] : allCountries[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }


}


extension AllResultsViewController : SortPopupMenuControllerDelegate {
    
    func deathRateButtonPressed() {
        sortData(sortBy: "deathRate")
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    func recoveryRateButtonPressed() {
        sortData(sortBy: "recoveryRate")
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    
    func recoveredButtonPressed() {
        sortData(sortBy: "recovered")
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    func confirmedButtonPressed() {
        sortData()
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    func deathButtonPressed() {
        sortData(sortBy: "death")
        hideSortPopUpView()
        isSortPopUpVisible.toggle()

    }
    
    func sortBackgroundTapped() {
        hideSortPopUpView()
        isSortPopUpVisible.toggle()
    }
    
    
}
