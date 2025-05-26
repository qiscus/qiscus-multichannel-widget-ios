//
//  QImagesRightCell.swift
//  BBChat
//
//  Created by qiscus on 14/01/20.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore
import Alamofire
import SwiftyJSON
import AlamofireImage
import SDWebImage

class QImagesRightCell: UIBaseChatCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var tvContent: UILabel!
    @IBOutlet weak var ivBaloonLeft: UIImageView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var ivStatus: UIImageView!
    @IBOutlet weak var ivComment: UIImageView!
    
    @IBOutlet weak var lbNameHeight: NSLayoutConstraint!
    @IBOutlet weak var lbNameTrailing: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    var menuConfig = enableMenuConfig()
    @IBOutlet weak var ivLoading: UIImageView!
    @IBOutlet weak var lbLoading: UILabel!
    var isQiscus : Bool = false
    var message: QMessage? = nil
    
    var actionBlock: ((QMessage) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setMenu()
        self.ivComment.contentMode = .scaleAspectFill
        self.ivComment.clipsToBounds = true
        self.ivComment.backgroundColor = UIColor.black
        self.ivComment.layer.cornerRadius = 8
        self.ivComment.isUserInteractionEnabled = true
        let imgTouchEvent = UITapGestureRecognizer(target: self, action: #selector(QImagesRightCell.imageDidTap))
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
        ivComment.image = nil
    }
    
    func setupBalon(){
        self.lbNameHeight.constant = 20
        self.ivBaloonLeft.tintColor = ColorConfiguration.rightBubbleColor
        self.ivBaloonLeft.backgroundColor = ColorConfiguration.rightBubbleColor
        self.ivBaloonLeft.layer.cornerRadius = 5.0
        self.lbName.textColor = ColorConfiguration.rightBubbleColor
        self.ivBaloonLeft.image = self.getBallon()
        self.ivComment.layer.cornerRadius = 5.0
        self.ivComment.clipsToBounds = true
        self.ivComment.contentMode = .scaleAspectFill
        
    }
    
    private func getUrlFromMessage(message: String) -> URL? {
        let prefixRemoval = message.replacingOccurrences(of: "[file]", with: "")
        let suffixRemoval = prefixRemoval.replacingOccurrences(of: "[/file]", with: "")
        
        return URL(string: suffixRemoval.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func bindData(message: QMessage) {
        self.message = message
        self.contentView.backgroundColor = UIColor.clear
        self.setupBalon()
        self.status(message: message)
        // get image
        self.lbTime.text = AppUtil.dateToHour(date: message.timestamp)
        guard let payload = message.payload else { return }
        let caption = payload["caption"] as? String
        
        if let caption = caption {
            self.tvContent.text = caption
        }else{
            self.tvContent.text = ""
        }
        
        self.tvContent.textColor = ColorConfiguration.rightBubbleTextColor
        if let url = payload["url"] as? String {
            if let url = payload["url"] as? String {
                //self.showLoading()
                var fileImage = url
                if fileImage.isEmpty {
                    fileImage = "https://"
                }
                
                self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
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
            self.ivComment.backgroundColor = #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
            
            self.ivComment.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            self.ivComment.sd_setImage(with: URL(string: fileImage) ?? URL(string: "https://"), placeholderImage: nil, options: .highPriority) { (uiImage, error, cache, urlPath) in
                if urlPath != nil && uiImage != nil{
                    self.ivComment.af_setImage(withURL: urlPath!)
                }
            }
            
        }
        
        self.lbNameHeight.constant = 0 
        
    }
    
    func status(message: QMessage){
        
        switch message.status {
        case .deleted:
            //            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sending, .pending:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.timeLabelTextColor
            ivStatus.image = UIImage(named: "ic_info_time", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .sent:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.timeLabelTextColor
            ivStatus.image = UIImage(named: "ic_sending", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        case .delivered:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.timeLabelTextColor
            ivStatus.image = UIImage(named: "ic_read", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
            break
        case .read:
            lbTime.textColor = ColorConfiguration.timeLabelTextColor
            ivStatus.tintColor = ColorConfiguration.readMessageColor
            ivStatus.image = UIImage(named: "ic_read", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            
            break
        case . failed:
            lbTime.textColor = ColorConfiguration.failToSendColor
            lbTime.text = TextConfiguration.sharedInstance.failedText
            ivStatus.image = UIImage(named: "ic_warning", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            ivStatus.tintColor = ColorConfiguration.failToSendColor
            break
        case .deleting:
            //            ivStatus.image = UIImage(named: "ic_deleted", in: QiscusMultichannelWidget.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            break
        }
    }
    
    @objc func imageDidTap() {
        if self.comment != nil && self.actionBlock != nil {
            self.actionBlock!(comment!)
        }
    }
    
}
