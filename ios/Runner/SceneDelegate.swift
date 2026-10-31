import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {

}

/// The game draws a phone of its own, with its own home bar at the bottom
/// and its own notifications at the top. The first swipe from either edge
/// goes to the game; iOS only takes a second one, and its home bar fades.
class PhoneViewController: FlutterViewController {
  override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
    [.top, .bottom]
  }

  override var prefersHomeIndicatorAutoHidden: Bool { true }
}
