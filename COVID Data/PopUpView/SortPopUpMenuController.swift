

import UIKit

protocol SortPopupMenuControllerDelegate {
    
    func recoveredButtonPressed()
    func confirmedButtonPressed()
    func deathButtonPressed()
    func deathRateButtonPressed()
    func recoveryRateButtonPressed()

    func sortBackgroundTapped()

}

class SortPopUpMenuController: UIView {
    
    //MARK: - IBOutlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var handelBarView: UIView!
    
    
    //MARK: - Vars
    var delegate: SortPopupMenuControllerDelegate?

    //MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("SortPopUp", owner: self, options: nil)
        containerView.fixInView(self)
        handelBarView.layer.cornerRadius = 3
        
        //background
        let backgroundTap = UITapGestureRecognizer()
        backgroundTap.addTarget(self, action: #selector(self.backgroundTap))
        
        containerView.addGestureRecognizer(backgroundTap)
        containerView.isUserInteractionEnabled = true
        
    }
    
    
    //MARK: - IBActions
    @objc private func backgroundTap() {
        delegate?.sortBackgroundTapped()
    }
    
    
    @IBAction func confirmedPressed(_ sender: Any) {

        delegate?.confirmedButtonPressed()
    }
    
    @IBAction func deathPressed(_ sender: Any) {

        delegate?.deathButtonPressed()
    }
    
    @IBAction func recoveredPressed(_ sender: Any) {
        
        delegate?.recoveredButtonPressed()
    }
    
    @IBAction func deathRatePressed(_ sender: Any) {
        delegate?.deathRateButtonPressed()
    }
    
    
    @IBAction func recoveryRatePressed(_ sender: Any) {
        delegate?.recoveryRateButtonPressed()
    }
    
}


