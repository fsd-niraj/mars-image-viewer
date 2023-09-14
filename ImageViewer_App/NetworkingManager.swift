import Foundation

class NetworkingManager: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
    
    func fetchNASAImages(for rover: String, on date: String, completion: @escaping ([ImageModel]?, Error?) -> Void) {
        let apiUrlString = "https://api.nasa.gov/mars-photos/api/v1/rovers/\(rover)/photos?earth_date=\(date)&api_key=\(apiKey)"
        
        guard let apiUrl = URL(string: apiUrlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: apiUrl) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                
                guard let photosData = jsonResponse?["photos"] as? [[String: Any]] else {
                    completion(nil, NSError(domain: "Invalid response data", code: 0, userInfo: nil))
                    return
                }
                
                var nasaImages: [ImageModel] = []
//                let imageData = photosData.first;
////                print("Photos data: ", photosData)
//                if let rover = imageData?["rover"] as? [String: Any],
//                   let roverName = rover["name"] as? String,
//                   let date = imageData?["earth_date"] as? String,
//                   let imageUrlString = imageData!["img_src"] as? String {
//
//                    let nasaImage = ImageModel(title: roverName + "-" + date, imageUrl: imageUrlString)
//                    nasaImages.append(nasaImage)
//                }
                for imageData in photosData {
                    if let title = imageData["camera"] as? [String: Any],
                       let cameraName = title["name"] as? String,
                       let rover = imageData["rover"] as? [String: Any],
                       let roverName = rover["name"] as? String,
                       let imageUrlString = imageData["img_src"] as? String,
                       let imageUrl = URL(string: imageUrlString) {
                        let nasaImage = ImageModel(title: cameraName, imageUrl: imageUrlString)
                        nasaImages.append(nasaImage)
                    }
                }
//                nasaImages.first(where: {$0.imgTitle == })
//                let newImage = ImageModel(title: <#T##String#>, imageUrl: <#T##String#>)
//                imageList.append(<#T##newElement: ImageModel##ImageModel#>)
                
                completion(nasaImages, nil)
                
            } catch {
                completion(nil, error)
            }
        }
        
        print(rover, date)
        
        task.resume()
    }
    
    
//    func fetchFromUrl(from url: String, completion: @escaping ([ImageModel]?, Error?) -> Void) {
//        let sessionConfiguration = URLSessionConfiguration.default
//        let newSession = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
//        
//        let task = newSession.dataTask(with: url) { (data, response, error) in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                completion(nil, NSError(domain: "Invalid response", code: 0, userInfo: nil))
//                return
//            }
//            
//            guard let data = data else {
//                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
//                return
//            }
//            
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                
//                guard let photosData = jsonResponse?["photos"] as? [[String: Any]] else {
//                    completion(nil, NSError(domain: "Invalid response data", code: 0, userInfo: nil))
//                    return
//                }
//                
//                var nasaImages: [ImageModel] = []
//                for imageData in photosData {
//                    if let title = imageData["camera"] as? [String: Any],
//                       let cameraName = title["name"] as? String,
//                       let imageUrlString = imageData["img_src"] as? String,
//                       let imageUrl = URL(string: imageUrlString) {
//                        let nasaImage = ImageModel(title: cameraName, imageUrl: imageUrlString)
//                        nasaImages.append(nasaImage)
//                    }
//                }
//                
//                completion(nasaImages, nil)
//                
//            } catch {
//                completion(nil, error)
//            }
//        }
//    }
}
    
