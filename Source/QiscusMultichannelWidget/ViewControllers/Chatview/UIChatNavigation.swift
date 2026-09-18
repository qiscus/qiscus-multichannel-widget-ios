//
//  ChatTitleView.swift
//  QiscusUI
//
//  Created by Qiscus on 25/10/18.
//

#if os(iOS)
import UIKit
#endif
import QiscusCore
import AlamofireImage

class UIChatNavigation: UIView {
    // ui component
    /// UIImageView avatar, hidden until an image is actually loaded
    let ivAvatar: UIImageView = UIImageView()
    /// UILabel title,
    let labelTitle: UILabel = UILabel()
    /// UILabel subtitle, hidden while its text is empty
    let labelSubtitle: UILabel = UILabel()

    private let avatarSize: CGFloat = 32.0
    private let contentStack: UIStackView = UIStackView()

    var room: QChatRoom? {
        set {
            self._room = newValue
            if let data = newValue { present(room: data) } // bind data only
        }
        get {
            return self._room
        }
    }
    private var _room : QChatRoom? = nil
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    // If someone is to initialize a UIChatInput in code
    override init(frame: CGRect) {
        // For use in code
        super.init(frame: frame)
        commonInit()
    }
    
    // If someone is to initalize a UIChatInput in Storyboard setting the Custom Class of a UIView
    required init?(coder aDecoder: NSCoder) {
        // For use in Interface Builder
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        self.autoresizingMask = (UIView.AutoresizingMask.flexibleWidth)
        self.setupUI()
    }
    
    private func setupUI() {
        self.ivAvatar.contentMode = .scaleAspectFill
        self.ivAvatar.clipsToBounds = true
        // the size is constrained to a constant, so the mask can be set once here;
        // deriving it from `bounds` in layoutSubviews runs before the stack view
        // has sized its arranged subviews and yields a radius of 0
        self.ivAvatar.layer.cornerRadius = self.avatarSize / 2.0
        self.ivAvatar.backgroundColor = .clear
        // nothing to show until `present(room:)` actually resolves an image,
        // otherwise the bar renders an empty circle next to the title
        self.ivAvatar.isHidden = true
        self.ivAvatar.setContentHuggingPriority(.required, for: .horizontal)
        self.ivAvatar.setContentCompressionResistancePriority(.required, for: .horizontal)

        self.labelTitle.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        self.labelSubtitle.font = UIFont.systemFont(ofSize: 13.0)
        for label in [self.labelTitle, self.labelSubtitle] {
            label.textColor = .white
            label.textAlignment = .natural
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
        }
        self.labelSubtitle.isHidden = true

        let textStack = UIStackView(arrangedSubviews: [self.labelTitle, self.labelSubtitle])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 1.0

        self.contentStack.axis = .horizontal
        self.contentStack.alignment = .center
        self.contentStack.spacing = 8.0
        self.contentStack.addArrangedSubview(self.ivAvatar)
        self.contentStack.addArrangedSubview(textStack)
        self.contentStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.contentStack)

        NSLayoutConstraint.activate([
            self.ivAvatar.widthAnchor.constraint(equalToConstant: self.avatarSize),
            self.ivAvatar.heightAnchor.constraint(equalToConstant: self.avatarSize),

            // the title view spans the whole gap between the bar button items, so the
            // group sits on its leading edge next to the back button and is allowed to
            // shrink rather than overflow
            self.contentStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentStack.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor),
            self.contentStack.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor),
            self.contentStack.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor)
        ])
    }
    
    func present(room: QChatRoom) {
        
        // change avatar room do admin avatar, you can set avatar on admin dashboard
        room.participants?.forEach({ (p) in
            if p.id.contains("admin@qismo.com") {
                if let avatarURL = p.avatarUrl {
                    if avatarURL.absoluteString == "https://image.flaticon.com/icons/svg/145/145867.svg" {
                        if let defaultURL = URL(string: "https://d1edrlpyc25xu0.cloudfront.net/kiwari-prod/image/upload/Ri-pxHv6e1/default_avatar.png") {
                            self.setAvatar(url: defaultURL)
                        }
                    } else {
                        self.setAvatar(url: avatarURL)
                    }
                }
            }
        })
    }

    /// Loads the avatar and only reveals it once an image really arrived, so a
    /// failed or missing avatar collapses out of the stack instead of leaving a gap.
    private func setAvatar(url: URL) {
        self.ivAvatar.af.setImage(withURL: url, completion: { [weak self] response in
            guard let self = self else { return }
            self.ivAvatar.isHidden = (response.value == nil)
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        // the subtitle doubles as the typing indicator and is emptied again
        // afterwards, so keep its visibility in sync with its text
        let hasSubtitle = !(self.labelSubtitle.text ?? "").isEmpty
        if self.labelSubtitle.isHidden == hasSubtitle {
            self.labelSubtitle.isHidden = !hasSubtitle
        }
    }
    
}

extension UIChatNavigation {
    func getParticipant(participants: [QParticipant]) -> String {
        var result = ""
        for m in participants {
            if result.isEmpty {
                result = m.name
            }else {
                result = result + ", \(m.name)"
            }
        }
        return result
    }
}
