//
//  MultichannelWidgetConfig.swift
//  QiscusMultichannelWidget
//
//  Created by Rahardyan Bisma on 19/05/20.
//

#if os(iOS)
import UIKit
#endif
import Foundation

public enum RoomSubtitle: CaseIterable {
    case enable, disable
}

open class MultichannelWidgetConfig {
    var qismoInterceptorDelegate : QismoInterceptorDelegate? = nil
    private var avatar: String = ""
    private var extras: String = "" //string json
    var title: String = "Customer Service"
    var subtitle: String = ""
    var channelId: Int? = nil
    var enableSubtitle : Bool = ChatConfig.enableSubtitle
    private var rightBubblColor: UIColor = ColorConfiguration.rightBubbleColor
    private var leftBubblColor: UIColor = ColorConfiguration.leftBubbleColor
    private var navigationColor: UIColor = ColorConfiguration.navigationColor
    private var navigationTitleColor: UIColor = ColorConfiguration.navigationTitleColor
    private var systemBalloonColor: UIColor = ColorConfiguration.systemBubbleColor
    private var systemBalloonTextColor: UIColor = ColorConfiguration.systemBubbleTextColor
    private var timeBackgroundColor:UIColor = ColorConfiguration.timeBackgroundColor
    private var leftBubblTextColor: UIColor = ColorConfiguration.leftBubbleTextColor
    private var rightBubblTextColor: UIColor = ColorConfiguration.rightBubbleTextColor
    private var timeLabelTextColor: UIColor = ColorConfiguration.timeLabelTextColor
    private var sendContainerColor: UIColor = ColorConfiguration.sendContainerColor
    private var fieldChatBorderColor : UIColor = ColorConfiguration.fieldChatBorderColor
    private var sendContainerBackgroundColor: UIColor = ColorConfiguration.sendContainerBackgroundColor
    private var baseColor: UIColor = ColorConfiguration.baseColor
    private var emptyChatBackgroundColor: UIColor = ColorConfiguration.emptyChatBackgroundColor
    private var emptyChatTextColor: UIColor = ColorConfiguration.emptyChatTextColor
    private var showSystemMessage: Bool = ChatConfig.showSystemMessage
    
    //config for avatar bubble and sender
    private var showAvatarSender = true
    private var showUsernameSender = true
    
    //config for avatarRoom
    private var avatarRoom: String = ChatConfig.avatarRoom
    
    //config for notification
    private var enableNotification : Bool = ChatConfig.enableNotification
    
    public func setExtras(extras: String) -> MultichannelWidgetConfig {
        self.extras = extras
        return self
    }
    
    public func setAvatar(avatarUrl: String) -> MultichannelWidgetConfig {
           self.avatar = avatarUrl
           return self
       }
    
    public func setRightBubbleColor(color: UIColor) -> MultichannelWidgetConfig {
        self.rightBubblColor = color
        return self
    }
    
    public func setRightBubbleTextColor(color: UIColor) -> MultichannelWidgetConfig {
        self.rightBubblTextColor = color
        return self
    }
    
    public func setLeftBubbleColor(color: UIColor) -> MultichannelWidgetConfig {
        self.leftBubblColor = color
        return self
    }
    
    public func setLeftBubbleTextColor(color: UIColor) -> MultichannelWidgetConfig {
        self.leftBubblTextColor = color
        return self
    }
    
    public func setTimeLabelTextColor(color: UIColor) -> MultichannelWidgetConfig {
        self.timeLabelTextColor = color
        return self
    }
    
    public func setTimeBackgroundColor(color: UIColor) -> MultichannelWidgetConfig {
        self.timeBackgroundColor = color
        return self
    }
    
    public func setSystemEventTextColor(color: UIColor) -> MultichannelWidgetConfig {
        self.systemBalloonTextColor = color
        return self
    }
    
    
    public func setNavigationColor(color: UIColor) -> MultichannelWidgetConfig {
        self.navigationColor = color
        return self
    }
    
