//
//  ViewController.swift
//  ARWatch
//
//  Created by Hannes Steiner on 02.06.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    public var standardNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        if let imagesToTrack = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: Bundle.main) {
            configuration.trackingImages = imagesToTrack
            configuration.maximumNumberOfTrackedImages = 1
        }
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let imageAnchor = anchor as? ARImageAnchor else { return nil }
        guard let imageName = imageAnchor.name else { return nil }
        let images = ["audio", "settings", "map"]
        if images.contains(imageName) {
            guard standardNode != nil else {
                let newNode = SCNNode()
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width*3,
                                     height: imageAnchor.referenceImage.physicalSize.height*3.6522)
                let planeNode = SCNNode(geometry: plane)
                planeNode.eulerAngles.x = -.pi / 2
                createHostingController(for: planeNode)
                newNode.addChildNode(planeNode)
                standardNode = newNode
                return standardNode
            }
            return standardNode
        } else {
            return nil
        }
    }
    
    func createHostingController(for node: SCNNode) {
        let arVC = UIHostingController(rootView: ContentView())
        DispatchQueue.main.async {
            arVC.willMove(toParent: self)
            self.addChild(arVC)
            arVC.view.frame = CGRect(x: 0, y: 0, width: 200*3, height: 200*3.6522)
            self.view.addSubview(arVC.view)
            self.show(hostingVC: arVC, on: node)
        }
    }
    
    func show(hostingVC: UIHostingController<ContentView>, on node: SCNNode) {
        let material = SCNMaterial()
        hostingVC.view.isOpaque = false
        material.diffuse.contents = hostingVC.view
        node.geometry?.materials = [material]
        hostingVC.view.backgroundColor = UIColor.clear
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print(error.localizedDescription)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
            case .notAvailable:
                print("notAvailable")
                return
            case .limited(let reason):
                switch reason {
                    case .initializing:
                    print("initializing")
                    case .excessiveMotion:
                    print("excessiveMotion")
                    case .insufficientFeatures:
                    print("insufficientFeatures")
                    case .relocalizing:
                    print("relocalizing")
                    @unknown default:
                    print("default")
            }
            case .normal:
                print("normal")
                return
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
