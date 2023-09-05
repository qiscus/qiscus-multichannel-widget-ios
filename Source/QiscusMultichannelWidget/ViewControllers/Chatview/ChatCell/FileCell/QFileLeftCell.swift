//
//  QFileLeftCell.swift
//  BBChat
//
//  Created by qiscus on 24/01/20.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore

import AlamofireImage
import SwiftyJSON

struct DocumentsDirectory {
    static let localDocumentsURL: NSURL? = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: .userDomainMask).last! as NSURL
    static let iCloudDocumentsURL: NSURL? = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") as! NSURL
    
}

class QFileLeftCell: UIBaseChatCell {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbFileSizeExtension: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var ivFIle: UIImageView!
    @IBOutlet weak var ivAvatarUser: UIImageView!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    var isQiscus : Bool = false
    var vc : UIChatViewController? = nil
    var message: QMessage? = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleMassage(_:)),
                                               name: Notification.Name("selectedCell"),
                                               object: nil)
       
    }
    
    @objc func handleMassage(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let json = JSON(userInfo)
            let commentId = json["commentId"].string ?? "0"
            if let message = self.message {
                if message.id == commentId {
                    self.contentView.backgroundColor = UIColor(red:39/255, green:177/255, blue:153/255, alpha: 0.1)
                }else{
                    self.contentView.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
        // Configure the view for the selected state
    }
    
    override func present(message: QMessage) {
        // parsing payload
        self.bindData(message: message)
        
    }
    
    override func update(message: QMessage) {
        self.bindData(message: message)
    }
    
    func bindData(message: QMessage){
        self.contentView.backgroundColor = UIColor.clear
        self.message = message
        self.setupBalon(message : message)
        
        self.lbTime.text = self.hour(date: message.date())
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        self.tvContent.text = message.message
        self.tvContent.textColor = ColorConfiguration.leftBubbleTextColor
        self.ivFIle.image = UIImage(named: "ic_file_attachment",in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.ivFIle.tintColor = ColorConfiguration.leftBubbleTextColor
        
        self.ivAvatarUser.layer.cornerRadius = self.ivAvatarUser.frame.size.width / 2
        self.ivAvatarUser.clipsToBounds = true
        
        if let avatar = message.userAvatarUrl {
            if avatar.absoluteString.contains("https://image.flaticon.com/icons/svg/145/145867.svg") == true{
                self.ivAvatarUser.af_setImage(withURL: URL(string:"https://d1edrlpyc25xu0.cloudfront.net/ziv-nqsjtf0zdqf6kfk7s/image/upload/w_320,h_320,c_limit/r7byw7m9e4/default-wa.png")!)
            }else{
                self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
            }
        }else{
            self.ivAvatarUser.af_setImage(withURL: message.userAvatarUrl ?? URL(string: "http://")!)
        }
        
        if(isPublic == true){
            self.lbName.text = message.sender.name
            self.lbName.textColor = colorName
            lbNameHeight.constant = 21
        }else{
            self.lbName.text = ""
            lbNameHeight.constant = 0
        }
        
        if ChatConfig.showAvatarSender == true{
            self.lbNameLeading.constant = 65
            self.ivAvatarUser.isHidden = false
        }else{
            self.lbNameLeading.constant = 20
            self.ivAvatarUser.isHidden = true
        }
        
        if ChatConfig.showUserNameSender == true {
            self.lbName.isHidden = false
            self.lbNameHeight.constant = 21
            self.lbName.textColor = colorName
        }else{
            self.lbName.isHidden = true
            self.lbNameHeight.constant = 0
        }
        
        guard let payload = message.payload else { return }
        
        let caption = payload["caption"] as? String
        
        if let caption = caption {
            if caption.contains("This message was sent on previous session") == true {
                
                let messageALL = caption
                let messageALLArr = messageALL.components(separatedBy: "This message was sent on previous session")
                
                if  messageALLArr.count >= 2 {
                    let message1 = messageALLArr[0] + "&#x2015;&#x2015;&#x2015;<br/><br/><small>"
                    let message1Replace = message1.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    
                    let message2 =  "This message was sent on previous session" + messageALLArr[1]
                    let message2Replace = message2.replacingOccurrences(of: "\n", with: "<br/>", options: .literal, range: nil)
                    let allMesage = message1Replace + message2Replace
                    
                    let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.white];
                    // create the attributed string
                    let attributedString = NSMutableAttributedString(string: allMesage.htmlToString, attributes: attributedStringColor)
                    
                    if let distance = attributedString.string.distance(of: "This message was sent on previous session") {
                        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 10), range: NSRange(location: distance , length: attributedString.string.count - distance - 1))
                    }
                    
                    self.lbCaption.attributedText = attributedString
                    self.lbCaption.textColor = UIColor.white
                    self.lbFileSizeExtension.textColor  = UIColor.white
                    self.ivFIle.tintColor = UIColor.white
                    self.tvContent.textColor = UIColor.white
                    
                }else{
                    self.lbCaption.text = caption
                }
            }else{
                self.lbCaption.text = caption
            }
            
        }else{
            self.lbCaption.text = ""
        }
        
        if let fileName = payload["file_name"] as? String{
            if fileName.isEmpty {
                self.tvContent.text = message.fileName(text: message.message)
            }else{
                self.tvContent.text = fileName
            }
            
            if let url = payload["url"] as? String {
                let ext = message.fileExtension(fromURL:url)
                if !url.isEmpty {
                    QismoManager.shared.qiscus.shared.download(url: URL(string: url)!, onSuccess: { (urlLocal) in
                        DispatchQueue.main.async {
                            do {
                                let resources = try urlLocal.resourceValues(forKeys:[.fileSizeKey])
                                if let size = resources.fileSize {
                                    self.lbFileSizeExtension.text = "\(self.getMb(size: size)) - \(ext.uppercased()) file"
                                } else {
                                    self.lbFileSizeExtension.text = "0 Mb - \(ext.uppercased()) file"
                                }
                            } catch {
                                self.lbFileSizeExtension.text = "0 Mb - \(ext.uppercased()) file"
                            }
                        }
                        
                    }) { (progress) in
                        
                    }
                }
                
                if let size = payload["size"] as? Int {
                    if size != 0 {
                        self.lbFileSizeExtension.text = "\(getMb(size: size)) - \(ext.uppercased()) file"
                    }
                }
            }
        }
    }
    
    func getMb(size : Int)-> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(size))
        
        let updateMb = string.replacingOccurrences(of: "MB", with: "Mb")
        return updateMb
    }
    
    @IBAction func saveFile(_ sender: Any) {
        guard let payload = self.comment?.payload else { return }
        if let fileName = payload["file_name"] as? String{
            if let url = payload["url"] as? String {
                
                if let vc = self.vc {
                    vc.view.endEditing(true)
                }
                
                if url.contains(".oga") == true {
//                    let preview = PlayOgaVC()
//                    preview.mediaURL = url
                    let preview = ChatPreviewDocVC()
                    preview.fileName = fileName
                    preview.url = url
                    preview.roomName = "Document Preview"
                    self.vc?.navigationController?.pushViewController(preview, animated: true)
                } else {
                    let preview = ChatPreviewDocVC()
                    preview.fileName = fileName
                    preview.url = url
                    preview.roomName = "Document Preview"
                    self.vc?.navigationController?.pushViewController(preview, animated: true)
                }
                
               
            }
        }
    }
    
    func save(fileName: String, tempLocalUrl: URL){
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: tempLocalUrl.path)
        while let file = enumerator?.nextObject() as? String {
            
            do {
                try fileManager.setUbiquitous(true,
                                              itemAt: DocumentsDirectory.localDocumentsURL!.appendingPathComponent(file)!,
                                              destinationURL: DocumentsDirectory.iCloudDocumentsURL!.appendingPathComponent(file)!)
                print("Moved to iCloud")
            } catch let error as NSError {
                print("Failed to move file to Cloud : \(error)")
            }
        }
        
        
        
        do {
            let documentsURL = try
                FileManager.default.url(for: .documentDirectory,
                                        in: .userDomainMask,
                                        appropriateFor: nil,
                                        create: false)
            
            let savedURL = documentsURL.appendingPathComponent(fileName)
            
            try FileManager.default.copyItem(at: tempLocalUrl, to: savedURL)
            self.showAlertWith(title: "Saved!", message: "Your file has been saved to your document.")
        } catch {
            print ("file error: \(error)")
            self.showAlertWith(title: "Save error", message: "\(error.localizedDescription)")
        }
        
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.currentViewController()?.navigationController?.present(ac, animated: true, completion: {
            //success
        })
        
    }
    
    func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return currentViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return currentViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        
        return base
    }
    
    
    func setupBalon(message: QMessage){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
       
        
        guard let payload = message.payload else {
            self.ivBaloonLeft.tintColor = ColorConfiguration.leftBubbleColor
            return
        }
        let caption = payload["caption"] as? String
        
        var dataCaption = ""
        if let caption = caption {
            dataCaption = caption
        }
        
        self.ivBaloonLeft.tintColor = ColorConfiguration.leftBubbleColor
        self.ivBaloonLeft.backgroundColor = ColorConfiguration.leftBubbleColor
        self.ivBaloonLeft.layer.cornerRadius = 5
    }
    
    func hour(date: Date?) -> String {
        guard let date = date else {
            return "-"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone      = TimeZone.current
        let defaultTimeZoneStr = formatter.string(from: date);
        return defaultTimeZoneStr
    }
    
}

