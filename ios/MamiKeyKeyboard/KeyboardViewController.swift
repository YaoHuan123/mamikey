import UIKit
import SwiftUI

final class KeyboardViewController: UIInputViewController {
  private var hostingController: UIHostingController<KeyboardRootView>?

  override func viewDidLoad() {
    super.viewDidLoad()
    setupKeyboardView()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    guard let inputView else { return }
    inputView.translatesAutoresizingMaskIntoConstraints = false
    let height: CGFloat = 280
    if inputView.constraints.isEmpty {
      NSLayoutConstraint.activate([
        inputView.heightAnchor.constraint(equalToConstant: height),
      ])
    }
  }

  private func setupKeyboardView() {
    let rootView = KeyboardRootView(
      onInsertText: { [weak self] text in
        self?.textDocumentProxy.insertText(text)
      },
      onDeleteBackward: { [weak self] in
        self?.textDocumentProxy.deleteBackward()
      },
      onAdvanceToNextInputMode: { [weak self] in
        self?.advanceToNextInputMode()
      },
      hasFullAccess: { [weak self] in
        self?.hasFullAccess ?? false
      }
    )

    let hosting = UIHostingController(rootView: rootView)
    hosting.view.translatesAutoresizingMaskIntoConstraints = false
    hosting.view.backgroundColor = .clear

    addChild(hosting)
    view.addSubview(hosting.view)
    NSLayoutConstraint.activate([
      hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
      hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    hosting.didMove(toParent: self)
    hostingController = hosting
  }
}
