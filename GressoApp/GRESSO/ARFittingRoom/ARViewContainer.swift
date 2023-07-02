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
        
        if let currentDestination {
            uiView.changeModel(currentDestination: currentDestination)
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
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        session.delegate = self
    }

    @MainActor required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeModel(currentDestination: URL) {
        do {
            let anchor = AnchorEntity()
            let model = try Entity.loadAnchor(contentsOf: currentDestination)
            anchor.addChild(model)
            scene.addAnchor(anchor)
        } catch {
            print("Fail loading entity.", error.localizedDescription)
        }
    }
    
}

extension ARFaceTrackingView: ARSessionDelegate {
    
//    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
//        for anchor in anchors {
//            if let faceAnchor = anchor as? ARFaceAnchor {
//                let faceGeometry = faceAnchor.geometry
//                faceGeometry
//                let vertices = faceGeometry.vertices
//
//                var minX = Float.greatestFiniteMagnitude
//                var minY = Float.greatestFiniteMagnitude
//                var minZ = Float.greatestFiniteMagnitude
//                var maxX = -Float.greatestFiniteMagnitude
//                var maxY = -Float.greatestFiniteMagnitude
//                var maxZ = -Float.greatestFiniteMagnitude
//
//                for vertex in vertices {
//                    minX = min(minX, vertex.x)
//                    minY = min(minY, vertex.y)
//                    minZ = min(minZ, vertex.z)
//
//                    maxX = max(maxX, vertex.x)
//                    maxY = max(maxY, vertex.y)
//                    maxZ = max(maxZ, vertex.z)
//                }
//
//                let boundingBox = CGRect(x: CGFloat(minX), y: CGFloat(minY), width: CGFloat(maxX - minX), height: CGFloat(maxY - minY))
//                print("### boundingBox", boundingBox)
//            }
//        }
//    }
    
//    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        print("### didAdd", anchors)
//    }
    
}
