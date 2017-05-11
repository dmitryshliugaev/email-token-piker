//
//  ViewController.swift
//  EmailTokenPicker
//
//  Created by Dmitry Shlyugaev on 07/05/2017.
//
//

import UIKit
import Contacts

class ViewController: UIViewController {

    @IBOutlet weak var tokenView: ETPTokenView!
    
    open lazy var contacts: [[String: String]] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        var relatedList: [[String: String]] = []
        
        for contact: CNContact in results {
            if contact.emailAddresses.count > 0 {
                for email in contact.emailAddresses {
                    relatedList.append(["name": contact.givenName + " " + contact.familyName,
                                        "email": email.value as String])
                    
                }
                
            }
        }
        
        return relatedList
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tokenView.delegate = self
        tokenView.promptText = ""
        tokenView.placeholder = "email list"
        tokenView.placeholderColor = .darkGray
        tokenView.descriptionText = ""
        tokenView.tokenizingCharacters = [",", " "]
        tokenView.direction = .vertical
        tokenView.shouldDisplayAlreadyTokenized = true
        tokenView.backgroundColor = .clear
        tokenView.shouldUntokenizeOnEndEditing = false
        tokenView.maxTokenLimit = -1
        tokenView.minimumCharactersToSearch = 0
        tokenView.returnKeyType(type: .done)
    }
}

extension ViewController: ETPTokenViewDelegate {
    func tokenView(_ token: ETPTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.characters.isEmpty) {
            completion!(contacts as Array<AnyObject>)
            return
        }
        
        var data: [[String: String]] = []
        for contact: [String: String] in contacts {
            if let email: String = contact["email"] {
                if email.lowercased().range(of: string.lowercased()) != nil {
                    data.append(contact)
                }
            }
        }
        
        completion!(data as Array<AnyObject>)
    }
    
    func tokenView(_ token: ETPTokenView, displayTitleForObject object: AnyObject) -> String {
        return object["name"] as! String
    }
    
    func tokenView(_ token: ETPTokenView, displayDetailForObject object: AnyObject) -> String {
        return object["email"] as! String
    }
    
    func tokenView(_ token: ETPTokenView, titleForToken object: AnyObject) -> String {
        return object["email"] as! String
    }
    
    func tokenView(_ tokenView: ETPTokenView, willAddToken token: ETPToken) {
        if !ETPUtils.validateEmail(token.title) {
            token.tokenBackgroundColor = UIColor.red
        }
    }
}
