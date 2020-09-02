

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    //MARK: - IBOutlets
    var mapView: MKMapView!
    
    //MARK: - Vars

    var allCountries: [Country] = []
    var selectedAnnotation: MKPointAnnotation?

    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()
        fetchCountryStatsFromCD()
    }
    

    private func setupMapView() {
        mapView = MKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.mapType = MKMapType.standard

        if let coordinate = mapView.userLocation.location?.coordinate{
            mapView.setCenter(coordinate, animated: true)
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
            self.setMapPins()
        } else {
            print("no countries in db")
        }
    }

    

    private func setMapPins() {
        
        for countryData in allCountries {
            
            let coordinate = CLLocationCoordinate2D(latitude: countryData.latitude, longitude: countryData.longitude)

            let title = countryData.country! + "\n Confirmed " + countryData.confirmed.formatNumber() + "\n Death " + countryData.deaths.formatNumber()

            let pin = MapPin(coordinate: coordinate, title: title, subtitle: "")

            mapView.addAnnotation(pin)
        }
    }

    private func countryFromSelectedPin(_ coordinate: CLLocationCoordinate2D?) {
        
        if coordinate != nil {
            for data in allCountries {
                if data.longitude == coordinate!.longitude && data.latitude == coordinate!.latitude {
                    showCountryData(data)
                    return
                }
            }
        }
    }
    
    private func showCountryData(_ countryData: Country) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "countryDetailView") as! CountryDetailViewController
        
        vc.country = countryData
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
}

extension MapViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        countryFromSelectedPin(view.annotation?.coordinate)
        
    }

    
}

