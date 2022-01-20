//
//  AddItemTableViewController.swift
//  Declutter
//
//  Created by Chia on 2022/01/12.
//

import UIKit
import PhotosUI

class AddItemTableViewController: UITableViewController {
    
    var item: Item?
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var memoTextView: UITextView!
    
    let datePicker = UIDatePicker()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 點選螢幕任一處收鍵盤
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(AddItemTableViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        
        createDatePicker()
        updateUI()
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoAction = UIAlertAction(title: "ライブラリから選択する", style: .default) { action in
            self.selectPhoto()
        }
        let cameraAction = UIAlertAction(title: "カメラで撮影する", style: .default) { action in
            self.takePhoto()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUI() {
        if let item = item {
            nameTextField.text = item.name
            dateTextField.text = item.date
            memoTextView.text = item.memo
            
            // 讀取圖片
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageUrl = documentDirectory.appendingPathComponent("\(item.imageName).jpg")
            itemImageView.image = UIImage(contentsOfFile: imageUrl.path)

        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 檢查物品名稱欄位是否有值
        if nameTextField.text?.isEmpty == false {
            // 有值的話回傳true，回到TableView
            return true
        } else {
            // 若無值則跳出警告，回傳false則不會回到前一頁
            let alertController = UIAlertController(title: "エラー", message: "ITEM名を入力してください。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let imageId = getImageId()
        item = Item(
            name: nameTextField.text!,
            date: dateTextField.text!,
            imageName: imageId,
            memo: memoTextView.text
        )
        saveImage(imageId: imageId)
    }
    
    // 點選螢幕任一處收鍵盤
    @objc func didTapView() {
        self.view.endEditing(true)
    }
    

}

// MARK: - Image
extension AddItemTableViewController {
    
    func getImageId() -> String {
        // 判斷是否已有圖片名稱，若無則用UUID產生新的圖片名稱
        var fileId: String
        if let id = item?.imageName {
            fileId = id
        } else {
            fileId = UUID().uuidString
        }
        return fileId
    }
    
    func saveImage(imageId: String) {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if let image = itemImageView.image {
            if let data = image.jpegData(compressionQuality: 0.8) {
                let filename = documentDirectory.appendingPathComponent("\(imageId).jpg")
                try? data.write(to: filename)
                item?.imageName = imageId
            }
        }
    }
}

// MARK: - Select Photo
extension AddItemTableViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProviders = results.map(\.itemProvider)
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] (image, Error) in
                DispatchQueue.main.async {
                    guard let self = self,
                          let image = image as? UIImage else { return }
                    self.itemImageView.image = image
                }
            }
        }
    }
    
    func selectPhoto() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
}

// MARK: - Use camera to take photo
extension AddItemTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhoto() {
        // 檢查相機是否能夠使用
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            present(picker, animated: true, completion: nil)
        } else {
            // 若相機無法使用則顯示警告視窗
            let alertController = UIAlertController(title: "エラー", message: "カメラのアクセスを許可してください", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            itemImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Date Picker
extension AddItemTableViewController {
    func createDatePicker() {
        // 設定datePicker樣式
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = UIColor(named: "lightblue")
        // 預設日期設為今天
        datePicker.date = Date.now
        // 將今天的日期轉換成String寫到TextField中
        writeDateToTextField(date: datePicker.date)
        
        // 建立ToolBar及指定樣式
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor(named: "navygray")
        toolbar.isTranslucent = false
        // 建立Done Button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonPressed))
        doneButton.tintColor = .white
        // 把Done Button加入ToolBar中
        toolbar.setItems([doneButton], animated: true)
        
        // 點選textField會顯示DatePicker及ToolBar
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    // 點選Done之後會自動將所選擇的日期寫入textField
    @objc func doneButtonPressed() {
        writeDateToTextField(date: datePicker.date)
        // 關閉DatePicker
        self.view.endEditing(true)
    }
    
    // 將日期由Date轉換成指定的格式並寫入TextField中
    func writeDateToTextField(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/M/d"
        dateTextField.text = dateFormatter.string(from: date)
    }
}
