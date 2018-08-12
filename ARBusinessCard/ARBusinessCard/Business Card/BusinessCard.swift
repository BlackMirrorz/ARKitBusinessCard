//
//  BusinessCard.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 10/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import Foundation
import ARKit
import WebKit
import MapKit

class BusinessCard: SCNNode{
    
    /// Template For The Business Card
    enum CardTemplate: CustomStringConvertible{
       
        case noProfileImage
        case standard
        
        var description: String{
            switch self {
            case .noProfileImage:
                return "art.scnassets/BusinessCardTemplateA.scn"
            case .standard:
                return "art.scnassets/BusinessCardTemplateB.scn"
            }
        }
    }
    
    var nameTimer: Timer?
    var time = 0
    
    let Flipped_Rotation = SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(180))
    var interactiveButtons = [SCNNode]()
    
    var cardData: BusinessCardData!
    var cardType: CardTemplate!
    var businessCardTarget: SCNNode!
    var cardHolderImage: SCNNode!       { didSet { cardHolderImage.name = "CardHolder" } }
    var firstNameText: SCNText!
    var surnameText: SCNText!
    var stackOverFlowButton: SCNNode!   { didSet { stackOverFlowButton.name = "StackOverFlow" } }
    var gitHubButton: SCNNode!          { didSet { gitHubButton.name = "GitHub" } }
    var websiteButton: SCNNode!         { didSet { websiteButton.name = "Website"} }
    var phoneNumberButton: SCNNode!     { didSet { phoneNumberButton.name = "PhoneNumber" } }
    var textMessageButton: SCNNode!     { didSet { textMessageButton.name = "TextMessage" } }
    var emailButton: SCNNode!           { didSet { emailButton.name = "Email" } }
    var contactsButton: SCNNode!        { didSet { emailButton.name = "Contacts" } }
    var mapButton: SCNNode!             { didSet { emailButton.name = "Map" } }
    
    //---------------------
    //MARK: - Intialization
    //---------------------
    
    /// Creates The Business Card
    ///
    /// - Parameters:
    ///   - data: BusinessCardData
    ///   - cardType: CardTemplate
    init(data: BusinessCardData, cardType: CardTemplate) {
        
        super.init()
        
        //1. Set The Data For The Card
        self.cardData = data
        self.cardType = cardType
        
        //2. Extrapolate All The Nodes & Geometries
        guard let template = SCNScene(named: cardType.description),
            let cardRoot = template.rootNode.childNode(withName: "RootNode", recursively: false),
            let target = cardRoot.childNode(withName: "BusinessCardTarget", recursively: false),
            let firstNameText = cardRoot.childNode(withName: "FirstName", recursively: false)?.geometry as? SCNText,
            let surnameText = cardRoot.childNode(withName: "Surname", recursively: false)?.geometry as? SCNText,
            let stackOverFlowButton = cardRoot.childNode(withName: "StackOverFlow", recursively: false),
            let gitHubButton = cardRoot.childNode(withName: "GitHub", recursively: false),
            let websiteButton = cardRoot.childNode(withName: "Website", recursively: false),
            let phoneNumberButton = cardRoot.childNode(withName: "PhoneNumber", recursively: false),
            let textMessageButton = cardRoot.childNode(withName: "TextMessage", recursively: false),
            let emailButton = cardRoot.childNode(withName: "Email", recursively: false),
            let contactsButton = cardRoot.childNode(withName: "SaveToContacts", recursively: false),
            let mapButton = cardRoot.childNode(withName: "Map", recursively: false)
            
        else { fatalError("Error Getting Business Card Node Data") }
        
        //3. If We Are Using The Standard Template We Will Also Show The User Profile Pic
        if cardType == .standard{
            let cardHolderImage = cardRoot.childNode(withName: "UserImage", recursively: false)
            self.cardHolderImage = cardHolderImage
        }
        
        //4. Assign These To The BusinessCard Node
        self.businessCardTarget = target
        self.firstNameText = firstNameText
        self.firstNameText.flatness = 0
        self.surnameText = surnameText
        self.surnameText.flatness = 0
        self.stackOverFlowButton = stackOverFlowButton
        self.gitHubButton = gitHubButton
        self.websiteButton = websiteButton
        self.phoneNumberButton = phoneNumberButton
        self.textMessageButton = textMessageButton
        self.emailButton = emailButton
        self.contactsButton = contactsButton
        self.mapButton = mapButton
        
        //5. Add It To The Hieracy
        self.addChildNode(cardRoot)
        self.eulerAngles.x = -.pi / 2
        
        //5. Store All The Interactive Elements
        interactiveButtons.append(phoneNumberButton)
        interactiveButtons.append(textMessageButton)
        interactiveButtons.append(emailButton)
        interactiveButtons.append(gitHubButton)
        interactiveButtons.append(stackOverFlowButton)
        interactiveButtons.append(websiteButton)
        interactiveButtons.append(contactsButton)
        interactiveButtons.append(mapButton)
        
        //6. Setup The Elements
        setBaseConfiguration()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("Business Card Coder Not Implemented") }
    
    deinit { flushFromMemory() }
    
    //---------------------------
    //MARK: - Card Elements Setup
    //---------------------------
    
    /// Sets Up The Base Configuration Of The Business Card & Makes All Elements Invisible To The User
    func setBaseConfiguration(){
        
        //1. Inavalidate The Timer
        nameTimer?.invalidate()
        time = 0
        
        businessCardTarget.isHidden = true
        
        //2. Clear The Name Data
        self.firstNameText.string = ""
        self.surnameText.string = ""
        
        //2. Assign The Profile Image & Rotate It So It Is Hidden
        if cardType == .standard{
            cardHolderImage.geometry?.firstMaterial?.diffuse.contents = UIImage(named: cardData.firstName + cardData.surname)
            cardHolderImage.rotation = Flipped_Rotation
        }
        
        //4. Rotate All Our Interactive Buttons So We Cant See Them
        interactiveButtons.forEach{ $0.rotation = Flipped_Rotation }

    }
    
    //------------------------------
    //MARK: - Card Element Animation
    //------------------------------
    
    /// Aniumates All The Elements Of The Business Card & Makes Them Visible To The User
    func animateBusinessCard(){
        
        let rotationAsRadian = CGFloat(GLKMathDegreesToRadians(180))
        let flipAction = SCNAction.rotate(by: rotationAsRadian, around: SCNVector3(0, 1, 0), duration: 1.5)
       
        switch cardType! {
        
        case .noProfileImage:
            animateBaseElementsWithAction(flipAction)
        case .standard:
            cardHolderImage.runAction(flipAction) { self.animateBaseElementsWithAction(flipAction) }
        }
        
    }

    /// Animates All Elements Except The User Profile Image
    ///
    /// - Parameter flipAction: SCNAction
    func animateBaseElementsWithAction(_ flipAction: SCNAction){
        
        //2. Animate The First Name & Surname
        self.animateTextGeometry(self.firstNameText, forName: self.cardData.firstName, completed: {
            
            self.animateTextGeometry(self.surnameText, forName: self.cardData.surname, completed: {
                
                //3. Animate All The Buttons
                self.interactiveButtons.forEach{ $0.runAction(flipAction)}
                
            })
        })
    }
    
    /// Animates The Presentation Of SCNText
    ///
    /// - Parameters:
    ///   - textGeometry: SCNText
    ///   - name: String
    ///   - completed: () -> Void
    func animateTextGeometry(_ textGeometry: SCNText, forName name: String, completed: @escaping () -> Void ){
        
        //1. Get The Characters From The Name
        let characters = Array(name)
        
        //2. Run The Name Animation
        nameTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            
            //a. If The Current Time Doesnt Equal The Count Of Our Characters Then Continue To Animate Our Text
            if self?.time != characters.count {
                let currentText: String = textGeometry.string as! String
                textGeometry.string = currentText + String(characters[(self?.time)!])
                self?.time += 1
            }else{
                //b. Invalide The Timer, Reset The Variables & Escape
                timer.invalidate()
                self?.time = 0
                completed()
            }
        }
    }
    
    //---------------
    //MARK: - Cleanup
    //---------------

    /// Removes All SCNMaterials & Geometries From An SCNNode
    func flushFromMemory(){
        
        print("Cleaning Business Card")
        
        if let parentNodes = self.parent?.childNodes{ parentNodes.forEach {
            $0.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            $0.geometry = nil
            $0.removeFromParentNode()
            }
        }
        
        for node in self.childNodes{
            node.geometry?.materials.forEach({ (material) in material.diffuse.contents = nil })
            node.geometry = nil
            node.removeFromParentNode()
        }
    }
}
