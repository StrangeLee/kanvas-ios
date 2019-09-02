//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AVFoundation
import Foundation
import UIKit

/// Protocol for confirming the text tools
protocol EditorTextControllerDelegate: class {
    
    /// Called after the confirm button is tapped
    ///
    /// - Parameter options: text style options
    /// - Parameter transformations: position, scaling and rotation angle for the view
    /// - Parameter size: text view size
    func didConfirmText(options: TextOptions, transformations: ViewTransformations, size: CGSize)
}

/// Constants for EditorTextController
private struct Constants {
    static let animationDuration: TimeInterval = 0.25
}

/// A view controller that contains the text tools menu
final class EditorTextController: UIViewController, EditorTextViewDelegate {
    
    weak var delegate: EditorTextControllerDelegate?
    
    private var textTransformations: ViewTransformations = ViewTransformations()
    
    private lazy var textView: EditorTextView = {
        let textView = EditorTextView()
        textView.delegate = self
        return textView
    }()
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @available(*, unavailable, message: "use init(settings:, segments:) instead")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) has not been implemented")
    }
    
    init() {
        super.init(nibName: .none, bundle: .none)
    }
    
    override func loadView() {
        view = textView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        setUpView()
    }
    
    private func setUpView() {
        textView.alpha = 0
    }
    
    // MARK: - EditorTextViewDelegate
    
    func didTapConfirmButton() {
        delegate?.didConfirmText(options: textView.textOptions, transformations: textTransformations, size: textView.textSize)
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            textView.moveToolsUp(distance: keyboardSize.height)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        textView.moveToolsDown()
    }
    
    // MARK: - Public interface
    
    /// shows or hides the text tools menu
    ///
    /// - Parameter visible: true to show, false to hide
    /// - Parameter transformations: transformations for the view
    /// - Parameter options: text style options
    func showView(_ visible: Bool,
                  options: TextOptions = TextOptions(),
                  transformations: ViewTransformations = ViewTransformations()) {
        if visible {
            show(options: options, transformations: transformations)
        }
        else {
            hide()
        }
    }
    
    /// Makes the view appear
    ///
    /// - Parameter transformations: transformations for the view
    /// - Parameter options: text style options
    private func show(options: TextOptions = TextOptions(),
                      transformations: ViewTransformations = ViewTransformations()) {
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.textView.alpha = 1
        }, completion: { _ in
            self.textTransformations = transformations
            self.textView.textOptions = options
            self.textView.startWriting()
        })
    }
    
    
    /// Hides the view
    private func hide() {
        textView.endWriting()
        UIView.animate(withDuration: Constants.animationDuration) {
            self.textView.alpha = 0
        }
    }
}
