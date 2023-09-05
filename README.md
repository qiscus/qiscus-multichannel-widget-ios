# [Widget] Documentation iOS

## Requirements

* iOS 10.0+
* minimum Xcode 11.4
* Swift 5

## Dependency

* Alamofire
* AlamofireImage
* SwiftyJSON
* QiscusCoreAPI
* SDWebImage

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate QiscusMultichannelWidget into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
pod 'QiscusMultichannelWidget', '~> 2.2.2'
```

## How To Use

### Initialization

In order to use `QiscusMultichannelWidge`t, you need to initialize it with your AppID (`YOUR_APP_ID`). Get more information to get AppID from [Qiscus Multichannel Chat page](https://multichannel.qiscus.com/)

```
let qiscusWidget = QiscusMultichannelWidget(appID: YOUR_APP_ID)
```

After the initialization, you can access all the widget's functions.

### Set The User

Set UserId before start the chat, this is mandatory.

```
qiscusWidget.setUser(id: "UserId", displayName: "Cus Tom R", avatarUrl: "[https://customer.avatar-url.com](https://customer.avatar-url.com/)")
```

If you want to set user properties, you can set them by using this function, for example:

```
let userProp = [["key":"job","value":"development"],["key":"Location","value":"Yogyakarta"]]

qiscusWidget.setUser(id: "UserId", displayName: "Cus Tom R", avatarUrl: "[https://customer.avatar-url.com](https://customer.avatar-url.com/)", userProperties : userProp)
```

### Get Login Status

User this function to check whether the user has already logged in.

```
qiscusWidget.isLoggedIn()
```

### Start Chat

Use this function to start a chat.

```
qiscusWidget.initiateChat()
    .setRoomTitle(title: "TITLE".localized())
    .setRoomSubTitle(enableSubtitle: RoomSubtitle.enable, subTitle: "SUBTITLE".localized())
    .startChat { (chatViewController) in
        viewController.navigationController?.setViewControllers([viewController, chatViewController], animated: true)
}
```

### Auto send message and Manual Send Message when open Chat
```
// 1
qiscusWidget.automaticSendMessage(textMessage: "testing automatic")
     
        
//2
let messageModel = QMessage()
messageModel.message = "testing automatic"
        
qiscusWidget.automaticSendMessage(qMessage: messageModel)
        
        
//3
qiscusWidget.manualSendMessage(textMessage: "testing manual")
```

### Clear User

Use this function to clear the logged-in users.

```
qiscusWidget.clearUser()
```

### Hide system message 

configure system message visibility by calling setShowSystemMessage(isShowing: Bool).

```
qiscusWidget.initiateChat()
            ...
            .setShowSystemMessage(isShowing: false)
            ...
            .startChat { (chatViewController) in
                 viewController.navigationController?.setViewControllers([viewController, chatViewController], animated: true)
            }
