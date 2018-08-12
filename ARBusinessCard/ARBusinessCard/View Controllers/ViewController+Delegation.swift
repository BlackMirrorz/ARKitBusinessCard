//
//  ViewController+Delegation.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 11/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import WebKit
import SideMenu
import Contacts

//----------------------------------------------
//MARK: - UISideMenuNavigationControllerDelegate
//----------------------------------------------

extension ViewController: UISideMenuNavigationControllerDelegate{

    func sideMenuWillAppear(menu: UISideMenuNavigationController, animated: Bool) { menuShown = true }
    
    func sideMenuDidAppear(menu: UISideMenuNavigationController, animated: Bool) { menuShown = true }
    
    func sideMenuDidDisappear(menu: UISideMenuNavigationController, animated: Bool) { menuShown = false }
}

//-------------------------------------------
//MARK: - MFMailComposeViewControllerDelegate
//-------------------------------------------

extension ViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        controller.dismiss(animated: true) { self.menuShown = false }
    }
}

extension ViewController: MFMessageComposeViewControllerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
         controller.dismiss(animated: true) { self.menuShown = false }
        
    }
    
}
//--------------------------
//MARK: -  ARSessionDelegate
//--------------------------

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        
        if menuShown { return }

        //1. Enumerate Our Anchors To See If We Have Found Our Target Anchor
        for anchor in anchors{

            if let imageAnchor = anchor as? ARImageAnchor, imageAnchor == targetAnchor{

                //2. If The ImageAnchor Is No Longer Tracked Then Reset The Business Card
                if !imageAnchor.isTracked{
                    businessCardPlaced = false
                    businessCard.setBaseConfiguration()
                }else{

                    //3. Layout The Card Again
                    if !businessCardPlaced{
                        businessCard.animateBusinessCard()
                        businessCardPlaced = true
                    }
                }
            }
        }
     }
}

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        //1. Check We Have A Valid Image Anchor
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //2. Get The Detected Reference Image
        let referenceImage = imageAnchor.referenceImage
        
        //3. Load Our Business Card
        if let matchedBusinessCardName = referenceImage.name, matchedBusinessCardName == "BlackMirrorz" && !businessCardPlaced{
            
            businessCardPlaced = true
            node.addChildNode(businessCard)
            businessCard.animateBusinessCard()
            targetAnchor = imageAnchor
            
        }
    }
}
