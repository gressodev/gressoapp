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
    @Binding var isSliderGoingDown: Bool
    
    var didTakeSnapshot: (UIImage) -> Void
    
    func makeUIView(context: Context) -> ARFaceTrackingView {
        let arView = ARFaceTrackingView(frame: .zero)
        arView.renderOptions = [.disablePersonOcclusion]
        
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])
        
        arView.needToDarkenLenses = {
            isSliderGoingDown = false
        }
        arView.needToLightenLenses = {
            isSliderGoingDown = true
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARFaceTrackingView, context: Context) {
        uiView.scene.anchors.removeAll()
        
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
    
    var needToDarkenLenses: (() -> Void)?
    var needToLightenLenses: (() -> Void)?
    
    func changeModel(currentDestination: URL) {
        do {
            let model = try RCProject.loadScene(realityFileSceneURL: currentDestination)
            scene.addAnchor(model)
            
            model.actions.darkenLensesStart.onAction = darkenNotificationID
            model.actions.lightenLensesStart.onAction = lightenNotificationID
        } catch {
            print("Fail loading entity.", error.localizedDescription)
        }
    }
    
    fileprivate func darkenNotificationID(_ entity: Entity?) {
        needToDarkenLenses?()
    }
    
    fileprivate func lightenNotificationID(_ entity: Entity?) {
        needToLightenLenses?()
    }
    
}
