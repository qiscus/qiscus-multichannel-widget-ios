//
//  UploadProgressBanner.swift
//  QiscusMultichannelWidget
//
//  Created by Qiscus on 13/08/21.
//

import Foundation
import UIKit

class UploadProgressBanner {
    let hostViewController: UIViewController
    var constraintBannerTop: NSLayoutConstraint?
    let banner = UIView()
    let progress = UIProgressView(progressViewStyle: .bar)
    let cancelButton = UIButton(type: .system)
    let uploadingLabel = UILabel()
    var isDisplayed: Bool = false
    
    init(host: UIViewController) {
        self.hostViewController = host
    }
    
    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (hostViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
                (hostViewController.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            return (UIApplication.shared.statusBarFrame.height ) + (hostViewController.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
    
    var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return (hostViewController.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0)
        } else {
            return (UIApplication.shared.statusBarFrame.height)
        }
    }
    
    func showBannerInfo() {
        if isDisplayed {
            return
        }
        
        isDisplayed = true
        banner.backgroundColor = .white
        banner.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Close", for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1), for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "SFProText-Regular", size: 16)
        progress.translatesAutoresizingMaskIntoConstraints = false
        uploadingLabel.translatesAutoresizingMaskIntoConstraints = false
        uploadingLabel.text = "Uploading.."
        
        let viewBorderBottom = UIView()
        viewBorderBottom.translatesAutoresizingMaskIntoConstraints = false
        viewBorderBottom.backgroundColor = #colorLiteral(red: 0.7803921569, green: 0.7803921569, blue: 0.7803921569, alpha: 1)
        
        guard let topView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        topView.addSubview(banner)
        banner.addSubview(cancelButton)
        banner.addSubview(viewBorderBottom)
        banner.addSubview(progress)
        banner.addSubview(uploadingLabel)
        cancelButton.addTarget(self, action: #selector(cancelDidTap), for: .touchUpInside)
        progress.progressTintColor = UIColor(red: 0/255.0, green: 184/255.0, blue: 148/255.0, alpha:1.0)
        
        self.constraintBannerTop = banner.topAnchor.constraint(equalTo: topView.topAnchor, constant: -topbarHeight)

        NSLayoutConstraint.activate([
            constraintBannerTop!,
            banner.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: topbarHeight),
            cancelButton.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -19),
            cancelButton.topAnchor.constraint(equalTo: banner.topAnchor, constant: statusBarHeight + 8),
            cancelButton.widthAnchor.constraint(equalToConstant: 52),
            viewBorderBottom.leadingAnchor.constraint(equalTo: banner.leadingAnchor),
            viewBorderBottom.trailingAnchor.constraint(equalTo: banner.trailingAnchor),
            viewBorderBottom.heightAnchor.constraint(equalToConstant: 1),
            viewBorderBottom.bottomAnchor.constraint(equalTo: banner.bottomAnchor),
            progress.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            progress.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 8),
            progress.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8),
            progress.heightAnchor.constraint(equalToConstant: 10),
            uploadingLabel.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            uploadingLabel.centerXAnchor.constraint(equalTo: banner.centerXAnchor)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.constraintBannerTop!.constant = 0
            
            UIView.animate(withDuration: 0.2) {
                topView.layoutIfNeeded()
            }
        }
    }
    
    func dismiss() {
        progress.progress = 0
        isDisplayed = false
        uploadingLabel.text = "Uploading.."
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let topView = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                return
            }
            
            self?.constraintBannerTop?.constant = -UIScreen.main.bounds.height
            UIView.animate(withDuration: 0.5, animations: {
                topView.layoutIfNeeded()
            }) { (_) in
                self?.banner.removeFromSuperview()
            }
        }
    }
    
    @objc func cancelDidTap() {
        dismiss()
    }
    
}
