//
//  ChatPreviewDocVC.swift
//  QiscusMultichannelWidget
//
//  Created by Qiscus on 23/07/21.
//

import UIKit
import WebKit
import SwiftyJSON
import QiscusCore



class ChatPreviewDocVC: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    @IBOutlet weak var heightProgressViewCons: NSLayoutConstraint!
    @IBOutlet weak var labelProgress: UILabel!
    @IBOutlet weak var progressViewShare: UIView!
    @IBOutlet weak var containerProgressView: UIView!
    
    var webView = WKWebView()
    var url: String = ""
    var fileName: String = ""
    var progressView = UIProgressView(progressViewStyle: UIProgressView.Style.bar)
    var roomName:String = ""
    
    var accountLinking = false
    var accountData:JSON?
    var accountLinkURL:String = ""
    var accountRedirectURL:String = ""
    
    init() {
        super.init(nibName: "ChatPreviewDocVC", bundle: QiscusMultichannelWidget.bundle)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        //self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    // MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.navigationDelegate = self
       // self.webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        if !self.accountLinking {
            let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(ChatPreviewDocVC.share))
            shareButton.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = shareButton
        }
        
        
        let backButton = self.backButton(self, action: #selector(ChatPreviewDocVC.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 7/255, green: 185/255, blue: 155/255, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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

        
        if !accountLinking {
            self.navigationItem.setTitleWithSubtitle(title: self.roomName, subtitle: self.fileName)
        }else{
            if let data = accountData {
                self.title = data["params"]["view_title"].string ?? ""
                self.accountLinkURL = data["url"].string ?? "https://"
                self.accountRedirectURL = data["redirect_url"].string ?? "https://"
            }
        }
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(webView)
        self.view.addSubview(progressView)
        
        let constraints = [
            NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.progressView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            
        ]
        view.addConstraints(constraints)
        view.layoutIfNeeded()
        
        //self.webView.backgroundColor = UIColor.red
        
        if self.url.isEmpty == true {
            self.url = "https://"
        }
        
        if !self.accountLinking{
            if let openURL = URL(string: self.url.replacingOccurrences(of: " ", with: "%20")){
                self.webView.load(URLRequest(url: openURL))
                
                
                
            }
        }else{
            if let openURL = URL(string:  self.accountLinkURL.replacingOccurrences(of: " ", with: "%20")) {
                self.webView.load(URLRequest(url: openURL))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.progressView.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - WebView Delegate
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let objectSender = object as? WKWebView {
            if (keyPath! == "estimatedProgress") && (objectSender == self.webView) {
                progressView.isHidden = self.webView.estimatedProgress == 1
                progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
            }else{
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.progressView.progress = 0.0
            //self.setupTableMessage(error.localizedDescription)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
        if self.accountLinking {
            if let urlToLoad = webView.url {
                let urlString = urlToLoad.absoluteString
                if urlString == self.accountRedirectURL.replacingOccurrences(of: " ", with: "%20") {
                    let _ = self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.progressView.isHidden = true
        
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
        self.navigationItem.rightBarButtonItem = nil
        UIBarButtonItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.systemBlue], for: .normal)
        
        UIButton.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = UIColor.systemBlue
        
        self.view.bringSubviewToFront(self.containerProgressView)
        self.containerProgressView.isHidden = false
        self.labelProgress.isHidden = false
        self.progressViewShare.isHidden = false
        self.labelProgress.text = "0 %"
        var progressCount = 0
        if let url = URL(string: url) {
            DispatchQueue.global(qos: .background).sync {
                QismoManager.shared.qiscus.shared.download(url: url) { path in
                    
                    DispatchQueue.main.async {
                        self.containerProgressView.isHidden = true
                        self.labelProgress.isHidden = true
                        self.progressViewShare.isHidden = true
                        
                        
                        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(ChatPreviewDocVC.share))
                        shareButton.tintColor = UIColor.white
                        self.navigationItem.rightBarButtonItem = shareButton
                        
                        let file = [path]
                        let activityViewController = UIActivityViewController(activityItems: file, applicationActivities: nil)
                        activityViewController.popoverPresentationController?.sourceView = self.view
                        
                        self.present(activityViewController, animated: true, completion: {
                            
                        })
                    }
                    
                   
                } onProgress: { progress in
                    if progressCount < (Int(progress * 100)) {
                        progressCount = (Int(progress * 100))
                        DispatchQueue.main.async {
                            self.labelProgress.text = "\(Int(progress * 100)) %"
                            self.heightProgressViewCons.constant = CGFloat(50)
                            UIView.animate(withDuration: 0.65, animations: {
                                self.progressViewShare.layoutIfNeeded()
                            })
                        }
                    }
                }
            }
        }
    }
}
