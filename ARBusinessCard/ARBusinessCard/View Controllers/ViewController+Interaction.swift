//
//  ViewController+Interaction.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 12/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MessageUI
import WebKit
import SideMenu
import Contacts

extension ViewController{
    
    //-----------------------
    //MARK: - UserInteraction
    //-----------------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //1. Get The Current Touch Location & Perform An SCNHitTest To Detect Which Nodes We Have Touched
        guard let currentTouchLocation = touches.first?.location(in: self.augmentedRealityView),
            let hitTestResult = self.augmentedRealityView.hitTest(currentTouchLocation, options: nil).first?.node.name
            else { return }
        
        //2. Perform The Neccessary Action Based On The Hit Node
        switch hitTestResult {
        case "PhoneNumber":
            callPhoneNumber(businessCard.cardData.phoneNumber)
        case "TextMessage":
            sendSMSTo(businessCard.cardData.phoneNumber)
        case "Email":
            sendEmailTo(businessCard.cardData.email)
        case "Website":
            socialLinkData = businessCard.cardData.website
            displayWebSite()
        case "GitHub":
            socialLinkData = businessCard.cardData.githubAccount
            displayWebSite()
        case "StackOverFlow":
            socialLinkData = businessCard.cardData.stackOverflowAccount
            displayWebSite()
        case "SaveToContacts":
            saveContactToAddressBook()
        case "Map":
            displayWebSite()
        default: ()
        }
    
    }
    
    /// Calls The Phone Number On The Business Card
    ///
    /// - Parameter number: String
    func callPhoneNumber(_ number: String){
        
        if let url = URL(string: "tel://\(number)"), UIApplication.shared.canOpenURL(url) {
            
            menuShown = true
            
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
           
        }else{
            print("Error Trying To Connect To Mobile Provider")
        }
    }
    
    
    /// Sends An SMS To The Number On The Business Card
    ///
    /// - Parameter number: String
    func sendSMSTo(_ number: String){
        
        if MFMessageComposeViewController.canSendText(){
            menuShown = true
            
            let smsController = MFMessageComposeViewController()
            smsController.body = "Enquiry About Your Business"
            smsController.recipients = [number]
            smsController.messageComposeDelegate = self
            present(smsController, animated: true, completion: nil)
        }else{
            print("Error Loading SMS Composer")
        }
        
    }
    
    /// Sends An Email To The Business Card Holder
    ///
    /// - Parameter recipient: String
    func sendEmailTo(_ recipient: String){
        
        if MFMailComposeViewController.canSendMail(){
            
            menuShown = true
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setSubject("Enquiry About Your Business")
            mailComposer.setToRecipients([recipient])
            present(mailComposer, animated: true, completion: nil)
        }else{
            print("Error Loading Email Composer")
        }
        
    }
    
    /// Loads One Of The Website From Business Card
    func displayWebSite() { self.performSegue(withIdentifier: "webViewer", sender: nil) }
    
    //----------------------------------
    //MARK: - Save Associate To Contacts
    //----------------------------------
    
    /// Saves The Business Profile To The Users Device
    func saveContactToAddressBook(){
        
        //1. Create A Contact
        let businessContact = CNMutableContact()
        
        //2. Create The First & Last Names Of The Contact & The Associates Job Title
        let fullName = businessCard.cardData.firstName + " " + businessCard.cardData.surname
        businessContact.givenName = businessCard.cardData.firstName
        businessContact.familyName = businessCard.cardData.surname
        businessContact.jobTitle = businessCard.cardData.position
        businessContact.organizationName = businessCard.cardData.company
        
        //3. Create The Profile Image
        if let profileImage = UIImage(named: businessCard.cardData.firstName+businessCard.cardData.surname),
            let profileData  = UIImagePNGRepresentation(profileImage){
            businessContact.imageData = profileData
        }
        
        //4. Set The Associates Work Email
        let workEmail = CNLabeledValue(label:CNLabelWork, value: businessCard.cardData.email as NSString)
        businessContact.emailAddresses = [workEmail]
        
        //5. Set The Associates Work Phone Number
        businessContact.phoneNumbers = [CNLabeledValue ( label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: businessCard.cardData.phoneNumber))]
        
        //6. Set The Associates Work Address
        let address = CNMutablePostalAddress()
        let cardAdress = businessCard.cardData.address
        address.street = cardAdress.street
        address.city = cardAdress.city
        address.postalCode = cardAdress.postalCode
        
        businessContact.postalAddresses = [CNLabeledValue(label: CNLabelWork, value: address)]
        
        //7. Set The Associates Social Profiles
        let stackOverflowProfile = CNLabeledValue(label: "Twitter",
                                                  value: CNSocialProfile(urlString: businessCard.cardData.stackOverflowAccount.link,
                                                                         username: "",
                                                                         userIdentifier: "",
                                                                         service: businessCard.cardData.stackOverflowAccount.type.rawValue))
        let githubProfile = CNLabeledValue(label: "Github",
                                           value:  CNSocialProfile(urlString: businessCard.cardData.githubAccount.link,
                                                                   username: "",
                                                                   userIdentifier: "",
                                                                   service: businessCard.cardData.githubAccount.type.rawValue))
        
        
        businessContact.socialProfiles = [stackOverflowProfile, githubProfile]
        
        //8. Save It To The Device
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(businessContact, toContainerWithIdentifier:nil)
        
        do{
            try store.execute(saveRequest)
            showSaveMessage("\(fullName) Saved To Contacts")
            
        }catch{
            showSaveMessage("\(fullName) Not Saved To Contacts")
        }
        
    }
    
    /// Shows A Success Or Error Message When Trying To Save The Associate's Contact Details
    ///
    /// - Parameter message: String
    func showSaveMessage(_ message: String){
        
        let saveMessage = UIAlertController(title: "Message From BlackMirrorz", message: message, preferredStyle: .alert)
        let dismissButton = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        saveMessage.addAction(dismissButton)
        present(saveMessage, animated: true, completion: nil)
    }
    
}
