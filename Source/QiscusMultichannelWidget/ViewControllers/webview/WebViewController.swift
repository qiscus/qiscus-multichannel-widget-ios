//
//  WebViewController.swift
//  Pods
//
//  Created by qiscus on 07/04/20.
//

#if os(iOS)
import UIKit
#endif
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var url: String?

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
        if url == nil {
            self.dismiss(animated: true, completion: nil)
        }
        let myRequest = URLRequest(url: URL(string: url!)!)
        webView.load(myRequest)
        
        let backButton = self.backButton(self, action: #selector(WebViewController.goBack))
        backButton.qiscusHideSharedBackground()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.title = "Web Preview"
    }
    
    override func loadView() {
       let webConfiguration = WKWebViewConfiguration()
       webView = WKWebView(frame: .zero, configuration: webConfiguration)
       webView.uiDelegate = self
       view = webView
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
