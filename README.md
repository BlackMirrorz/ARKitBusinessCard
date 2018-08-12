
# ARKit Business Card

This project is a basic example of creating a fully interactive business card in *ARKit*.

The app uses `ARImageTrackingConfiguration` to detect the business card and then present interactive content.

All the code is fully commented so it should be very easy to follow.

The image below shows the `SCNScene Business Card` template:

![Business Card Template](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/businessCardLayout.png)

The use of a template makes the creation of interactive business cards simple, without the need for manually calculating the position of interactive buttons, and labels etc.  And means that you can easily configure the app to detect as many different business cards as you need.

The `BusinessCardData Struct` formats all the data needed for each element of the business card to work:

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
    
    struct BusinessAddress{
    
        var street: String
        var city: String
        var state: String
        var postalCode: String
        var coordinates: (latittude: Double, longtitude: Double)
    }
    
    enum SocialLink: String{
    
        case Website
        case StackOverFlow
        case GitHub
    }

As such generating a `BusinessCard` (which is an `SCNNode` subclass) is as simple as this:

    extension  ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {

        //1. Check We Have A Valid Image Anchor
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
    
       //2. Get The Detected Reference Image
       let referenceImage = imageAnchor.referenceImage

      //3. Load Our Business Card
      if let matchedBusinessCardName = referenceImage.name, matchedBusinessCardName == "BlackMirrorz"{

         //4. Create Our Business Card
         let businessCardData = BusinessCardData(firstName: "Josh",
         surname: "Robbins",
         position: "Software Engineer",
         company: "BlackMirrorz",
         address: BusinessAddress(street: "1 Infinite Loop",
         city: "Cupertino",
         state: "CA",
         postalCode: "95015",
         coordinates: (latittude: 37.3349, longtitude: -122.0090201)),
         website: SocialLinkData(link: "https://www.blackmirrorz.tech", type: .Website),
         phoneNumber: "+821076337633",
         email: "josh.robbins@blackmirroz.tech",
         stackOverflowAccount: SocialLinkData(link: "https://stackoverflow.com/users/8816868/josh-robbins", type: .StackOverFlow),
         githubAccount: SocialLinkData(link: "https://github.com/BlackMirrorz", type: .GitHub))

         //5. Assign It To The Business Card Node
         let businessCard = BusinessCard(data: businessCardData, cardType: .noProfileImage)
         businessCardPlaced = true
         node.addChildNode(businessCard)
         
       }
      }
    }

When the business card is detected, the Firstname and Surname of the card holder is animated with a typing like effect, and the buttons are animated as well.

**Interactive Elements:**

Each button performs a different function:
![ARKit Business Card Icons](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/icons.png )The `StackOverFlow Button` presents a slide out `WKWebView` to display the users `StackOverFlow` Account.
The `GitHub Button` presents a slide out `WKWebView` to display the users `GitHub` Account.
The `Internet Button` presents a slide out `WKWebView` to display the users website.
The `Phone Button` allows the user to call the Business Telephone Number.
The `SMS Button` presents an `MFMessageComposeViewController` allowing the user to send a text message to the business.
The `Email Button` presents an `MFMailComposeViewController` allowing the user to email the business.
The `Contact Button` creates a `CNMutableContact` and saves the business as a new contact on the users device.
The `Location Button` presents a slide out `MKMapView` to display the users Businesses Location.

**Requirements:**

This project was written in Swift 4, and at the time of writing uses Xcode 10 Beta.
The project is setup for iPhone, and in Portait Orientation.

**Repositories Used:**

Since rendering a `WKWebView` as an `SCNMaterial`, I had to look at other ways to allow the content to be fully interactive.

As such I made use of the fabulous repository `SideMenu` by `Jonkykong` which is available here:
[SideMenu](https://github.com/jonkykong/SideMenu)

This allows the user to still experience `ARKit` whilst allowing an almost split screen like effect:
![ARKit Business Card Split Screen](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/slideMenu.png )

**To Do:**

Allow the user to create a business card within the app.