    public func setEnableNotification(enableNotification : Bool) -> MultichannelWidgetConfig{
        self.enableNotification = enableNotification
        
        if !QismoManager.shared.deviceToken.isEmpty{
            if self.enableNotification == true {
                QismoManager.shared.register(deviceToken: QismoManager.shared.deviceToken, isDevelopment: QismoManager.shared.isDevelopment) { (isSuccess) in
                    
                } onError: { (error) in
                    
                }
            }else{
                QismoManager.shared.remove(deviceToken: QismoManager.shared.deviceToken, isDevelopment: QismoManager.shared.isDevelopment) { (isSuccess) in
                    
                } onError: { (error) in
                    
                }

            }
        }
        
        return self
    }
    
    public func setRoomTitle(title: String) -> MultichannelWidgetConfig {
        self.title = title
        return self
    }
    
    public func setChannelId(channelId: Int) -> MultichannelWidgetConfig {
        self.channelId = channelId
        return self
    }
    
    public func setRoomSubTitle(enableSubtitle : RoomSubtitle = RoomSubtitle.enable, subTitle : String) -> MultichannelWidgetConfig {
        self.subtitle = subTitle
        if enableSubtitle == .enable {
            self.enableSubtitle = true
        }else{
            self.enableSubtitle = false
        }
        
        return self
    }
    
    public func setNavigationTitleColor(color: UIColor) -> MultichannelWidgetConfig {
        self.navigationTitleColor = color
        return self
    }
    
    public func setBaseColor(color: UIColor) -> MultichannelWidgetConfig {
        self.baseColor = color
        return self
    }
    
    public func setEmptyBackgroundColor(color: UIColor) -> MultichannelWidgetConfig {
        self.emptyChatBackgroundColor = color
        return self
    }
    
    public func setEmptyTextColor(color: UIColor) -> MultichannelWidgetConfig {
        self.emptyChatTextColor = color
        return self
    }
    
    @available(*, deprecated, message: "Please replace with setHideUIEvent")
    public func setShowSystemMessage(isShowing: Bool) -> MultichannelWidgetConfig {
        self.showSystemMessage = isShowing
        return self
    }
    
    public func setHideUIEvent(showSystemEvent: Bool) -> MultichannelWidgetConfig {
        self.showSystemMessage = showSystemEvent
        return self
    }
    
    public func setAvatar(isShowing: Bool) -> MultichannelWidgetConfig {
        self.showAvatarSender = isShowing
        return self
    }
    
    public func setShowAvatarSender(isShowing: Bool) -> MultichannelWidgetConfig {
        self.showAvatarSender = isShowing
        return self
    }
    
    public func setShowUsernameSender(isShowing: Bool) -> MultichannelWidgetConfig {
        self.showUsernameSender = isShowing
        return self
    }
    
    public func setSendContainerColor(color: UIColor) -> MultichannelWidgetConfig {
        self.sendContainerColor = color
        return self
    }
    
    public func setFieldChatBorderColor(color: UIColor) -> MultichannelWidgetConfig {
        self.fieldChatBorderColor = color
        return self
    }
    
    public func setSendContainerBackgroundColor(color: UIColor) -> MultichannelWidgetConfig {
        self.sendContainerBackgroundColor = color
        return self
    }
    
    
    
