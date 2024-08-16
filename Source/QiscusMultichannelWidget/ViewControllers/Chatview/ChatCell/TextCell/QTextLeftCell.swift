//
//  QTextLeftCell.swift
//  Qiscus
//
//  Created by asharijuang on 04/09/18.
//

#if os(iOS)
import UIKit
#endif

import QiscusCore

class QTextLeftCell: UIBaseChatCell, UITextViewDelegate {
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var ivBubbleLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var tvContent2: UITextView!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var ivAvatarUser: UIImageView!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    var openUrl: ((URL) -> Void)? = nil
    @IBOutlet weak var leftWidthConstUsername: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.tvContent2.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setMenu()
        // Configure the view for the selected state
        self.tvContent2.delegate = self
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
        
        self.lbTime.text = AppUtil.dateToHour(date: message.date())
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        
        let attributedString = NSAttributedString(string: message.message,
                                                  attributes: [
                                                    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                    NSAttributedString.Key.foregroundColor : ColorConfiguration.leftBubbleTextColor,
                                                    NSAttributedString.Key.underlineColor : ColorConfiguration.leftBubbleTextColor,
        ])
        
        let attributes: [NSAttributedString.Key: Any] = [
            .underlineColor: ColorConfiguration.leftBubbleTextColor,
            .font: UIFont.systemFont(ofSize: 14),
            .underlineStyle: NSUnderlineStyle.single.rawValue | NSUnderlineStyle.single.rawValue
        ]
        
        self.tvContent2.attributedText = attributedString
        self.tvContent2.linkTextAttributes = attributes
        self.tvContent2.textColor = ColorConfiguration.leftBubbleTextColor
        
        if(isPublic == true){
            self.lbName.text = message.sender.name
            self.lbName.textColor = colorName
            self.lbName.isHidden = false
            lbNameHeight.constant = 21
        }else{
            self.lbName.text = ""
            self.lbName.isHidden = true
            lbNameHeight.constant = 0
        }
        
        if ChatConfig.showAvatarSender == true{
            self.leftWidthConstUsername.constant = 65
            self.ivAvatarUser.isHidden = false
        }else{
            self.leftWidthConstUsername.constant = 20
            self.ivAvatarUser.isHidden = true
        }
        
        if ChatConfig.showUserNameSender == true {
            self.lbName.isHidden = false
            self.lbNameHeight.constant = 21
        }else{
            self.lbName.isHidden = true
            self.lbNameHeight.constant = 0
        }
        
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
    }
    
    func setupBalon(){
        self.ivBubbleLeft.applyShadow()
        self.ivBubbleLeft.image = self.getBallon()
        self.ivBubbleLeft.tintColor = ColorConfiguration.leftBubbleColor
        self.ivBubbleLeft.backgroundColor = ColorConfiguration.leftBubbleColor
        self.ivBubbleLeft.layer.cornerRadius = 5.0
        self.ivBubbleLeft.clipsToBounds = true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if openUrl != nil {
            self.openUrl!(URL)
        }
        return false
    }

}
