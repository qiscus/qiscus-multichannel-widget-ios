//
//  QFileRightCell.swift
//  BBChat
//
//  Created by qiscus on 27/01/20.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore
import SwiftyJSON

class QFileRightCell: UIBaseChatCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var lbCaption: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbFileSizeExtension: UILabel!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ivFIle: UIImageView!
    var menuConfig = enableMenuConfig()
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
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon(message: message)
        self.status(message: message)
        
        self.lbTime.text = self.hour(date: message.date())
        self.tvContent.textColor = ColorConfiguration.rightBubbleTextColor
        self.ivFIle.image = UIImage(named: "ic_file_attachment", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        self.ivFIle.tintColor = UIColor.white
        
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
                }else{
                    self.lbCaption.text = caption
                }
            }else{
                self.lbCaption.text = caption
            }
            
        }else{
            self.lbCaption.text = ""
        }
        
        self.lbCaption.textColor = ColorConfiguration.rightBubbleTextColor
        
        
        if let fileName = payload["file_name"] as? String{
            if fileName.isEmpty {
                self.tvContent.text = message.fileName(text: message.message)
            }else{
                self.tvContent.text = fileName
            }
            if let url = payload["url"] as? String {
                if !url.isEmpty {
                    let ext = message.fileExtension(fromURL:url)
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
                    
                    if let size = payload["size"] as? Int {
                        if size != 0 {
                             self.lbFileSizeExtension.text = "\(getMb(size: size)) - \(ext.uppercased()) file"
                        }
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
    
    func setupBalon(message : QMessage){
        //self.ivBaloonLeft.applyShadow()
        self.ivBaloonLeft.image = self.getBallon()
        
        guard let payload = message.payload else {
            self.lbNameHeight.constant = 0
            self.ivBaloonLeft.tintColor = ColorConfiguration.rightBubbleColor
            return
        }
        let caption = payload["caption"] as? String
        
        var dataCaption = ""
        if let caption = caption {
            dataCaption = caption
        }
        
        self.lbNameHeight.constant = 0
        self.ivBaloonLeft.tintColor = ColorConfiguration.rightBubbleColor
        self.ivBaloonLeft.backgroundColor = ColorConfiguration.rightBubbleColor
        self.ivBaloonLeft.layer.cornerRadius = 5
        
    }
    
    func save(fileName: String, tempLocalUrl: URL){
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
    
    
    func status(message: QMessage){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            lbTime.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_sending", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_read", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        }
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