    public func startChat(callback: @escaping (UIViewController) -> Void) {
        ColorConfiguration.navigationColor = self.navigationColor
        ColorConfiguration.navigationTitleColor = self.navigationTitleColor
        ColorConfiguration.rightBubbleColor = self.rightBubblColor
        ColorConfiguration.leftBubbleColor = self.leftBubblColor
        ColorConfiguration.systemBubbleColor = self.systemBalloonColor
        ColorConfiguration.systemBubbleTextColor = self.systemBalloonTextColor
        ColorConfiguration.leftBubbleTextColor = self.leftBubblTextColor
        ColorConfiguration.rightBubbleTextColor = self.rightBubblTextColor
        ColorConfiguration.timeLabelTextColor = self.timeLabelTextColor
        ColorConfiguration.sendContainerColor = self.sendContainerColor
        ColorConfiguration.fieldChatBorderColor = self.fieldChatBorderColor
        ColorConfiguration.timeBackgroundColor = self.timeBackgroundColor
        ColorConfiguration.baseColor = self.baseColor
        ColorConfiguration.emptyChatTextColor = self.emptyChatTextColor
        ColorConfiguration.emptyChatBackgroundColor = self.emptyChatBackgroundColor
        ColorConfiguration.sendContainerBackgroundColor = self.sendContainerBackgroundColor
        
        ChatConfig.showSystemMessage = self.showSystemMessage
        ChatConfig.showAvatarSender = self.showAvatarSender
        ChatConfig.showUserNameSender = self.showUsernameSender
        ChatConfig.enableSubtitle = self.enableSubtitle
        
        QismoManager.shared.qismoInterceptor = self.qismoInterceptorDelegate
        
        SharedPreferences.saveExtrasMultichannelConfig(extras: self.extras)
        if let channelId = self.channelId {
            SharedPreferences.saveChannelId(id: channelId)
        }
        
        QismoManager.shared.initiateChat(withTitle: self.title, andSubtitle: self.subtitle, extras: self.extras, callback: callback)
    }
    
    public func startChat(withRoomId id: String, callback: @escaping (UIViewController) -> Void) {
        ColorConfiguration.navigationColor = self.navigationColor
        ColorConfiguration.navigationTitleColor = self.navigationTitleColor
        ColorConfiguration.rightBubbleColor = self.rightBubblColor
        ColorConfiguration.leftBubbleColor = self.leftBubblColor
        ColorConfiguration.systemBubbleColor = self.systemBalloonColor
        ColorConfiguration.systemBubbleTextColor = self.systemBalloonTextColor
        ColorConfiguration.leftBubbleTextColor = self.leftBubblTextColor
        ColorConfiguration.rightBubbleTextColor = self.rightBubblTextColor
        ColorConfiguration.timeLabelTextColor = self.timeLabelTextColor
        ColorConfiguration.sendContainerColor = self.sendContainerColor
        ColorConfiguration.fieldChatBorderColor = self.fieldChatBorderColor
        ColorConfiguration.timeBackgroundColor = self.timeBackgroundColor
        ColorConfiguration.baseColor = self.baseColor
        ColorConfiguration.emptyChatTextColor = self.emptyChatTextColor
        ColorConfiguration.emptyChatBackgroundColor = self.emptyChatBackgroundColor
        ColorConfiguration.sendContainerBackgroundColor = self.sendContainerBackgroundColor
        
        ChatConfig.showSystemMessage = self.showSystemMessage
        ChatConfig.showAvatarSender = self.showAvatarSender
        ChatConfig.showUserNameSender = self.showUsernameSender
        ChatConfig.enableSubtitle = self.enableSubtitle
        
        ChatConfig.showAvatarSender = self.showAvatarSender
        ChatConfig.showUserNameSender = self.showUsernameSender
        SharedPreferences.saveExtrasMultichannelConfig(extras: self.extras)
        if let channelId = self.channelId {
            SharedPreferences.saveChannelId(id: channelId)
        }
        
        QismoManager.shared.qismoInterceptor = self.qismoInterceptorDelegate
       
        QismoManager.shared.chatViewController(withRoomId: id, Title: self.title, andSubtitle: self.subtitle) { (chatview) in
            callback(chatview)
        }
    }
    
    public func setQismoInterceptor(delegate : QismoInterceptorDelegate?) -> MultichannelWidgetConfig {
        self.qismoInterceptorDelegate = delegate
        return self
    }
}
