
#if os(iOS)
import UIKit
#endif
import Photos
import MobileCoreServices
import QiscusCore
import Alamofire
import AlamofireImage
import SwiftyJSON
import AVFoundation
import PhotosUI

enum QUploaderType {
    case image
    case video
}

class NewQiscusUploaderVC: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var inputBottom: NSLayoutConstraint!
    @IBOutlet weak var mediaCaption: UITextView!
    @IBOutlet weak var minInputHeight: NSLayoutConstraint!
    
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    @IBOutlet weak var imageCollection: UploadImageCollection!
    @IBOutlet weak var constraintProgressWidth: NSLayoutConstraint!
    
    var chatView:UIChatViewController?
    var type = QUploaderType.image
    var data   : Data?
    var fileName :String?
    var imageData: [QMessage] = []
    var selectedImageIndex: Int = 0
    let maxProgressHeight:Double = 40.0
    var content: [String: Any] = [:]
    var captions = [String]()
    
    
    /**
     Setup maximum size when you send attachment inside chat view, example send video/image from galery. By default maximum size is unlimited.
     */
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    
    init() {
        super.init(nibName: "NewQiscusUploaderVC", bundle: QiscusMultichannelWidget.bundle)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.setupUI()
        
        if self.data != nil && self.imageData.count == 0 {
            self.title = "Upload Image"
            
            let file = FileUploadModel()
            file.data = data!
            file.name = fileName!
            self.captions.append("")
            self.labelProgress.text = ""
            QismoManager.shared.qiscus.shared.upload(file: file, onSuccess: { (file) in
                print("upload progress finish")
                self.sendButton.isEnabled = true
                self.sendButton.isHidden = false
                self.hiddenProgress()
                
                let message = QMessage()
                message.type = "file_attachment"
                message.payload = [
                    "url"       : file.url.absoluteString,
                    "file_name" : file.name,
                    "size"      : file.size,
                    "caption"   : ""
                ]
                message.message = "Send Image"
                self.imageData.append(message)
            }, onError: { (error) in
                //error
            }, progressListener: { (progress) in
                print("upload progress: \(progress)")
                UIView.animate(withDuration: 0.65, animations: {
                    self.progressView.layoutIfNeeded()
                    self.labelProgress.text = "\(Int(progress * 100)) %"
                    self.showProgress()
                    
                })
            })
            
        }
        
        for gesture in self.view.gestureRecognizers! {
            self.view.removeGestureRecognizer(gesture)
        }
    }
    
    func setupUI(){
        self.title = "Image"
        
        let backButton = self.backButton(self, action: #selector(NewQiscusUploaderVC.goBack))
        backButton.qiscusHideSharedBackground()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        self.navigationController?.navigationBar.barTintColor = ColorConfiguration.navigationColor
        
        self.hiddenProgress()
        self.containerProgressView.layer.cornerRadius = self.containerProgressView.frame.height / 2
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        doneButton.qiscusHideSharedBackground()
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        mediaCaption.inputAccessoryView = keyboardToolBar
        
        mediaCaption.text = TextConfiguration.sharedInstance.captionPlaceholder
        mediaCaption.textColor = UIColor.lightGray
        mediaCaption.delegate = self
        mediaCaption.layer.cornerRadius = 8
        
        self.qiscusAutoHideKeyboard()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        self.sendButton.tintColor = ColorConfiguration.topColor
        self.mediaCaption.font = ChatConfig.chatFont
        
        self.sendButton.setImage(UIImage(named: "ic_send", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.sendButton.setImage(UIImage(named: "ic_uploading", in: QiscusMultichannelWidget.bundle,compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .disabled)
        self.sendButton.isEnabled = false
        self.sendButton.tintColor = ColorConfiguration.sendContainerColor

        self.imageCollection.addImage(image: UIImage(data: self.data!)!)
        self.imageCollection.setOnTapImage { [weak self] (selectedImage) in
            guard let self = self else {
                return
            }
            
            self.mediaCaption.endEditing(true)
            self.imageView.image = selectedImage
            
            self.selectedImageIndex = self.imageCollection.selectedIndex
            
            for (index, element) in self.captions.enumerated() {
                if index ==  self.imageCollection.selectedIndex {
                    var cap = self.captions[index]
                    
                    if cap.isEmpty{
                        cap = TextConfiguration.sharedInstance.captionPlaceholder
                        self.mediaCaption.textColor = UIColor.lightGray
                    }else{
                        self.mediaCaption.textColor = UIColor.black
                    }
                    self.mediaCaption.text = cap
                }
            }
            
           
     
            
        }

        self.imageCollection.setOnMessages { [weak self] (messages) in
            //self?.showMessages(text: messages)
        }
        
        self.imageCollection.setOnTapAdd { [weak self] in
            self?.goToGaleryPicker()
        }
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = UIImage(named: "ic_arrow_back", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = ColorConfiguration.navigationTitleColor
        backIcon.contentMode = .scaleAspectFit
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 30,height: 25)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 30,height: 25)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 30,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func hiddenProgress(){
        progressView.isHidden = true
        labelProgress.isHidden = true
        containerProgressView.isHidden = true
    }
    
    func showProgress(){
        progressView.isHidden = false
        labelProgress.isHidden = false
        containerProgressView.isHidden = false
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            if #available(iOS 14, *) {
                var configuration = PHPickerConfiguration()
                configuration.selectionLimit = 1
                configuration.filter = .images
                let picker = PHPickerViewController(configuration: configuration)
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.sourceType = UIImagePickerController.SourceType.photoLibrary
                picker.mediaTypes = [kUTTypeImage as String]
                self.present(picker, animated: true, completion: nil)
            }
        })
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == TextConfiguration.sharedInstance.captionPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == TextConfiguration.sharedInstance.captionPlaceholder {
            textView.text = TextConfiguration.sharedInstance.captionPlaceholder
            textView.textColor = UIColor.lightGray
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.barTintColor =  ColorConfiguration.navigationColor
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorConfiguration.navigationTitleColor]

        
        if self.data != nil {
            if type == .image {
                self.imageView.image = UIImage(data: self.data!)
              
            }
        }

        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(NewQiscusUploaderVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(NewQiscusUploaderVC.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func sendMedia(_ sender: Any) {
        if type == .image {
            
            for (indexX, element) in self.imageData.enumerated() {
                for (indexY, element) in self.captions.enumerated() {
                    if indexX == indexY {
                        let payload = self.imageData[indexX].payload
                        let json = JSON(payload)
                        let url = json["url"].string ?? ""
                        let fileName = json["file_name"].string ?? ""
                        let size =  json["size"].int ?? 0
                        let caption = self.captions[indexY]
                        
                        self.imageData[indexY].payload = [
                            "url"       : url,
                            "file_name" : fileName,
                            "size"      : size,
                            "caption"   : caption
                        ]
                    }
                }
                
                self.chatView?.send(message: self.imageData[indexX], onSuccess: { (comment) in
                    self.chatView?.setFromUploader(comment: comment)
                }, onError: { (error) in
                    print("error send image \(error)")
                })
            }
            
            
            let _ = self.navigationController?.popViewController(animated: true)
        
        }
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.inputBottom.constant = 0
        self.minInputHeight.constant = 32
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.inputBottom.constant = -keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    @IBAction func cancel(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
}

extension NewQiscusUploaderVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        chatView?.typing(true)
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
        if (newSize.height >= 35 && newSize.height <= 100) {
            self.minInputHeight.constant = newSize.height
        }
        
        if (newSize.height >= 100) {
            textView.isScrollEnabled = true
        }
        
        if textView.text != TextConfiguration.sharedInstance.captionPlaceholder {
            for (index, element) in captions.enumerated() {
                if index ==  self.imageCollection.selectedIndex {
                    captions.remove(at: index)
                    captions.insert(textView.text, at: index)
                }
            }
        }else{
            for (index, element) in captions.enumerated() {
                if index ==  self.imageCollection.selectedIndex{
                    captions.remove(at: index)
                    captions.insert("", at: index)
                }
            }
        }
    }
}


extension NewQiscusUploaderVC: PHPickerViewControllerDelegate {
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if #available(iOS 11.0, *) {
           // UINavigationBar.appearance().tintColor = self.latestNavbarTint
            //self.navigationController?.navigationBar.tintColor = self.latestNavbarTint
        }
        
        guard !results.isEmpty else {
            self.dismiss(animated:true, completion: nil)
            return
        }
        
        var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
        
        let itemProviders = results.map(\.itemProvider)
        
        if itemProviders.count == 0{
            self.dismiss(animated:true, completion: nil)
            return
        }
        
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            var data = image.pngData()
                            
                            let imageSize = image.size
                            var bigPart = CGFloat(0)
                            if(imageSize.width > imageSize.height){
                                bigPart = imageSize.width
                            }else{
                                bigPart = imageSize.height
                            }
                            
                            var compressVal = CGFloat(1)
                            if(bigPart > 2000){
                                compressVal = 2000 / bigPart
                            }
                            
                            data = image.jpegData(compressionQuality:compressVal)
                            
                            if data != nil {
                                let mediaSize = Double(data!.count) / 1024.0
                                if mediaSize > self.maxUploadSizeInKB {
                                    picker.dismiss(animated: true, completion: {
                                        self.showFileTooBigAlert()
                                    })
                                    return
                                } else {
                                    self.dismiss(animated:true, completion: nil)
                                    
                                    picker.dismiss(animated: true, completion: {
                                        
                                    })
                                    
                                    self.imageCollection.addImage(image: UIImage(data: data!)!)
                                    
                                    self.imageView.image = UIImage(data: data!)
                                    
                                    let file = FileUploadModel()
                                    file.data = data!
                                    file.name = imageName
                                    
                                    self.sendButton.isEnabled = false
                                    self.captions.append("")
                                    QismoManager.shared.qiscus.shared.upload(file: file, onSuccess: { (file) in
                                        self.sendButton.isEnabled = true
                                        self.sendButton.isHidden = false
                                        self.hiddenProgress()
                                        
                                        let message = QMessage()
                                        message.type = "file_attachment"
                                        message.payload = [
                                            "url"       : file.url.absoluteString,
                                            "file_name" : file.name,
                                            "size"      : file.size,
                                            "caption"   : ""
                                        ]
                                        message.message = "Send Image"
                                        
                                        self.imageData.append(message)
                                    }, onError: { (error) in
                                        //error
                                    }, progressListener: { (progress) in
                                        print("upload progress: \(progress)")
                                        UIView.animate(withDuration: 0.65, animations: {
                                            self.progressView.layoutIfNeeded()
                                            self.showProgress()
                                            self.labelProgress.text = "\(Int(progress * 100)) %"
                                        })
                                    })
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Image Picker
extension NewQiscusUploaderVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showFileTooBigAlert(){
        let alertController = UIAlertController(title: "Fail to upload", message: "File too big", preferredStyle: .alert)
        let galeryActionButton = UIAlertAction(title: "Cancel", style: .cancel) { _ -> Void in }
        alertController.addAction(galeryActionButton)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let fileType:String = info[.mediaType] as! String
        let time = Double(Date().timeIntervalSince1970)
        let timeToken = UInt64(time * 10000)
        
        if fileType == "public.image"{
            var imageName:String = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            var data = image.pngData()
            
            if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL{
                imageName = imageURL.lastPathComponent
                
                let imageNameArr = imageName.split(separator: ".")
                let imageExt:String = String(imageNameArr.last!).lowercased()
                
                let gif:Bool = (imageExt == "gif" || imageExt == "gif_")
                let png:Bool = (imageExt == "png" || imageExt == "png_")
                
                if png{
                    data = image.pngData()!
                }else if gif{
                    let asset = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    if let phAsset = asset.firstObject {
                        let option = PHImageRequestOptions()
                        option.isSynchronous = true
                        option.isNetworkAccessAllowed = true
                        PHImageManager.default().requestImageData(for: phAsset, options: option) {
                            (gifData, dataURI, orientation, info) -> Void in
                            data = gifData
                        }
                    }
                }else{
                    let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                    let asset = result.firstObject
                    imageName = "\((asset?.value(forKey: "filename"))!)"
                    imageName = imageName.replacingOccurrences(of: "HEIC", with: "jpg")
                    let imageSize = image.size
                    var bigPart = CGFloat(0)
                    if(imageSize.width > imageSize.height){
                        bigPart = imageSize.width
                    }else{
                        bigPart = imageSize.height
                    }
                    
                    var compressVal = CGFloat(1)
                    if(bigPart > 2000){
                        compressVal = 2000 / bigPart
                    }
                    
                    data = image.jpegData(compressionQuality:compressVal)
                }
            }else{
                let imageSize = image.size
                var bigPart = CGFloat(0)
                if(imageSize.width > imageSize.height){
                    bigPart = imageSize.width
                }else{
                    bigPart = imageSize.height
                }
                
                var compressVal = CGFloat(1)
                if(bigPart > 2000){
                    compressVal = 2000 / bigPart
                }
                
                data = image.jpegData(compressionQuality:compressVal)
            }
            
            if data != nil {
                let mediaSize = Double(data!.count) / 1024.0
                if mediaSize > self.maxUploadSizeInKB {
                    picker.dismiss(animated: true, completion: {
                        self.showFileTooBigAlert()
                    })
                    return
                }
                
                dismiss(animated:true, completion: nil)
                
                self.imageCollection.addImage(image: UIImage(data: data!)!)
                
                self.imageView.image = UIImage(data: data!)
                
                let file = FileUploadModel()
                file.data = data!
                file.name = imageName
                
                self.sendButton.isEnabled = false
                self.captions.append("")
                self.labelProgress.text = ""
                QismoManager.shared.qiscus.shared.upload(file: file, onSuccess: { (file) in
                    self.sendButton.isEnabled = true
                    self.sendButton.isHidden = false
                    self.hiddenProgress()
                    
                    let message = QMessage()
                    message.type = "file_attachment"
                    message.payload = [
                        "url"       : file.url.absoluteString,
                        "file_name" : file.name,
                        "size"      : file.size,
                        "caption"   : ""
                    ]
                    message.message = "Send Image"
                    
                    self.imageData.append(message)
                }, onError: { (error) in
                    //error
                }, progressListener: { (progress) in
                    print("upload progress: \(progress)")
                  
                    UIView.animate(withDuration: 0.65, animations: {
                        self.progressView.layoutIfNeeded()
                        self.showProgress()
                        self.labelProgress.text = "\(Int(progress * 100)) %"
                    })
                    
                })
                
                
            }
            
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

