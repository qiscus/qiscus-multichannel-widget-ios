//
//  QismoNetworkManagerV2.swift
//  QiscusMultichannelWidget
//
//  Created by Rahardyan Bisma on 16/07/20.
//

import Foundation
import QiscusCore
import Alamofire
import SwiftyJSON

class QismoNetworkManager {
    
    var qiscus: QiscusCore
    var qiscusUser: QAccount?
    let urlInitiateChat = "https://qismo.qiscus.com/api/v2/qiscus/initiate_chat"
    let urlSessionChat = "https://qismo.qiscus.com"
    
    public init(qiscusCore : QiscusCore) {
        self.qiscus = qiscusCore
    }
    
    public func initiateChat(param: [String:Any], onSuccess: @escaping(String) -> Void, onError: @escaping(String) -> Void) {
        var mParam = param
        self.qiscus.getJWTNonce(onSuccess: { nonce in
            mParam.updateValue(nonce.nonce, forKey: "nonce")
            print("check param ini =\(mParam)")
            let request = AF.request(self.urlInitiateChat, method: .post, parameters: mParam, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                print("network result \(response.result)")
                
                let json = JSON(response.value)
                let identityToken = json["data"]["identity_token"].string ?? ""
                let isSecure = json["data"]["is_secure"].int ?? 0
                
                let roomId = json["data"]["customer_room"]["room_id"].string ?? ""
                let sessionId = json["data"]["customer_room"]["session_id"].string ?? ""
                
                let channelId = json["data"]["customer_room"]["channel_id"].int ?? 0
                let isResolved = json["data"]["customer_room"]["is_resolved"].bool ?? false
                
                SharedPreferences.saveNewChat(isNew: true)
                
                if channelId > 0 {
                    SharedPreferences.saveChannelId(id: channelId)
                }
                
                
                
                if sessionId.contains("<null>") ||  sessionId.contains("null") ||  sessionId.isEmpty == true{
                    //ignored
                }else{
                    SharedPreferences.saveIsSecure(isSecure: isSecure)
                    SharedPreferences.saveSessionId(sessionId: sessionId)
                }
                
                if identityToken.isEmpty || roomId.isEmpty {
                    return
                }
                
                //login sdk
                self.setQismoSdkUser(identityToken: identityToken, onSuccess: { [weak self] user in
                    //success login sdk
                    self?.qiscusUser = user
                    SharedPreferences.saveQiscusAccount(userEmail: self?.qiscusUser?.id ?? user.id)
                    onSuccess(roomId)
                }, onError: { qError in
                    debugPrint(qError.message)
                })

            }.cURLDescription { curl in
                print("initiate chat \(curl)")
            }

        }, onError: { error in
            print(error.message)
            onError(error.message)
        })
    }
    
    private func callInitiateChat(param: [String:Any], onSuccess: @escaping() -> Void, onError: @escaping() -> Void) {
        let url = "https://multichannel.qiscus.com/api/v1/qiscus/initiate_chat"
        AF.request(URL(string: url)!, method: .post, parameters: param)
            .responseJSON { json in
                
            }
    }
    
    public func setQismoSdkUser(identityToken: String, onSuccess: @escaping(QAccount) -> Void, onError: @escaping(QError) -> Void) {
        self.qiscus.setUserWithIdentityToken(token: identityToken, onSuccess: { user in
            onSuccess(user)
        }, onError: { qError in
            onError(qError)
        })
    }
    
    public func getQismoRoom(roomId: String, onSuccess: @escaping(QChatRoom) -> Void, onError: @escaping(QError) -> Void) {
        self.qiscus.shared.getChatRooms(roomIds: [roomId], onSuccess: { (room) in
            
        }) { (error) in
            
        }
        
    }
    
    public func getSessionChat(onSuccess: @escaping(Bool) -> Void, onError: @escaping(String) -> Void) {
        let request = AF.request("\(self.urlSessionChat)/\(self.qiscus.appID)/get_session", method: .get, parameters: nil, encoding: JSONEncoding.default)
        .validate()
        .responseJSON { response in
            print("network result \(response.result)")
            
            if response.response?.statusCode == 200 {
                let json = JSON(response.value)
                let session = json["data"]["is_sessional"].bool ?? false
                
                onSuccess(session)
            }else{
                onError("Something when wrong")
            }
           
        }.cURLDescription { curl in
            print("initiate chat \(curl)")
        }
    }
    
}