```

## Customization

We provide several functions to customize the User Interface.

### Config
Use this method to configure the widget properties.
Channel Id is an identity for each widget channel. If you have a specific widget channel that you want to integrate into the mobile in-app widget, you can add your channel_id when you do initiateChat. 

|Title	|Description	|
|---	|---	|
|setRoomTitle	|Set room name base on customer's name or static default.	|
|setRoomSubTitle	|	|
|	|setRoomSubTitle(RoomSubtitle.Enabled)	|Set enable room sub name by the system.	|
|	|setRoomSubTitle(RoomSubtitle.Disabled)	|Set disable room sub name.	|
|	|setRoomSubTitle(RoomSubtitle.Editable, "Custom subtitle")	|Set enable room sub name base on static default.	|
|setHideUIEvent	|Show/hide system event.	|
|setAvatar	|	|
|	|setAvatar(Avatar.Enable)	|Set enable avatar and name	|
|	|setAvatar(Avatar.Disabled)	|Set disable avatar and name	|
|setEnableNotification	|Set enable app notification.	|
|setChannelId(channelId: channel_id)	|Use this function to set your widget channel Id 	|

### Color

|No	|Title	|Description	|
|---	|---	|---	|
|1	|setNavigationColor	|Set navigation color.	|
|2	|setSendContainerColor	|Set icon send border-color.	|
|3	|setFieldChatBorderColor	|Set field chat border-color.	|
|4	|setSendContainerBackgroundColor	|Set send container background-color.	|
|5	|setNavigationTitleColor	|Set room title, room subtitle, and back button border color.	|
|6	|setSystemEventTextColor	|Set system event text and border color.	|
|7	|setLeftBubbleColor	|Set left bubble chat color (for: Admin, Supervisor, Agent).	|
|8	|setRightBubbleColor	|Set right bubble chat color (Customer).	|
|9	|setLeftBubbleTextColor	|Set left bubble text color (for: Admin, Supervisor, Agent).	|
|10	|setRightBubbleTextColor	|Set right bubble text color (Customer).	|
|11	|setTimeLabelTextColor	|Set time text color.	|
|12	|setTimeBackgroundColor	|Set time background color.	|
|13	|setBaseColor	|Set background color of the room chat.	|
|14	|setEmptyTextColor	|Set empty state text color.	|
|15	|setEmptyBackgroundColor	|Set empty state background color.	|

![Color Customization Image](/Readme/colorConfig.png)
## Push Notification

Follow these steps to set push notifications on your application

1. **Create the Certificate Signing Request (CSR)**

* Open **Keychain Access** on your Mac (Applications -> Utilities -> Keychain Access)
* Select **Request a Certificate From a Certificate Authority**

![Push Notification Image](/Readme/pn01.png)

* Fill **User Email Address, Common Name** (Example: John Doe Dev Key), and select the **Saved to disk** on **Request is** group

![Push Notification Image](/Readme/pn01b.png)

2. **Create the Push Notification SSL certificate in Apple Developer site**

* Log in to the [Apple Developer Member Center](https://developer.apple.com/)
* Go to the **Certificates, Identifiers & Profiles menu**
* Select Certificates**, **then click the Plus (+) button 

![Push Notification Image](/Readme/pn02.png)

* Select Apple Push Notification service SSL (Sandbox & Production) and click continue.

![Push Notification Image](/Readme/pn02b.png)

* Select AppID then click continue
* Upload the CSR file (step 1) to complete this process
* Download an SSL certificate
* Double-click the file and register it to your login Keychain

3. **Upload the p12 file to Qiscus dashboard**

* Click the *Certificates* category from the left menu, under the *Keychain Access*
* Select the Push SSL certificate that you registered before
* Right-click the certificate

![Push Notification Image](/Readme/pn03.png)

* Select export to save the file to your disk

![Push Notification Image](/Readme/pn03b.png)

* Go to [Qiscus Help page](https://support.qiscus.com/hc/en-us/requests/new) to submit your request
* Full fill the requirements below:
    * Email, Subject, and Description
    * Select *Multichannel CS Chat *in Product Associated
    * Select *Multichannel Customer Service Chat* in Category of Query
    * Fill `YOUR_APP_ID` in Application ID
* Click Submit

![Push Notification Image](/Readme/pn03c.png)

> Note:
This example is a production push notification certificate. You need to create a development push notification certificate and p12 file, then submit it as an attachment for Xcode users.

4. **Register the device token to Multichannel Widget.**

* Create a class to hold the Widget. In this example, we will use a Singleton Object class called ChatManager that will wrap the QiscusMultichannelWidget functionalities. In this step, we will highlight the deviceToken registration and notification tap handling.

```
final  class  ChatManager {

    static let shared: ChatManager = ChatManager()

    lazy  var  qiscusWidget: QiscusMultichannelWidget = {
        return QiscusMultichannelWidget(appID: "YOUR_APP_ID")
    }()
    
    ...
    
