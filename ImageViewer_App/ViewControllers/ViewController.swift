import UIKit
import FirebaseCore
import FirebaseFirestore

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var networkingManager = NetworkingManager()
    let db = Firestore.firestore();
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imagePicker: UIPickerView!
    @IBOutlet weak var noImageListText: UILabel!
    @IBOutlet weak var roverPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var photosCount: UILabel!
    
    var pickerViewData = imageList
    var roverData = ["Curiosity", "Opportunity", "Spirit"]
    var selectedRover = ""
    var selectedDate = ""
    var nasaImages: [ImageModel] = []
    var saveImageUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        self.imagePicker.delegate = self
        self.imagePicker.dataSource = self
        self.roverPicker.delegate = self
        self.roverPicker.dataSource = self
        imagePicker.reloadAllComponents()
        if let firstImageUrl = imageList.first?.imgUrl {
                loadImage(from: URL(string: firstImageUrl)!) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.imageView.image = image
                    }
                }
            }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == imagePicker{
            return imageList.count
        }else if pickerView == roverPicker{
            return roverData.count
        }else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == imagePicker{
            return imageList[row].imgTitle
        }else if pickerView == roverPicker{
            return roverData[row]
        }else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == imagePicker {
            if imageList.count > 0{
                photosCount.text = "Number of photos: \(imageList.count)"
                print("Image Document name: ", imageList[row].imgTitle);
                let documentName = imageList[row].imgTitle;
                let docRef = db.collection("mars").document(documentName);

                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let data = document.get("imageUrl").map(String.init(describing:)) ?? "nil"
                        print("Document data:", data)
                        let url = data;
                        self.loadImage(from: URL(string: data)!){ image in
                            DispatchQueue.main.async {
                                self.imageView.image = image
                            }
                        }

                    } else {
                        print("Document does not exist")
                    }
                }
                
                
                
//                let imgQue = DispatchQueue.init(label: "myQ")
//                imageView.image = nil
//                imgQue.async {
////                    if let urlObject = URL(string: imageList[row].imgUrl) {
////                        print("urlObj", urlObject.absoluteString)
////                        do {
////                            self.loadImage(from: urlObject.absoluteURL) { image in
////                                DispatchQueue.main.async {
////                                    self.imageView.image = image
////                                }
////                                print("success-", image as Any)
////                            }
////                        } catch {
////                            print("err here", error)
////                        }
////                    }
//                    let imageUrlString = imageList[row].imgUrl
//
//                    if let imageUrl = URL(string: imageUrlString) {
//                        imgQue.async {
//                            do {
//                                DispatchQueue.main.async {
//                                    self.loadImage(from: URL(string: imageUrlString)!){ image in
//                                        DispatchQueue.main.async {
//                                            self.imageView.image = image
//                                        }
//                                    }
//                                }
//                            } catch {
//                                print("Error loading image:", error)
//                            }
//                        }
//                    } else {
//                        print("Invalid image URL:", imageUrlString)
//                    }
//
//                }
                print("now viewing", row)
            }
        } else if pickerView == roverPicker {
            if roverData.count > 0 {
                selectedRover = roverData[row].lowercased()
                fetchImages()
            }
        }
    }
    
    func networkFinishedSuccess() {
        print("Img loaded success")
    }
    
    func networkFinishedError() {
        imageView.image = UIImage(named: "placeholder")
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDate = dateFormatter.string(from: sender.date)
        fetchImages()
    }
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error loading image: \(error)")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    func loadAndDisplayImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL:", urlString)
            return
        }

        loadImage(from: url) { image in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageView.image = image
                } else {
                    self.imageView.image = UIImage(named: "placeholder")
                }
            }
        }
    }

    
    func fetchImages() {
        networkingManager.fetchNASAImages(for: selectedRover, on: selectedDate) { [weak self] (images: [ImageModel]?, error: Error?) in
            if let error = error {
                print("Error fetching NASA images: \(error)")
                return
            }
            if let images = images {
                self?.nasaImages = images
                if let imageUrl = images.first?.imgUrl {
                    self?.saveImageUrl = imageUrl;
                    self?.loadImage(from: URL(string: imageUrl)!){ image in
                        DispatchQueue.main.async {
                            self?.imageView.image = image
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func saveImage(_ sender: Any) {
        
//        let url = URL(string: stringUrl)
        let imgName = selectedRover + "-" + selectedDate
        let imgUrl = self.saveImageUrl;
//        let stringUrl = nasaImages.first(where: {$0.imgTitle == imgName})?.imgUrl
//        print(imageList.first?.imgTitle)
//        print("Image name: ", stringUrl)
        db.collection("mars").document(imgName).setData([
            "imageUrl": imgUrl
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }

        
        imageList.append(ImageModel(title: imgName, imageUrl: imgUrl))
        imagePicker.reloadAllComponents()
        if(imageList.count > 0){
            noImageListText.isHidden = true
        }
    }
}
