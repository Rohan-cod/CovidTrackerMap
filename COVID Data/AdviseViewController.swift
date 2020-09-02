

import UIKit

class AdviseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    load()
        
    }
    

    func load() {
        let url = Bundle.main.url(forResource: "who_corona_advice", withExtension: "json")!
        
        loadModelFromJSON(url: url) { (result: Result<WHOAdvice, Error>) in
            if case let .success(res) = result {
                print("...", res.topics)
            }
        }
    }
    
    func loadModelFromJSON<D: Decodable>(url: URL, completion: (Result<D, Error>) -> ()) {
           guard let data = try? Data(contentsOf: url) else {
               completion(.failure(NSError(domain: "", code: 32)))
               return
           }

           let jsonDecoder = JSONDecoder()
           jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

           do {
               let model = try jsonDecoder.decode(D.self, from: data)
               completion(.success(model))
           } catch {
               print(error)
               print(error.localizedDescription)
               completion(.failure(error))
           }
       }

}
