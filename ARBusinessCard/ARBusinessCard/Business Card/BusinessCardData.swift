//
//  BusinessCardData.swift
//  ARBusinessCard
//
//  Created by Josh Robbins on 11/08/2018.
//  Copyright © 2018 BlackMirrorz. All rights reserved.
//

import Foundation

typealias SocialLinkData = (link: String, type: SocialLink)

/// The Information For The Business Card Node & Contact Details
struct BusinessCardData{
    
    var firstName: String
    var surname: String
    var position: String
    var company: String
    var address: BusinessAddress
    var website: SocialLinkData
    var phoneNumber: String
    var email: String
    var stackOverflowAccount: SocialLinkData
    var githubAccount: SocialLinkData
    
}

/// The Associates Business Address
struct BusinessAddress{
    
    var street: String
    var city: String
    var state: String
    var postalCode: String
    var coordinates: (latittude: Double, longtitude: Double)
}

/// The Type Of Social Link
///
/// - Website: Business Website
/// - StackOverFlow: StackOverFlow Account
/// - GitHub: Github Account
enum SocialLink: String{
    
    case Website
    case StackOverFlow
    case GitHub
}
