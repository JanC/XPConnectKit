//
//  ViewControllerExtensions.swift
//  XPConnectSample
//
//  Created by Jan Chaloupecky on 16.03.18.
//  Copyright © 2018 TequilaApps. All rights reserved.
//

import UIKit


extension UIViewController {
    func showAlert(title: String, message: String) {
        OperationQueue.main.addOperation {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(controller, animated: true)
        }
    }

    func askYesNo(title: String, question: String, yesAction: @escaping (() -> Void), noAction: (() -> Void)? = nil) {
        let controller = UIAlertController(title: title, message: question, preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Ok", style: .default) { action in
            yesAction()
        })
        
        controller.addAction(UIAlertAction(title: "Not now", style: .default) { action in
            noAction?()
        })
        self.present(controller, animated: true)
    }
    
    func present(asPopover viewController: UIViewController, fromPoint point: CGPoint, inSourceView view: UIView) {
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController!.sourceView = view
        viewController.popoverPresentationController!.sourceRect = CGRect(origin: point, size: .zero)
        self.present(viewController, animated: true)
    }
}
