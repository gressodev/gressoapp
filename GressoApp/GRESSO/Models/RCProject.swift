//
//  RCProject.swift
//  GRESSO
//
//  Created by Dmitry Koshelev on 10.07.2023.
//

import Foundation
import RealityKit
import Combine

@available(iOS 13.0, macOS 10.15, *)
public enum RCProject {
    
    public class NotificationTrigger {

        public let identifier: Swift.String

        private weak var root: RealityKit.Entity?

        fileprivate init(identifier: Swift.String, root: RealityKit.Entity?) {
            self.identifier = identifier
            self.root = root
        }

        public func post(overrides: [Swift.String: RealityKit.Entity]? = nil) {
            guard let scene = root?.scene else {
                print("Unable to post notification trigger with identifier \"\(self.identifier)\" because the root is not part of a scene")
                return
            }

            var userInfo: [Swift.String: Any] = [
                "RealityKit.NotificationTrigger.Scene": scene,
                "RealityKit.NotificationTrigger.Identifier": self.identifier
            ]
            userInfo["RealityKit.NotificationTrigger.Overrides"] = overrides

            Foundation.NotificationCenter.default.post(name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotificationTrigger"), object: self, userInfo: userInfo)
        }

    }

    public class NotifyAction {

        public let identifier: Swift.String

        public var onAction: ((RealityKit.Entity?) -> Swift.Void)?

        private weak var root: RealityKit.Entity?

        fileprivate init(identifier: Swift.String, root: RealityKit.Entity?) {
            self.identifier = identifier
            self.root = root

            Foundation.NotificationCenter.default.addObserver(self, selector: #selector(actionDidFire(notification:)), name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
        }

        deinit {
            Foundation.NotificationCenter.default.removeObserver(self, name: Foundation.NSNotification.Name(rawValue: "RealityKit.NotifyAction"), object: nil)
        }

        @objc
        private func actionDidFire(notification: Foundation.Notification) {
            guard let onAction = onAction else {
                return
            }

            guard let userInfo = notification.userInfo as? [Swift.String: Any] else {
                return
            }

            guard let scene = userInfo["RealityKit.NotifyAction.Scene"] as? RealityKit.Scene,
                root?.scene == scene else {
                    return
            }

            guard let identifier = userInfo["RealityKit.NotifyAction.Identifier"] as? Swift.String,
                identifier == self.identifier else {
                    return
            }

            let entity = userInfo["RealityKit.NotifyAction.Entity"] as? RealityKit.Entity

            onAction(entity)
        }

    }

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()
    
    public static func loadScene(realityFileSceneURL: URL) throws -> RCProject.Scene {
        let anchorEntity = try RCProject.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }
    
    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> RCProject.Scene {
        let scene = RCProject.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

        public private(set) lazy var actions = RCProject.Scene.Actions(root: self)
        
        public private(set) lazy var notifications = RCProject.Scene.Notifications(root: self)

        public class Notifications {

            fileprivate init(root: RealityKit.Entity) {
                self.root = root
            }

            private weak var root: RealityKit.Entity?

            public private(set) lazy var darkenLenses = RCProject.NotificationTrigger(identifier: "darkenLenses", root: root)
            public private(set) lazy var lightenLenses = RCProject.NotificationTrigger(identifier: "lightenLenses", root: root)

            public private(set) lazy var allNotifications = [ lightenLenses, darkenLenses ]

        }

        public class Actions {

            fileprivate init(root: RealityKit.Entity) {
                self.root = root
            }

            private weak var root: RealityKit.Entity?

            public private(set) lazy var darkenLensesStart = RCProject.NotifyAction(identifier: "darkenLensesStart", root: root)
            public private(set) lazy var lightenLensesStart = RCProject.NotifyAction(identifier: "lightenLensesStart", root: root)

            public private(set) lazy var allActions = [ lightenLensesStart, darkenLensesStart ]

        }

    }

}
