

# ARKit Business Card

This project is a basic example of creating a fully interactive business card in *ARKit*.

The app uses `ARImageTrackingConfiguration` to detect the business card and then present interactive content.

As with all my work,  the code is fully commented (probably way too much!) so it should be very easy to follow.

**Branches:**

The Master Branch was originally compiled in XCode10 Beta using Swift 4.

An updated Branch called 'Swift4.2' contains the project built in XCode 10.5 Beta and uses Swift 4.2.

**Requirements:**

The project is setup for iPhone, and in Portait Orientation.

**Notes:**
If you want to use this project on IOS11.4 you will need to change the `ARImageTrackingConfiguration` to `ARWorldTrackingConfiguration` and make some minor tweaks to the `Configuration` settings in the ViewController, all of which are very trivial.

Some people have had some issues with SideMenu. If I remember correctly, I had to manually change a few of the names, as some have changed in later versions of Swift. Again these are all very trivial!

**Using The Templates:**

In the templates folder of this repository there are 2 files:

 1. businessCardPrint.png
 2. businessCardTemplate.ai
 
To get up and running you can print out the `businessCardPrint.png` or even display it in preview to test the apps functionality. Currently this is sized at 10cm by 5cm, although of course you can change this as you wish!

The template `ai file` is provided so you can make your own business cards.

The image below shows the `SCNScene Business Card` template:

The semi transparent area is the actual size of our business card (imageTarget) as such you can change and organise things as you wish.

![Business Card Template](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/businessCardLayout.png)

The use of a template makes the creation of interactive business cards simple, without the need for manually calculating the position of interactive buttons, and labels etc.  And means that you can easily configure the app to detect as many different business cards as you need.

There are 2 Templates:

 1. `BusinessCardTemplateA` (which doesn't show the users image),
 2. `BusinessCardTemplateB` (which shows the users image).

If you are using the 1st template you must currently provide an image, which for the sake of simplicity; add an image of the cardholder to the `Assetts` folder and name it like so:
firstname+surname e.g. JoshRobbins.png

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

A `BusinessCard` is initialised like so:

    /// Creates The Business Card
    ///
    /// - **Parameters**:
    /// - data: BusinessCardData
    /// - cardType: CardTemplate
    init(data: BusinessCardData, cardType: CardTemplate) {
    }

Whereby the `data` argument takes the data needed to populate the template and the `cardType` takes either of the following values:

    case noProfileImage
    case standard

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
![ARKit Business Card Icons](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/icons.png )

 - The `StackOverFlow Button` presents a slide out `WKWebView` to display the users `StackOverFlow` Account.
 - The `GitHub Button` presents a slide out `WKWebView` to display the users `GitHub` Account.
 - The `Internet Button` presents a slide out `WKWebView` to display the users website.
 - The `Phone Button` allows the user to call the Business Telephone Number.
 - The `SMS Button` presents an `MFMessageComposeViewController` allowing the user to send a text message to the business.
 - The `Email Button` presents an `MFMailComposeViewController` allowing the user to email the business.
 - The `Contact Button` creates a `CNMutableContact` and saves the business as a new contact on the users device.
 - The `Location Button` presents a slide out `MKMapView` to display the users Businesses Location.

**Repositories Used:**

Since rendering a `WKWebView` as an `SCNMaterial` isn't possible, I had to look at other ways to allow the content to be fully interactive.

As such I made use of the fabulous repository `SideMenu` by `Jonkykong` which is available here:
[SideMenu](https://github.com/jonkykong/SideMenu)

This allows the user to still experience `ARKit` whilst allowing an almost split screen like effect:

![ARKit Business Card Split Screen](https://www.blackmirrorz.tech/images/BlackMirrorz/ARBusinessCardScreenShots/slideMenu.png )

**To Do:**

Allow the user to create a business card within the app.
