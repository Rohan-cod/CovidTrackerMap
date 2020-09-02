

import Foundation

struct TotalData {
    
    let confirmed: Int
    let deaths: Int
    let critical: Int
    let recovered: Int
    
    var fatalityRate: Double {
        return (100.00 * Double(deaths)) / Double(confirmed)
    }
    
    var recoveredRate: Double {
        return (100.00 * Double(recovered)) / Double(confirmed)
    }
}


struct WHOAdvice: Decodable, Identifiable {
    
    let id = UUID()
    
    let title: String
    let subtitle: String
    let basics: [WHOData]
    let topics: [WHOTopic]
    
}

struct WHOTopic: Decodable, Identifiable {
    
    let id = UUID()
    
    let title: String
    let questions: [WHOData]
}


struct WHOData: Decodable, Identifiable {
    
    let id = UUID()
    
    let title: String
    let subtitle: String
}



//
//struct CountryData {
//    
//    let country: String
//    let longitude: Double
//    let latitude: Double
//    let confirmed: Int
//    let deaths: Int
//    let critical: Int
//    let recovered: Int
//    
//    var fatalityRate: Double {
//        return (100.00 * Double(deaths)) / Double(confirmed)
//    }
//    
//    var recoveredRate: Double {
//        return (100.00 * Double(recovered)) / Double(confirmed)
//    }
//}
