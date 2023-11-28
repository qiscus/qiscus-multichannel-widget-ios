//
//  QiscusUploaderVC.swift
//  Example
//
//  Created by Ahmad Athaullah on 9/12/17.
//  Copyright © 2017 Ahmad Athaullah. All rights reserved.
//

#if os(iOS)
import UIKit
#endif

import UIKit
import Photos
import MobileCoreServices
import QiscusCore
//import CropViewController

//enum QUploaderType {
//    case image
//    case video
//}

class QiscusUploaderVC: UIViewController, UIScrollViewDelegate,UITextViewDelegate {
    
    init() {
        super.init(nibName: "QiscusUploaderVC", bundle: QiscusMultichannelWidget.bundle)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var ivVideoIndicator: UIImageView!
    @IBOutlet weak var btnCrop: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var inputBottom: NSLayoutConstraint!
    @IBOutlet weak var mediaCaption: UITextView!
    @IBOutlet weak var minInputHeight: NSLayoutConstraint!
    @IBOutlet weak var viewInputHeight: NSLayoutConstraint!
    @IBOutlet weak var imageCollection: UploadImageCollection!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var viewUploadingDescription: UIView!
    @IBOutlet weak var labelUploadingDescription: UILabel!
    //    @IBOutlet weak var mediaBottomMargin: NSLayoutConstraint!
    
    var chatView:UIChatViewController?
    var type = QUploaderType.image
    var isImageUploaded: [UIImage : Bool] = [:]
    var selectedImageIndex: Int = 0
    let maxProgressHeight:Double = 80.0
    var room: QChatRoom? = nil
    var imageAssets: [PHAsset?] = []
    /**
     Setup maximum size when you send attachment inside chat view, example send video/image from galery. By default maximum size is unlimited.
     */
    var maxUploadSizeInKB:Double = Double(100) * Double(1024)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
        // initial image file upload
        //        self.startUpload(fileName: self.fileName, data: self.data)
        self.processAssets(assets: self.imageAssets)
        
        for gesture in self.view.gestureRecognizers! {
            self.view.removeGestureRecognizer(gesture)
        }
    }
    
    private func processAssets(assets: [PHAsset?]) {
        for asset in assets {
            guard let asset = asset else {
                return
            }
            
            self.imageView.image = asset.getPreviewImage()
            //self.imageCollection.addImage(image: asset)
            
            if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.image {
                //self.btnCrop.isHidden = false
                self.btnCrop.isHidden = true
                self.ivVideoIndicator.isHidden = true
            }
            
            if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.video {
                self.btnCrop.isHidden = true
                self.ivVideoIndicator.isHidden = false
            }
        }
    }
    
    func upload(assets: [PHAsset?], totalAssets: Int, completion: @escaping () -> Void) {
        labelUploadingDescription.text = "Uploading \((self.imageAssets.count + 1) - assets.count)/\(self.imageAssets.count)"
        
        var mutableAssets = assets
        mutableAssets.first??.getURL { [weak self] (assetUrl) in
            guard let asset = assets.first as? PHAsset, let assetUrl = assetUrl else {
                return
            }
            
            let fileName = PHAssetResource.assetResources(for: asset).first?.originalFilename.replacingOccurrences(of: "HEIC", with: "jpg")
            let fileNameArr = fileName?.split(separator: ".")
            let fileExt:String = String(fileNameArr?.last ?? "").lowercased()
            var mediaData: Data?
            if asset.mediaType == .image {
                guard let imageData = try? Data(contentsOf: assetUrl), let imageSize = UIImage(data: imageData)?.size else {
                    return
                }
                
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
                
                mediaData = fileExt == "gif" ? imageData : UIImage(data: imageData)?.jpegData(compressionQuality: compressVal)
            } else {
                mediaData = try? Data(contentsOf: assetUrl)
            }
            
            let assetIdentifier = PHAssetResource.assetResources(for: asset).first?.assetLocalIdentifier
            let isLastImage = mutableAssets.count == 1
            self?.startUpload(fileName: fileName, data: mediaData, isLastImage: isLastImage, assetLocalIdentifier: assetIdentifier ?? "", totalAssets: totalAssets, completion: {
                mutableAssets.removeFirst()
                
                if mutableAssets.isEmpty {
                    completion()
                    return
                }
                
                self?.upload(assets: mutableAssets, totalAssets: totalAssets, completion: completion)
            })
        }
    }
    
