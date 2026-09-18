//
//  WebFileViewController.swift
//  QiscusMultichannelWidget
//
//  Created by Rahardyan Bisma on 30/06/20.
//

import UIKit
import WebKit

class WebFileViewController: UIViewController {
    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    var webView: WKWebView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()
    
    var fileUrl: String?
    var localFileUrl: URL?
    var fileName: String = "File Attachment"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.webView)
        self.view.addSubview(self.activityIndicator)
        self.webView.navigationDelegate = self
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.title = fileName
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
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.webView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                self.webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
                self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ])
        }
        
        guard let localFileUrl = self.localFileUrl else {
            guard let fileUrl = self.fileUrl, let url = URL(string: fileUrl) else {
                return
            }
            
            webView.load(URLRequest(url: url))
            return
        }
        
        
        webView.loadFileURL(localFileUrl, allowingReadAccessTo: localFileUrl)
        
        let backButton = self.backButton(self, action: #selector(WebFileViewController.goBack))
        backButton.qiscusHideSharedBackground()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
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


}

extension WebFileViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
}
