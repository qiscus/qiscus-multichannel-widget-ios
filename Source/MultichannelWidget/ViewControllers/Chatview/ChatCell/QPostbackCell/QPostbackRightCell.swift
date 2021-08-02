//
//  QPostbackRightCell.swift
//  MultichannelWidget
//
//  Created by Qiscus on 23/07/21.
//

import UIKit
import QiscusCore
import SwiftyJSON
import AlamofireImage

class QPostbackRightCell: UIBaseChatCell {
    let maxWidth:CGFloat = 0.6 * UIScreen.main.bounds.size.width
    let minWidth:CGFloat = 0.6 * UIScreen.main.bounds.size.width
    let buttonWidth:CGFloat = 0.7 * UIScreen.main.bounds.size.width
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lbUserNameHeight: NSLayoutConstraint!
    @IBOutlet weak var balloonView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var buttonsView: UIStackView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
//    @IBOutlet weak var textViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var buttonsViewHeight: NSLayoutConstraint!
    var delegateChat : UIChatViewController? = nil
    var isQiscus : Bool = false
    var message: QMessage? = nil
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
        self.setupBalon(message : message)
        self.status(message: message)
        self.userNameLabel.text = message.sender.name
        
        balloonView.image = getBallon()
        
        for view in buttonsView.subviews{
            view.removeFromSuperview()
        }
        
        dateLabel.text = self.hour(date: message.date())
        balloonView.tintColor = ColorConfiguration.rightBubbleColor
        balloonView.backgroundColor = ColorConfiguration.rightBubbleColor
        balloonView.layer.cornerRadius = 5.0

        if message.isMyComment() {
            self.lbUserNameHeight.constant = 0
            self.balloonView.tintColor = ColorConfiguration.rightBubbleColor
        }
        
        if self.comment!.type == "buttons" {
            var i = 0
            
            guard let dataPayload = message.payload else {
                return
            }
            let data = JSON(dataPayload)
            
            let message = data["text"].string ?? ""
            
            var textAttribute:[NSAttributedString.Key: Any]{
                get{
                    var foregroundColorAttributeName = ColorConfiguration.rightBubbleTextColor
                    return [
                        NSAttributedString.Key.foregroundColor: foregroundColorAttributeName,
                        NSAttributedString.Key.font: ChatConfig.chatFont
                    ]
                }
            }
            
            var attributedText = NSMutableAttributedString(string: message)
            let allRange = (message as NSString).range(of: message)
            attributedText.addAttributes(textAttribute, range: allRange)
            
            self.textView.attributedText = attributedText
            self.textView.linkTextAttributes = self.linkTextAttributes
            
            let buttonsPayload = data["buttons"].arrayValue
            self.buttonsViewHeight.constant = CGFloat(buttonsPayload.count * 40)
            self.layoutIfNeeded()
            for buttonsData in buttonsPayload{
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonsView.frame.size.width, height: 40))
                let borderFrame = CGRect(x: 0, y: 0, width: buttonWidth, height: 0.5)
                let buttonBorder = UIView(frame: borderFrame)
                buttonBorder.backgroundColor = UIColor.white
                button.addSubview(buttonBorder)
                button.backgroundColor = ColorConfiguration.rightBubbleColor
                button.setTitle(buttonsData["label"].stringValue, for: .normal)
                button.setTitleColor(UIColor.white, for: .normal)
                button.tag = i
                button.addTarget(self, action:#selector(self.postback(sender:)), for: .touchUpInside)
                self.buttonsView.addArrangedSubview(button)
                i += 1
            }
        }else{
            guard let dataPayload = message.payload else {
                return
            }
            
            let data = JSON(dataPayload)
            let paramData = data["params"]

            self.buttonsViewHeight.constant = CGFloat(40)
            self.layoutIfNeeded()

            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.buttonsView.frame.size.width, height: 40))
            button.backgroundColor = ColorConfiguration.rightBubbleColor
            button.setTitle(paramData["button_text"].stringValue, for: .normal)
            button.setTitleColor(UIColor.white, for: .normal)
            button.tag = 2222
            button.addTarget(self, action:#selector(self.accountLinking(sender:)), for: .touchUpInside)

            self.buttonsView.addArrangedSubview(button)
        }
    }
    
    func setupBalon(message : QMessage){
        
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
    
    func status(message: QMessage){
        
        switch message.status {
        case .deleted:
            ivStatus.image = UIImage(named: "ic_deleted", in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            dateLabel.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            dateLabel.text = TextConfiguration.sharedInstance.sendingText
            ivStatus.image = UIImage(named: "ic_info_time",in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            dateLabel.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_sending", in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            dateLabel.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.sentOrDeliveredColor
            ivStatus.image = UIImage(named: "ic_read",in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .read:
            dateLabel.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read", in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case . failed:
            dateLabel.textColor = ColorConfiguration.timeLabelTextColor
            dateLabel.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning", in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            ivStatus.image = UIImage(named: "ic_deleted", in: MultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
}
