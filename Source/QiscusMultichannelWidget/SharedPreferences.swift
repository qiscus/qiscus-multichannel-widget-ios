//
//  SharedPreferences.swift
//  Pods
//
//  Created by qiscus on 26/04/20.
//

import Foundation

class SharedPreferences {
    
    static let defaults = UserDefaults.standard
    
    static func saveDeletedComment(uniqueId: String) {
        var deletedCommentUIDs = SharedPreferences.getDeletedCommentUniqueId() ?? []
        
        if deletedCommentUIDs.contains(uniqueId) {
            return
        }
        
        deletedCommentUIDs.append(uniqueId)
        defaults.setValue(deletedCommentUIDs, forKeyPath: "deleted_comment_uniqueid")
    }
    
    static func saveRoomId(id: String) {
        defaults.set(id, forKey: "multichannel_room_id")
    }
    
    static func saveChannelId(id: Int) {
        defaults.set(id, forKey: "multichannel_channel_id")
    }
    
    static func getChannelId() -> Int? {
        return defaults.integer(forKey: "multichannel_channel_id")
    }
    
    static func saveIsSecure(isSecure: Int) {
        defaults.set(isSecure, forKey: "multichannel_is_secure")
    }
    
    static func getIsSecure() -> Int? {
        return defaults.integer(forKey: "multichannel_is_secure")
    }
    
    static func saveSessionId(sessionId: String) {
        defaults.set(sessionId, forKey: "multichannel_session_id")
    }
    
    static func getSessionId() -> String? {
        return defaults.string(forKey: "multichannel_session_id")
    }
    
    static func saveNewChat(isNew: Bool) {
        defaults.set(isNew, forKey: "multichannel_is_new_chat")
    }
    
    static func getNewChat() -> Bool {
        return defaults.bool(forKey: "multichannel_is_new_chat")
    }
    
    static func getDeletedCommentUniqueId() -> [String]? {
        return defaults.array(forKey: "deleted_comment_uniqueid") as? [String]
    }
    
    static func getRoomId() -> String? {
        return defaults.string(forKey: "multichannel_room_id")
    }
    
    static func saveTitle(title: String) {
        defaults.set(title, forKey: "multichannel_title")
    }
    
    static func getTitle() -> String {
        return defaults.string(forKey: "multichannel_title") ?? ""
    }
    
    static func saveSubtitle(subtitle: String) {
          defaults.set(subtitle, forKey: "multichannel_subtitle")
    }
    
    static func getSubtitle() -> String {
        return defaults.string(forKey: "multichannel_subtitle") ?? ""
    }
    
    static func saveExtras(extras: String) {
        defaults.set(extras, forKey: "multichannel_extras")
    }
    
    static func getExtras() -> String {
        return defaults.string(forKey: "multichannel_extras") ?? ""
    }
    
    static func saveExtrasMultichannelConfig(extras: String) {
        defaults.set(extras, forKey: "multichannel_extras_config")
    }
    
    static func getExtrasMultichannelConfig() -> String {
        return defaults.string(forKey: "multichannel_extras_config") ?? ""
    }
    
    static func saveParam(param: [String:Any]) {
        defaults.set(param, forKey: "multichannel_param")
    }
    
    static func getParam() -> [String: Any]? {
        return defaults.dictionary(forKey: "multichannel_param")
    }
    
    static func saveQiscusAccount(userEmail: String) {
        defaults.set(userEmail, forKey: "multichannel_qiscus_account")
    }
    
    static func getQiscusAccount() -> String? {
        defaults.string(forKey: "multichannel_qiscus_account")
    }
    
    static func removeRoomId() {
        defaults.set(nil, forKey: "multichannel_room_id")
    }
    
    static func removeChannelId() {
        defaults.set(nil, forKey: "multichannel_channel_id")
    }
    
    static func removeExtrasMultichannelConfig() {
        defaults.set("", forKey: "multichannel_extras_config")
    }
    
    static func removeQiscusAccount() {
        defaults.removeObject(forKey: "multichannel_qiscus_account")
    }
    
    static func removeSessionId() {
        defaults.removeObject(forKey: "multichannel_session_id")
    }
    
    static func removeSecureId() {
        defaults.removeObject(forKey: "multichannel_is_secure")
    }
}