    func register(deviceToken: Data?) {

        if let deviceToken = deviceToken {
            var tokenString: String = ""
            for i in 0..<deviceToken.count {
                tokenString += String(format: "%02.2hhx", deviceToken[i] as CVarArg)
            }
             //isDevelopment = true : for development or running from XCode
            //isDevelopment = false : release mode TestFlight or appStore
            self.qiscusWidget.register(deviceToken: tokenString, isDevelopment: false, onSuccess: { (response) in
                print("Multichannel widget success to register device token")
            }) { (error) in
                print("Multichannel widget failed to register device token")
            }
        }

    }

    func userTapNotification(userInfo : [AnyHashable : Any]) {

        self.qiscusWidget.tapNotification(userInfo: userInfo)
    }

    ...
}
```

* In your app's AppDelegate, store your device token as a variable.

```
import  UserNotifications

@UIApplicationMain
class  AppDelegate:  UIResponder,  UIApplicationDelegate {

    func  application(_  application:  UIApplication, didFinishLaunchingWithOptions  launchOptions [UIApplication.LaunchOptionsKey:  Any]?) ->  Bool {
    
        // MARK : Setup Push Notification
        if  #available(iOS 10.0,  *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate  =  self
            let  authOptions:  UNAuthorizationOptions  = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options:  authOptions,
                completionHandler: {_,  _  in })
        } else {
            let  settings:  UIUserNotificationSettings  =
            UIUserNotificationSettings(types: [.alert, .badge, .sound],  categories:  nil)
            application.registerUserNotificationSettings(settings)
        }
          
        // MARK : register the app for remote notifications
        application.registerForRemoteNotifications()

        return  true
    }
 
    func  application(_  application:  UIApplication,  didRegisterForRemoteNotificationsWithDeviceToken  deviceToken:  Data) {

        ChatManager.shared.register(deviceToken:  deviceToken)
    }

    func  application(_  application:  UIApplication,  didReceiveRemoteNotification  userInfo: [AnyHashable  :  Any]) {
    
        ChatManager.shared.userTapNotification(userInfo: userInfo)
    } 
}

// [START ios_10_message_handling]
@available(iOS  10,  *)
extension  AppDelegate  :  UNUserNotificationCenterDelegate {
  
    // Receive displayed notifications for iOS 10 devices.
    func  userNotificationCenter(_  center:  UNUserNotificationCenter, willPresent  notification:  UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->  Void) {

        completionHandler([.alert, .sound])
    }

    func  userNotificationCenter(_  center:  UNUserNotificationCenter, didReceive  response:  UNNotificationResponse, withCompletionHandler  completionHandler: @escaping () ->  Void) {
    
        let  userInfo  =  response.notification.request.content.userInfo
        ChatManager.shared.userTapNotification(userInfo:  userInfo)
        completionHandler()
    }
}
// [END ios_10_message_handling]
```

5. **Test the push notification from third party**

Use the Easy APNs Provider tools

![Push Notification Image](/Readme/pn05.png)

> Note:

> Follow steps 1 - 5 tools to test push notification. We use cert Apple Development IOS Push Service to test it

## How to Run the Example

1. **Get your APPID**

* Go to [Qiscus Multichannel Chat page](https://multichannel.qiscus.com/) to register your email
* Log in to Qiscus Multichannel Chat with yout email and password
* Go to ‘Setting’ menu on the left bar
* Look for ‘App Information’
* You can find APPID in the App Info 

2. **Activate Qiscus Widget Integration**

* Go to ‘Integration’ menu on the left bar
* Look for ‘Qiscus Widget’
* Slide the toggle to activate the Qiscus widget

3. **Run pod install**

After cloning the example, you need to run this code to install all C*ocoapods* dependencies needed by the Example

```
pod install
```

4. **Set YOUR_APP_ID in the Example**

* Open Example/ChatManager.swift
* Replace the appId at line 21 with YOUR_ APP_ID (step 1)

```
lazy  var  qiscusWidget: QiscusMultichannelWidget = {
    return  QiscusMultichannelWidget(appID: "YOUR_APP_ID")
}()
```

5. **Start Chat**

The Example is ready to use. You can start to chat with your agent from the Qiscus Multichannel Chat dashboard.
