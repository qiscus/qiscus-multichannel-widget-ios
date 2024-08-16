//
//  QTextRightCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

#if os(iOS)
import UIKit
#endif

import QiscusCore

class QTextRightCell: UIBaseChatCell, UITextViewDelegate {

    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var ivBubbleLeft: UIImageView!
    
        @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    
    var actionBlock: ((QMessage) -> Void)? = nil
    var openUrl: ((URL) -> Void)? = nil
    var menuConfig = enableMenuConfig()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.tvContent.delegate = self
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
        self.setupBalon()
        self.status(message: message)
        
        let attributedString = NSAttributedString(string: message.message,
                                                  attributes: [
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                    NSAttributedString.Key.foregroundColor : ColorConfiguration.rightBubbleTextColor,
                                                    NSAttributedString.Key.underlineColor : ColorConfiguration.rightBubbleTextColor,
        ])
        
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineColor: ColorConfiguration.rightBubbleTextColor,
            .font: UIFont.systemFont(ofSize: 14),
            .underlineStyle: NSUnderlineStyle.single.rawValue | NSUnderlineStyle.single.rawValue
        ]
        
      
        
        self.lbName.text = "You"
        self.lbTime.text = AppUtil.dateToHour(date: message.date())
        self.tvContent.attributedText = attributedString
        self.tvContent.linkTextAttributes = attributes
        self.tvContent.textColor = ColorConfiguration.rightBubbleTextColor
        self.lbNameHeight.constant = 0
        self.ivBubbleLeft.layer.cornerRadius = 5.0
        self.ivBubbleLeft.clipsToBounds = true
    }
    
    func setupBalon(){
        //self.ivBubbleLeft.applyShadow()
        self.ivBubbleLeft.image = self.getBallon()
        self.ivBubbleLeft.tintColor = ColorConfiguration.rightBubbleColor
        self.ivBubbleLeft.backgroundColor = ColorConfiguration.rightBubbleColor
    }
    
    func status(message: QMessage){
        
        switch message.status {
        case .deleted:
//            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
//            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
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
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if openUrl != nil {
            self.openUrl!(URL)
        }
        return false
    }
    
}
