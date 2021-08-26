//
//  Qismo.swift
//  Alamofire
//
//  Created by asharijuang on 08/01/20.
//

import Foundation
#if os(iOS)
import UIKit
#endif
import Alamofire
import QiscusCore

public class QiscusMultichannelWidget {
    
    static var bundle:Bundle{
        get{
            let podBundle = Bundle(for: QiscusMultichannelWidget.self)
            
            if let bundleURL = podBundle.url(forResource: "QiscusMultichannelWidget", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    
    let widgetConfig: MultichannelWidgetConfig
    let manager : QismoManager = QismoManager.shared
    
    var reachability: WidgetReachability?
    
    public init(appID: String) {
        self.manager.setup(appID: appID)
        self.widgetConfig = MultichannelWidgetConfig()
    }
    
    public func setUser(id: String, displayName: String, avatarUrl: String = "") {
        self.manager.setUser(id: id, username: displayName, avatarUrl: avatarUrl)
    }
    
    public func getUser() -> QAccount?{
        return self.manager.getUser()
    }
    
    
    /// Clear all user data or logout
    public func clearUser() {
        self.manager.clear()
    }
    
    @available(*, deprecated, message: "Please replace with initiateChat")
    public func prepareChat(withTitle title: String, andSubtitle subtitle: String) -> MultichannelWidgetConfig {
        widgetConfig.title = title
        widgetConfig.subtitle = subtitle
        return widgetConfig
    }
    
    public func initiateChat() -> MultichannelWidgetConfig {
        return widgetConfig
    }
    
    public func register(deviceToken token: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (String) -> Void){
        manager.register(deviceToken: token, onSuccess: onSuccess, onError: onError)
    }
    
    public func remove(deviceToken token: String, onSuccess: @escaping (Bool) -> Void, onError: @escaping (String) -> Void){
        manager.remove(deviceToken: token, onSuccess: onSuccess, onError: onError)
    }
    
    public func isLoggedIn() -> Bool {
        return manager.qiscus.isLogined
    }
    
    public func isMultichannelNotification(userInfo: [String:Any]) -> Bool {
        // check app id
        return false
    }
    
    public func isMultichannelNotification(userInfo: [AnyHashable : Any]) -> Bool {
        return manager.isMultichannelNotification(userInfo: userInfo)
    }
    
    public func handleNotification(userInfo : [AnyHashable : Any], removePreviousNotif: Bool) {
        manager.handleNotification(userInfo: userInfo, removePreviousNotif: removePreviousNotif)
    }
    
    
}
