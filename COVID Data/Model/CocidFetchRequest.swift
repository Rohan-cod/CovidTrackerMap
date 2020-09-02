

import Foundation
import Alamofire
import SwiftyJSON
import CoreData

class CovidFetchRequest {

    let headers: HTTPHeaders = [
        "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
        "x-rapidapi-key": "d172e810e7msh47584ae043c146dp12d8eejsnb0b3c42c4a59"
    ]

    func getCurrentTotal(completion: @escaping(_ totalData: TotalData?) -> Void) {
        
        AF.request("https://covid-19-data.p.rapidapi.com/totals?format=undefined", headers: headers).responseJSON { response in
            
            
            let result = response.data

            if result != nil {
                let json = JSON(result!)
//                print(json)
                
                let confirmed = json[0]["confirmed"].intValue
                let deaths = json[0]["deaths"].intValue
                let critical = json[0]["critical"].intValue
                let recovered = json[0]["recovered"].intValue

                completion(TotalData(confirmed: confirmed, deaths: deaths, critical: critical, recovered: recovered))

            } else {
                completion(nil)
                print("no result found")
            }
        }

    }

    
    
    func getAllCountries(completion: @escaping(_ allCountries: [Country]) -> Void) {
        
        AF.request("https://covid-19-data.p.rapidapi.com/country/all?format=undefined", headers: headers).responseJSON { response in

            let result = response.value
            var allCountries: [Country] = []

            if result != nil {
                
                let dataDictionary = result as! [Dictionary<String, AnyObject>]
                
                for countryData in dataDictionary {

                    let country = countryData["country"] as? String ?? "Error"
                    let longitude = countryData["longitude"] as? Double ?? 0.0
                    let latitude = countryData["latitude"] as? Double ?? 0.0

                    let confirmed = countryData["confirmed"] as? Int64 ?? 0
                    let deaths = countryData["deaths"] as? Int64 ?? 0
                    let critical = countryData["critical"] as? Int64 ?? 0
                    let recovered = countryData["recovered"] as? Int64 ?? 0
                    
                    
                    let countryObject = Country(context: AppDelegate.context)
                    countryObject.country = country
                    countryObject.longitude = longitude
                    countryObject.latitude = latitude
                    
                    countryObject.confirmed = confirmed
                    countryObject.deaths = deaths
                    countryObject.recovered = recovered
                    countryObject.critical = critical
                    countryObject.fatalityRate = (100.00 * Double(deaths)) / Double(confirmed)
                    countryObject.recoveryRate = (100.00 * Double(recovered)) / Double(confirmed)
                    
                    allCountries.append(countryObject)

                }
            }
            
            completion(allCountries)
        }
        
    }

//    func getDataFor(country: String, completion: @escaping(_ success: Bool)->Void) {
//        
//        let countryName = country.lowercased()
//        
//        AF.request("https://covid-19-data.p.rapidapi.com/country?format=undefined&name=\(countryName)", headers: headers).responseJSON { response in
//
//            let result = response.data
//
//            if result != nil {
//                let json = JSON(result!)
//                print(json)
//            }
//        }
//        
//    }
}


