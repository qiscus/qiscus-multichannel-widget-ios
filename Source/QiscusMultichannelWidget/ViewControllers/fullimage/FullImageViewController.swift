//
//  FullImageViewController.swift
//  QiscusMultichannelWidget
//
//  Created by qiscus on 17/03/20.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore

class FullImageViewController: UIViewController {
    
    @IBOutlet weak var ivImage: UIImageView!
    
    var message: QMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = ColorConfiguration.navigationColor
            appearance.titleTextAttributes = [.font: UIFont.boldSystemFont(ofSize: 18.0),
                                              .foregroundColor: UIColor.white]

            // Customizing our navigation bar
            navigationController?.navigationBar.tintColor =  ColorConfiguration.navigationColor
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }

        
        // Do any additional setup after loading the view.
        if message != nil {
            if let url = message!.payload?["url"] as? String {
                if self.ivImage.image == nil {
                    self.ivImage.af.setImage(withURL: URL(string: url)!)
                }
            } else if let url = self.getUrlFromMessage(message: message?.message ?? "") {
                if self.ivImage.image == nil {
                    self.ivImage.af.setImage(withURL: url)
                }
            }
            
            self.title = message?.fileName(text: message!.message)
            
            if let url = message!.payload?["replied_comment_payload"] as? [String:Any] {
                if let url = url["url"] as? String {
                    var fileImage = url
                    if fileImage.isEmpty == true {
                        fileImage = "https://"
                    }
                    if self.ivImage.image == nil {
                        self.ivImage.af.setImage(withURL: URL(string: fileImage)!)
                    }
                    self.title = message?.fileName(text: fileImage)
                }
            }
        }
        
        let backButton = self.backButton(self, action: #selector(FullImageViewController.goBack))
        backButton.qiscusHideSharedBackground()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(FullImageViewController.share))
        shareButton.tintColor = UIColor.white
        shareButton.qiscusHideSharedBackground()
        self.navigationItem.rightBarButtonItem = shareButton

    }
    
    private func getUrlFromMessage(message: String) -> URL? {
        let prefixRemoval = message.replacingOccurrences(of: "[file]", with: "")
        let suffixRemoval = prefixRemoval.replacingOccurrences(of: "[/file]", with: "")
        
        return URL(string: suffixRemoval.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    // MARK: - Navigation
    @objc func goBack(_ sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Custom Component
    func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
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


    @objc func share(){
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        
        if self.ivImage.image != nil {
            let file = [self.ivImage.image]
            let activityViewController = UIActivityViewController(activityItems: file, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            
            self.present(activityViewController, animated: true, completion: {
                
            })
            
            let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(FullImageViewController.share))
            shareButton.tintColor = UIColor.white
            shareButton.qiscusHideSharedBackground()
            self.navigationItem.rightBarButtonItem = shareButton
        }
        
    }

}
