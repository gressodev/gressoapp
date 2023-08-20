//
//  ARViewContainer.swift
//  GressoApp
//
//  Created by Dmitry Koshelev on 09.06.2023.
//

import SwiftUI
import RealityKit
import ARKit
import SceneKit
import SceneKit.ModelIO

@MainActor
struct ARViewContainer: UIViewRepresentable {
    
    @Binding var currentDestination: URL?
    @Binding var needToTakeSnapshot: Bool
    @Binding var needToDarken: Bool
    
    var didTakeSnapshot: (UIImage) -> Void

    func makeUIView(context: Context) -> ARFaceTrackingView {
        let arView = ARFaceTrackingView(frame: .zero)
//        arView.renderOptions = [.disablePersonOcclusion]
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.environmentTexturing = .automatic
        
//        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARFaceTrackingView, context: Context) {
//        uiView.resetScene() // .scene.anchors.removeAll()
        
        if let currentDestination {
            uiView.changeModel(
                currentDestination: currentDestination,
                needToDarken: needToDarken
            )
        }
        if needToTakeSnapshot {
            guard let image = uiView.takeScreenshot() else { return }
            DispatchQueue.main.async {
                didTakeSnapshot(image)
                needToTakeSnapshot = false
            }
        }
    }
    
}

final class ARFaceTrackingView: ARSCNView, ARSCNViewDelegate {
    
    private var currentDestination: URL?
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        
        delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        session.pause()
    }
    
    func changeModel(currentDestination: URL, needToDarken: Bool) {
        self.currentDestination = currentDestination
//        do {
//            let model = try RCProject.loadScene(realityFileSceneURL: currentDestination)
//            scene.addAnchor(model)
//
//            if needToDarken {
//                model.notifications.darkenLenses.post()
//            } else {
//                model.notifications.lightenLenses.post()
//            }
//        } catch {
//            print("Fail loading entity.", error.localizedDescription)
//        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let currentDestination, let device = device else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let node = SCNNode(geometry: faceGeometry)
        node.geometry?.firstMaterial?.transparency = 0.0
        
        let mdlAsset = MDLAsset(url: currentDestination)
        mdlAsset.loadTextures()
        let asset = mdlAsset.object(at: 0)
        
        let assetNode = SCNNode(mdlObject: asset)
        let reflectiveMaterial = SCNMaterial()
        reflectiveMaterial.lightingModel = .physicallyBased
        reflectiveMaterial.metalness.contents = 1.0
        reflectiveMaterial.roughness.contents = 0
        assetNode.geometry?.firstMaterial = reflectiveMaterial
        node.addChildNode(assetNode)
        
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        
        
//        let distance = simd_distance(faceAnchor.rightEyeTransform.columns.3, faceAnchor.leftEyeTransform.columns.3)
//        print("### distance: ", distance * 100, " sm")
    }
    
    func resetScene() {
//        session.pause()
//        scene.rootNode.enumerateChildNodes { node, _ in
//            node.removeFromParentNode()
//        }
        session.run(ARFaceTrackingConfiguration(), options: [.resetTracking, .removeExistingAnchors])
    }
    
}
