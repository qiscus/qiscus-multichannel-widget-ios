//
//  QImagesLeftCell.swift
//  BBChat
//
//  Created by qiscus on 13/01/20.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore
import Alamofire
import AlamofireImage
import SDWebImage
import SwiftyJSON

class QImagesLeftCell: UIBaseChatCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbLoading: UILabel!
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameLeading: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var ivAvatarUser: UIImageView!
    var isPublic: Bool = false
    var menuConfig = enableMenuConfig()
    var colorName : UIColor = UIColor.black
    var message: QMessage? = nil
    
    var actionBlock: ((QMessage) -> Void)? = nil
    var imageRequest: DownloadRequest? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
         self.ivComment.layer.cornerRadius = 8
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QImagesLeftCell.imageDidTap))
        self.ivComment.addGestureRecognizer(imgTouchEvent)
        
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
        self.bindData(message: message)
    }
    
    override func update(message: QMessage) {
        self.bindData(message: message)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.ivComment.image = nil
    }
    
    
    func setupBalon(){
        self.ivComment.layer.cornerRadius = 5.0
        self.ivBaloonLeft.layer.cornerRadius = 5
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
        
        self.ivBaloonLeft.image = self.getBallon()
        self.ivBaloonLeft.tintColor = ColorConfiguration.leftBubbleColor
        ivBaloonLeft.backgroundColor = ColorConfiguration.leftBubbleColor
        
    }
    
    func bindData(message: QMessage) {
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        setupBalon()
        
        self.lbTime.text = AppUtil.dateToHour(date: message.timestamp)
        self.lbTime.textColor = ColorConfiguration.timeLabelTextColor
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        if let caption = caption {
            self.tvContent.text = caption
        }else{
            self.tvContent.text = ""
        }
        
        self.tvContent.textColor = ColorConfiguration.leftBubbleTextColor
        if let url = payload["url"] as? String {
            if let url = payload["url"] as? String {
                //self.showLoading()
                var fileImage = url
                if fileImage.isEmpty {
                    fileImage = "https://"
                }
                
                self.ivComment.backgroundColor = ColorConfiguration.leftBubbleColor
                
                if url.fileExtension(fromURL: url) == "gif"{
                    self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                    
                    QismoManager.shared.qiscus.shared.getThumbnailURL(url: fileImage) { url in
                        self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                            if urlPath != nil && uiImage != nil{
                                self.ivComment.af_setImage(withURL: urlPath!)
                                
                            }
                        }
                    } onError: { error in
                        self.ivComment.sd_setImage(with: URL(string: url) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                            if urlPath != nil && uiImage != nil{
                                self.ivComment.af_setImage(withURL: urlPath!)
                            }
                        }
                    }
                    
                }else{
                    self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                    self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                        if urlPath != nil && uiImage != nil{
                            self.ivComment.af_setImage(withURL: urlPath!)
                        }
                    }
                }
                
            }
        }else{
            var fileImage = message.getAttachmentURL(message: message.message)
            
            if fileImage.isEmpty {
                fileImage = "https://"
            }
            
            self.ivComment.backgroundColor = ColorConfiguration.leftBubbleColor
            
            self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                if urlPath != nil && uiImage != nil{
                    self.ivComment.af_setImage(withURL: urlPath!)
                }
            }
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
        
        
    }
    
    
    @objc func imageDidTap() {
        guard let selectedImage = self.ivComment.image else {
            print("Image not found!")
            return
        }
        if self.comment != nil && self.actionBlock != nil {
            self.actionBlock!(comment!)
        }
    }
    
}
