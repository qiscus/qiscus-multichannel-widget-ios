//
//  ChatManager.swift
//  Example
//
//  Created by arief nur putranto on 23/05/25.
//

import Foundation
import UIKit
import QiscusMultichannelWidget
import QiscusCore

enum ChatTransitionType {
    case push(animated: Bool)
    case present(animated: Bool, completion: (() -> Void)? = nil)
}

final class ChatManager {
    static let shared: ChatManager = ChatManager()
    lazy var qiscusWidget: QiscusMultichannelWidget = {
       return QiscusMultichannelWidget(appID: YOUR_APPID)
    }()
    
    func setUser(id: String, displayName: String, avatarUrl: String = "", userProperties :  [[String:Any]]? = nil) {
        qiscusWidget.setUser(id: id, displayName: displayName, avatarUrl: avatarUrl, userProperties: userProperties)
    }
    
    func getUser() ->QAccount?{
        return qiscusWidget.getUser()
    }
    
    func signOut() {
        qiscusWidget.clearUser()
    }
    
    func isLoggedIn() -> Bool {
        return qiscusWidget.isLoggedIn()
    }
    
    func startChat(from viewController: UIViewController, extras: String = "", transition: ChatTransitionType = .push(animated: true)) {
        
//        //test 1
        //qiscusWidget.automaticSendMessage(textMessage: "https://github.com/qiscus/qiscus-multichannel-widget-ios")
//
//        //test2
//        let messageModel = QMessage()
//        messageModel.message = "testing2"
//
//        qiscusWidget.automaticSendMessage(qMessage: messageModel)
//
//
//        //test 3
//        qiscusWidget.manualSendMessage(textMessage: "testing manual")
        
        qiscusWidget.initiateChat()
           // .setChannelId(channelId: environment.channelIdQiscusOmnichannel)
                        .setRoomTitle(title: "ELSA")
                        //.setRightBubbleColor(color: Colors.UI.paleBlack)
                       // .setAvatar(avatarUrl: imageUrl)
                        .setEnableNotification(enableNotification: true)
                        .setAvatar(isShowing: true)
                        //.setSendContainerColor(color: Colors.UI.orangeSelected)
                        .setShowUsernameSender(isShowing: false)
                        .setShowAvatarSender(isShowing: false)
                        .setHideUIEvent(showSystemEvent: false)
                        .setRoomSubTitle(enableSubtitle: .disable, subTitle: "")
                        .setQismoInterceptor(delegate: self)
//            .setRoomTitle(title: "TITLE".localized())
//            .setSystemEventTextColor(color: UIColor.red)
//            .setTimeBackgroundColor(color: UIColor.blue)
//            .setRoomSubTitle(enableSubtitle: RoomSubtitle.enable, subTitle: "SUBTITLE".localized())
            .startChat { (chatViewController) in
                viewController.navigationController?.setViewControllers([viewController, chatViewController], animated: true)
                
//                let navigationController = UINavigationController(rootViewController: chatViewController)
//
//                viewController.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    func register(deviceToken: Data?) {
        if let deviceToken = deviceToken {
            var tokenString: String = ""
            for i in 0..<deviceToken.count {
                tokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
            }
            print("token = \(tokenString)")
            //isDevelopment = true : for development or running from XCode
            //isDevelopment = false : release mode TestFlight or appStore
            
            self.qiscusWidget.register(deviceToken: tokenString, isDevelopment : false, onSuccess: { (response) in
                print("Multichannel widget success to register device token")
            }) { (error) in
                print("Multichannel widget failed to register device token")
            }
        }
    }
    
    
    func userTapNotification(userInfo : [AnyHashable : Any]) {
        self.qiscusWidget.handleNotification(userInfo: userInfo, removePreviousNotif: true)
//        .startChat(withRoomId: <#T##String#>, callback: <#T##(UIViewController) -> Void#>)
    }
}

extension ChatManager : QismoInterceptorDelegate {
    func interceptBeforeSendMessage(_ message: QMessage, onUpdateMessage: @escaping (QMessage) -> Void) {
        
        onUpdateMessage(message)
    }
}