    private func startUpload(fileName: String?, data: Data?, isLastImage: Bool, assetLocalIdentifier: String, totalAssets: Int, completion: @escaping () -> Void) {
        if fileName != nil && data != nil {
            //            self.labelTitle.text = self.fileName!
            
            let file = FileUploadModel()
            file.data = data!
            file.name = fileName!
            
            let comment = QMessage()
            comment.chatRoomId = self.room?.id ?? ""
            let caption = (mediaCaption.text == "Add caption to your image" ? "" : mediaCaption.text) ?? ""

            chatView?.uploadImageMessage(comment: comment, file: file, assetIdentifier: assetLocalIdentifier, caption: caption, totalAssets: totalAssets, onComplete: completion)
            
        }
    }
    
    func setupUI(){
        //        self.labelTitle.text = "Image"
//        self.mentionView.isHidden = true
//        self.mentionView.textView = self.mediaCaption
//        self.mentionView.room = self.room
        self.hiddenProgress()
        self.containerProgressView.layer.cornerRadius = self.containerProgressView.frame.height / 2
        
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem:
            UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.doneClicked) )
        
        keyboardToolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        mediaCaption.inputAccessoryView = keyboardToolBar
        
        mediaCaption.text = TextConfiguration.sharedInstance.captionPlaceholder
        mediaCaption.textColor = UIColor.lightGray
        mediaCaption.delegate = self
        mediaCaption.layer.cornerRadius = 10
        mediaCaption.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 38)
        
        viewUploadingDescription.layer.cornerRadius = 10
        
        self.qiscusAutoHideKeyboard()
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 4.0
        let sendImage = UIImage(named: "send")?.withRenderingMode(.alwaysTemplate)
        self.sendButton.setImage(sendImage, for: .normal)
        self.sendButton.tintColor = ColorConfiguration.topColor
        //        self.cancelButton.setTitle("Cancel", for: .normal)
        self.mediaCaption.font = ChatConfig.chatFont
        
        self.sendButton.tintColor = ColorConfiguration.sendContainerColor
        self.sendButton.setImage(UIImage(named: "ic_send")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        //        self.cancelButton.tintColor = ColorConfiguration.sendButtonColor
        //        self.cancelButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate), for: .normal)
        
        self.imageCollection.setOnTapAdd { [weak self] in
            self?.uploadGalery()
        }
        
        self.imageCollection.setOnTapImage { [weak self] (selectedImage) in
            guard let self = self else {
                return
            }
            self.imageView.image = selectedImage
            
           if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.image {
                self.btnCrop.isHidden = false
                self.ivVideoIndicator.isHidden = true
            }
            
            if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.video {
                self.btnCrop.isHidden = true
                self.ivVideoIndicator.isHidden = false
            }
        }
        
        self.imageCollection.setOnMessages { [weak self] (messages) in
            self?.showMessages(text: messages)
        }
        
        if self.imageAssets.count > 1 {
            self.btnDelete.isEnabled = true
        }
        
//        self.mentionView.shouldDismissKeyboard = {
//            self.view.endEditing(true)
//        }
    }
    
    func hiddenProgress(){
        self.containerProgressView.isHidden = true
        self.labelProgress.isHidden = true
        self.progressView.isHidden = true
    }
    
    func showProgress(){
        self.viewUploadingDescription.isHidden = false
        self.labelProgress.isHidden = false
        self.containerProgressView.isHidden = false
        self.progressView.isHidden = false
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.white
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        //self.mentionView.listenChatInput(textView: textView)
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        let newSize = textView.sizeThatFits(CGSize.init(width: fixedWidth, height: CGFloat(MAXFLOAT)))
//
//        if (newSize.height >= 34 && newSize.height <= 100) {
//            self.minInputHeight.constant = newSize.height
//            self.viewInputHeight.constant = newSize.height + 24.0
//        }
//
//        self.mediaCaption.isScrollEnabled = newSize.height >= 100
//    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        if text.isEmpty {
//            self.mentionView.checkDeleteMention(index: range.location)
//        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
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
        
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(QiscusUploaderVC.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(QiscusUploaderVC.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @IBAction func showEmoji(_ sender: Any) {
        //self.mediaCaption.activateEmoji = true
        if self.mediaCaption.becomeFirstResponder() {
            self.mediaCaption.reloadInputViews()
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteImage(_ sender: Any) {
        self.imageAssets.remove(at: self.imageCollection.selectedIndex)
        
        self.imageCollection.deleteSelectedImage()
        self.imageView.image = self.imageCollection.selectedImage
        
        if self.imageAssets.count == 1 {
            self.btnDelete.isEnabled = false
        }
        
        if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.image {
            self.btnCrop.isHidden = false
            self.ivVideoIndicator.isHidden = true
        }
        
        if self.imageAssets[self.imageCollection.selectedIndex]?.mediaType == PHAssetMediaType.video {
            self.btnCrop.isHidden = true
            self.ivVideoIndicator.isHidden = false
        }
    }
    
    @IBAction func cropImage(_ sender: Any) {
//        guard let image = self.imageCollection.selectedImage else {
//            return
//        }
//        
//        let cropViewController = CropViewController(image: image)
//        cropViewController.delegate = self
//        present(cropViewController, animated: true, completion: nil)
    }
    
    @IBAction func sendMedia(_ sender: Any) {
        if type == .image {
            self.sendButton.isHidden = true
            self.btnClose.isHidden = true
            self.btnDelete.isHidden = true
            self.navigationController?.popViewController(animated: true)
            self.upload(assets: self.imageAssets, totalAssets: self.imageAssets.count) {
                print("upload finished")
//                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func sendImageMessages(imageMessage: QMessage, isLastImage: Bool, completion: @escaping () -> Void) {
        
        if isLastImage && (self.mediaCaption.text != TextConfiguration.sharedInstance.captionPlaceholder) {
            imageMessage.payload!["caption"] = mediaCaption.text
        }
        
        imageMessage.extras = ["file_type" : "media"]
        
        chatView?.send(message: imageMessage, onSuccess: { [weak self] (comment) in
            completion()
            }, onError: { (error) in
                // TODO: handle when sending process failed
        })
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.inputBottom.constant = 0
        //        self.mediaBottomMargin.constant = 8
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.inputBottom.constant = keyboardHeight
        //        self.mediaBottomMargin.constant = -(self.mediaCaption.frame.height + 8)
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func uploadGalery() {
        self.view.endEditing(true)
        let photoPermissions = PHPhotoLibrary.authorizationStatus()
        
        if(photoPermissions == PHAuthorizationStatus.authorized){
            self.goToGaleryPicker()
        }else if(photoPermissions == PHAuthorizationStatus.notDetermined){
            PHPhotoLibrary.requestAuthorization({(status:PHAuthorizationStatus) in
                switch status{
                case .authorized:
                    self.goToGaleryPicker()
                    break
                case .denied:
                    self.showPhotoAccessAlert()
                    break
                default:
                    self.showPhotoAccessAlert()
                    break
                }
            })
        }else{
            self.showPhotoAccessAlert()
        }
    }
    
    func goToGaleryPicker(){
        DispatchQueue.main.async(execute: {
            let picker = QImagePickerViewController()
            picker.existingImageCount = self.imageAssets.count
            picker.onFinishPickImage = { [weak self] (imageAssets) in
                self?.btnDelete.isEnabled = true
                self?.imageAssets.append(contentsOf: imageAssets)
                self?.processAssets(assets: imageAssets)
            }
            
            self.present(picker, animated: true, completion: nil)
        })
    }
    
    func showPhotoAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.galeryAccessAlertText
            QPopUpView.showAlert(withTarget: self, vc: self.chatView, message: text, doneAction: {
                
            }, cancelAction: {
                
            })
        })
    }
    
    //Alert
    func goToIPhoneSetting(){
        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showCameraAccessAlert(){
        DispatchQueue.main.async(execute: {
            let text = TextConfiguration.sharedInstance.cameraAccessAlertText
            let cancelTxt = TextConfiguration.sharedInstance.alertCancelText
            let settingTxt = TextConfiguration.sharedInstance.alertSettingText
            QPopUpView.showAlert(withTarget: self, vc: self.chatView, message: text, firstActionTitle: settingTxt, secondActionTitle: cancelTxt,
                                 doneAction: {
                                    self.goToIPhoneSetting()
            },
                                 cancelAction: {}
            )
        })
    }
    
    func showMessages(text: String) {
           let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
           let closeButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
           alert.addAction(closeButton)
           
           present(alert, animated: true, completion: nil)
       }
}

//extension QiscusUploaderVC : CropViewControllerDelegate {
//    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
//        var placeholder: PHObjectPlaceholder?
//        PHPhotoLibrary.shared().performChanges({
//            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//            let albumChangeRequest = PHAssetCollectionChangeRequest()
//            guard let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
//            placeholder = photoPlaceholder
//            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
//            albumChangeRequest.addAssets(fastEnumeration)
//        }, completionHandler: { [weak self] success, error in
//            guard let self = self else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                cropViewController.dismiss(animated: true, completion: nil)
//            }
//            guard let placeholder = placeholder else {
//                return
//            }
//            if success {
//                let assets: PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
//                guard let asset: PHAsset = assets.firstObject else {
//                    return
//                }
//                
//                self.imageAssets[self.imageCollection.selectedIndex] = asset
//                //self.imageCollection.updateSelectedImage(asset: asset)
//                
//                DispatchQueue.main.async {
//                    self.imageView.image = asset.getPreviewImage()
//                }
//                
//                PHPhotoLibrary.shared().performChanges({
//                    PHAssetChangeRequest.deleteAssets([asset] as NSArray)
//                }) { (success, error) in
//                    
//                }
//            }
//        })
//    }
//}
