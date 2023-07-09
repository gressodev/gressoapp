//
//  ARViewContainer.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 09.06.2023.
//

import SwiftUI
import RealityKit
import ARKit

@MainActor
struct ARViewContainer: UIViewRepresentable {
    
    @Binding var currentDestination: URL?
    @Binding var needToTakeSnapshot: Bool
    @Binding var needToDarkenLenses: Bool
    @Binding var needToLightenLenses: Bool
    
    var didTakeSnapshot: (UIImage) -> Void
    
    func makeUIView(context: Context) -> ARFaceTrackingView {
        let arView = ARFaceTrackingView(frame: .zero)
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARFaceTrackingView, context: Context) {
        uiView.scene.anchors.removeAll()
        
        uiView.needToDarkenLenses = needToDarkenLenses
        uiView.needToLightenLenses = needToLightenLenses
        
        if let currentDestination {
            uiView.changeModel(
                currentDestination: currentDestination
            )
        }
        if needToTakeSnapshot {
            uiView.snapshot(saveToHDR: false) { image in
                guard let cgImage = image?.cgImage else { return }
                let uiImage = UIImage(cgImage: cgImage)
                didTakeSnapshot(uiImage)
                needToTakeSnapshot = false
            }
        }
    }
    
}

final class ARFaceTrackingView: ARView {
    
    @Published var needToDarkenLenses: Bool = false
    @Published var needToLightenLenses: Bool = false
    
    func changeModel(currentDestination: URL) {
        do {
            let model = try RCProject.loadScene(realityFileSceneURL: currentDestination)
            scene.addAnchor(model)
            if needToDarkenLenses {
                model.notifications.darkenLenses.post()
                needToDarkenLenses = false
            } else if needToLightenLenses {
                model.notifications.lightenLenses.post()
                needToLightenLenses = false
            }
        } catch {
            print("Fail loading entity.", error.localizedDescription)
        }
    }
    
}

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

    public enum LoadRealityFileError: Error {
        case fileNotFound(String)
    }

    private static var streams = [Combine.AnyCancellable]()

    public static func loadScene(realityFileSceneURL: URL) throws -> RCProject.Scene {
        let anchorEntity = try RCProject.Scene.loadAnchor(contentsOf: realityFileSceneURL)
        return createScene(from: anchorEntity)
    }

//    public static func loadСценаAsync(completion: @escaping (Swift.Result<ARProject.Сцена, Swift.Error>) -> Void) {
//        guard let realityFileURL = Foundation.Bundle(for: ARProject.Сцена.self).url(forResource: "ARProject", withExtension: "reality") else {
//            completion(.failure(ARProject.LoadRealityFileError.fileNotFound("ARProject.reality")))
//            return
//        }
//
//        var cancellable: Combine.AnyCancellable?
//        let realityFileSceneURL = realityFileURL.appendingPathComponent("Scene", isDirectory: false)
//        let loadRequest = RCProject.Scene.loadAnchorAsync(contentsOf: realityFileSceneURL)
//        cancellable = loadRequest.sink(receiveCompletion: { loadCompletion in
//            if case let .failure(error) = loadCompletion {
//                completion(.failure(error))
//            }
//            streams.removeAll { $0 === cancellable }
//        }, receiveValue: { entity in
//            completion(.success(RCProject.createScene(from: entity)))
//        })
//        cancellable?.store(in: &streams)
//    }

    private static func createScene(from anchorEntity: RealityKit.AnchorEntity) -> RCProject.Scene {
        let scene = RCProject.Scene()
        scene.anchoring = anchorEntity.anchoring
        scene.addChild(anchorEntity)
        return scene
    }

    public class Scene: RealityKit.Entity, RealityKit.HasAnchoring {

        public private(set) lazy var notifications = RCProject.Scene.Notifications(root: self)

        public class Notifications {

            fileprivate init(root: RealityKit.Entity) {
                self.root = root
            }

            private weak var root: RealityKit.Entity?

            public private(set) lazy var darkenLenses = RCProject.NotificationTrigger(identifier: "darkenLenses", root: root)
            public private(set) lazy var lightenLenses = RCProject.NotificationTrigger(identifier: "lightenLenses", root: root)

            public private(set) lazy var allNotifications = [ darkenLenses, lightenLenses ]

        }

    }

}
