//
//  QPostbackLeftCell.swift
//  Alamofire
//
//  Created by Qiscus on 23/07/21.
//

import UIKit
import QiscusCore
import SwiftyJSON
import AlamofireImage

class QPostbackLeftCell: UIBaseChatCell {
    let maxWidth:CGFloat = 0.6 * UIScreen.main.bounds.size.width
    let minWidth:CGFloat = 0.6 * UIScreen.main.bounds.size.width
    let buttonWidth:CGFloat = 0.6 * UIScreen.main.bounds.size.width
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var userNameLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var leftWidthConstUsername: NSLayoutConstraint!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var ivAvatarUser: UIImageView!
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    var delegateChat : UIChatViewController? = nil
    var isQiscus : Bool = false
    var message: QMessage? = nil
    var colorName : UIColor = UIColor.black
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setMenu()
       textView.contentInset = UIEdgeInsets.zero
        
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
        self.setupBalon()
        
        if ChatConfig.showAvatarSender == true{
            self.leftWidthConstUsername.constant = 65
            self.ivAvatarUser.isHidden = false
        }else{
            self.leftWidthConstUsername.constant = 20
            self.ivAvatarUser.isHidden = true
        }
        
        if ChatConfig.showUserNameSender == true {
            self.userNameLabel.isHidden = false
            self.userNameLabelHeight.constant = 21
        }else{
            self.userNameLabel.isHidden = true
            self.userNameLabelHeight.constant = 0
        }
        
        self.userNameLabel.text = message.sender.name
        self.userNameLabel.textColor = colorName
        
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
        
        balloonView.image = getBallon()
        
        for view in buttonsView.subviews{
            view.removeFromSuperview()
        }
        
        dateLabel.text = self.hour(date: message.date())
        balloonView.tintColor = ColorConfiguration.leftBubbleColor
        balloonView.backgroundColor = ColorConfiguration.leftBubbleColor
        balloonView.layer.cornerRadius = 5.0
        
        if self.comment!.type == "buttons" {
            var i = 0
            guard let dataPayload = message.payload else {
                return
            }
            let data = JSON(dataPayload)
            
            let message = data["text"].string ?? ""
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.center
            
            var textAttribute:[NSAttributedString.Key: Any]{
                get{
                    let foregroundColorAttributeName = ColorConfiguration.leftBubbleTextColor
                    return [
                        NSAttributedString.Key.foregroundColor: foregroundColorAttributeName,
                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                        NSAttributedString.Key.paragraphStyle : paragraphStyle
                    ]
                }
            }
            
            let attributedText = NSMutableAttributedString(string: message)
            let allRange = (message as NSString).range(of: message)
            attributedText.addAttributes(textAttribute, range: allRange)
            
            self.textView.attributedText = attributedText
            self.textView.linkTextAttributes = self.linkTextAttributes
            
            let buttonsPayload = data["buttons"].arrayValue
            
//            self.buttonsViewHeight.constant = CGFloat(buttonsPayload.count * 45)
//            self.layoutIfNeeded()
            
            var buttonsViewHeight = 0
            
            for buttonsData in buttonsPayload{
                let label = buttonsData["label"].string ?? ""
                let check = label.count
                
                var height = 43
                if check >= 60 {
                    height = 100
                    buttonsViewHeight += 100
                }else{
                    buttonsViewHeight += 45
                }
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: Int(self.buttonsView.frame.size.width), height: height))
                button.backgroundColor = ColorConfiguration.leftBubbleColor
                button.titleLabel?.numberOfLines = 4
                button.titleLabel?.lineBreakMode = .byTruncatingTail
                button.titleLabel?.textAlignment = .center
                button.sizeToFit()
                button.setTitle(buttonsData["label"].stringValue, for: .normal)
                button.setTitleColor(ColorConfiguration.leftBubbleTextColor, for: .normal)
                button.setTitleColor(ColorConfiguration.rightBubbleColor, for: .highlighted)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
                button.tag = i
                button.addTarget(self, action:#selector(self.postback(sender:)), for: .touchUpInside)
               
                
                if i == 0{
                    button.addBorderTop(size: 1, color: UIColor.white, width: 2 * balloonView.frame.size.width)
                    
                }
                
                self.buttonsView.addArrangedSubview(button)
                
                i += 1
            }
            
            self.buttonsViewHeight.constant = CGFloat(buttonsViewHeight)
            
            
        }else{
            guard let dataPayload = message.payload else {
                return
            }
            
            let data = JSON(dataPayload)
            let paramData = data["params"]

            self.buttonsViewHeight.constant = CGFloat(45)
            self.layoutIfNeeded()

            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonsView.frame.size.width, height: 43))
            button.backgroundColor = ColorConfiguration.leftBubbleColor
            button.setTitle(paramData["button_text"].stringValue, for: .normal)
            button.setTitleColor(ColorConfiguration.leftBubbleTextColor, for: .normal)
            button.setTitleColor(ColorConfiguration.rightBubbleColor, for: .highlighted)
            button.tag = 2222
            button.addTarget(self, action:#selector(self.accountLinking(sender:)), for: .touchUpInside)
            button.addBorderTop(size: 1, color: UIColor.white)
            self.buttonsView.addArrangedSubview(button)
            
        }
    }
    
    func setupBalon(){
        
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
    
    @objc func postback(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        let allData =  data["buttons"].arrayValue
        if allData.count > sender.tag {
            self.didTapActionButton(withData: allData[sender.tag])
            
        }
    }
    
    @objc func accountLinking(sender:UIButton){
        guard let dataPayload = self.comment?.payload else {
            return
        }
        let data = JSON(dataPayload)
        self.didTapAccountLinking(data: data)
    }
    
    func didTapActionButton(withData data:JSON){
        let postbackType = data["type"].stringValue
        let payload = data["payload"]
        switch postbackType {
        case "link":
            let urlString = payload["url"].stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let urlArray = urlString.components(separatedBy: "/")
            func openInBrowser(){
                if let url = URL(string: urlString) {
                    UIApplication.shared.openURL(url)
                }
            }
            
            if urlArray.count > 2 {
                if urlArray[2].lowercased().contains("instagram.com") {
                    var instagram = "instagram://app"
                    if urlArray.count == 4 || (urlArray.count == 5 && urlArray[4] == ""){
                        let usernameIG = urlArray[3]
                        instagram = "instagram://user?username=\(usernameIG)"
                    }
                    if let instagramURL =  URL(string: instagram) {
                        if UIApplication.shared.canOpenURL(instagramURL) {
                            UIApplication.shared.openURL(instagramURL)
                        }else{
                            openInBrowser()
                        }
                    }
                }else{
                    openInBrowser()
                }
            }else{
                openInBrowser()
            }
            
            
            break
        default:
            let text = data["label"].stringValue
            let type = "text"
            if let room = self.delegateChat?.room {
                
                let comment = QMessage()
                comment.type = type
                comment.message = text
                comment.payload = payload.dictionaryObject
                
                QismoManager.shared.qiscus.shared.sendMessage(roomID: room.id, comment: comment, onSuccess: { (commentModel) in
                    //success
                }, onError: { (error) in
                    
                })
                
            }
            break
        }
        
    }
    
    func didTapAccountLinking(data:JSON){
        let webView = ChatPreviewDocVC()
        webView.accountLinking = true
        webView.accountData = data
        
        if let vc = delegateChat {
            vc.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            vc.navigationController?.pushViewController(webView, animated: true)
        }
       
    }
    
}
