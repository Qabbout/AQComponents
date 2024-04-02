//
//  AQContactsManager.swift
//
//
//  Created by Abdulrahman Qabbout on 02/04/2024.
//

import UIKit

import Contacts
import ContactsUI

public typealias ContactPickerCompletion = (_ didCancel:Bool, _ selectedContact: CNContact?) -> Void

final public class MyCNContactPickerViewController: CNContactPickerViewController {
    public var completion:ContactPickerCompletion?
}

final public class AQContactsManager: NSObject {
    
    public static let shared = AQContactsManager()
    public var contactsList = [CNContact]()
    fileprivate var contactPicker:MyCNContactPickerViewController!
    
    private override init() {
        super.init()
        
        contactPicker = MyCNContactPickerViewController()
        contactPicker.displayedPropertyKeys = [
            CNContactIdentifierKey,
            CNContactGivenNameKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataAvailableKey
        ]
        self.defaultInit()
    }
    
    // MARK: - Default Init
    public func defaultInit() {
        contactsList = self.fetchTheDeviceContactsArray()
    }
    
    // MARK: - Ask For Permission
    public func askForPermission() {
        let _ = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
    }
    
    public func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            completionHandler(false)
        case .restricted, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                DispatchQueue.main.async(execute: {
                    if granted {
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                })
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Fetch The Device Contacts
    public func fetchTheDeviceContactsArray(forceFetch:Bool = false ) -> [CNContact] {
        if contactsList.count > 0 {
            if forceFetch == false {
                return contactsList
            }
            else {
                contactsList.removeAll()
            }
        }
        
        let contactStore = CNContactStore()
        var contacts = [CNContact]()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys()
        ]
        
        let request = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
            return contacts
        } catch {
            return []
        }
    }
    
    // MARK: - View Contact Details
    public func viewContactDetails(viewController:UIViewController, contactId:String, editContact:Bool = true) {
        
        let deviceContacts = self.fetchTheDeviceContactsArray()
        var foundContact:CNContact!
        
        DispatchQueue.main.async {
            for c in 0..<deviceContacts.count {
                let deviceContact = deviceContacts[c]
                if deviceContact.identifier == contactId {
                    foundContact = deviceContact
                    break
                }
            }
            
            if foundContact != nil {
                let unkvc = CNContactViewController.init(for: foundContact)
                unkvc.hidesBottomBarWhenPushed = true
                if editContact {
                    unkvc.setEditing(true, animated: true)
                }
                unkvc.message = ""
                unkvc.contactStore = CNContactStore()
                unkvc.delegate = self
                unkvc.allowsActions = false
                viewController.navigationController?.pushViewController(unkvc, animated: true)
            }
        }
    }
    
    // MARK: - Check if contact is exist in device
    public func checkIfContactExistInDevice(contactId:String) -> Bool {
        
        let deviceContacts = self.fetchTheDeviceContactsArray()
        var foundContact:CNContact!
        
        for c in 0..<deviceContacts.count {
            let deviceContact = deviceContacts[c]
            if deviceContact.identifier == contactId {
                foundContact = deviceContact
                break
            }
        }
        
        if foundContact != nil {
            return true
        }
        else {
            return false
        }
    }
    
    // MARK: - Check if contact is exist in device
    public func getContactFromDevice(contactId:String) -> CNContact? {
        
        let deviceContacts = self.fetchTheDeviceContactsArray()
        var foundContact:CNContact!
        
        for c in 0..<deviceContacts.count {
            let deviceContact = deviceContacts[c]
            if deviceContact.identifier == contactId {
                foundContact = deviceContact
                break
            }
        }
        
        if foundContact != nil {
            return foundContact
        }
        else {
            return nil
        }
    }
    
    // MARK: - Create New Contact
    @objc public func createNewContact(phoneText:String, emailText:String, givenName:String, note:String, barTintColor:UIColor, barBackgroundColor:UIColor) {
        
        let topView = UIApplication.shared.topViewController() ?? UIViewController()
        let contact = CNMutableContact()
        
        let phone = CNLabeledValue(label: CNLabelPhoneNumberMobile, value:CNPhoneNumber(stringValue: phoneText))
        contact.phoneNumbers = [phone]
        
        let workEmail = CNLabeledValue(label:CNLabelWork, value: emailText as NSString)
        contact.emailAddresses = [workEmail]
        contact.givenName = givenName
        contact.note = note
        
        let unkvc = CNContactViewController.init(for: contact)
        unkvc.delegate = self
        unkvc.hidesBottomBarWhenPushed = true
        unkvc.setEditing(true, animated: true)
        unkvc.message = ""
        unkvc.contactStore = CNContactStore()
        unkvc.allowsActions = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
                // Use the window here
                let statusBar = UIView(frame: window.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
                statusBar.backgroundColor = barBackgroundColor
                window.addSubview(statusBar)
            }
            
            //Set navigation bar subView background colour
            for view in unkvc.navigationController?.navigationBar.subviews ?? [] {
                view.tintColor = barTintColor
                view.backgroundColor = barBackgroundColor
            }
        })
        
        topView.navigationController?.pushViewController(unkvc, animated: true)
    }
    
    // MARK: - Open Contacts List
    public func openContactsList(animated:Bool = true, compeltion:@escaping ContactPickerCompletion) {
        let topView = UIApplication.shared.topViewController()
        contactPicker.delegate = self
        contactPicker.completion = compeltion
        topView?.present(contactPicker, animated: animated, completion: nil)
    }
}

// MARK: - CNContactPickerDelegate
extension AQContactsManager: CNContactPickerDelegate {
    
    /*!
     * @abstract    Invoked when the picker is closed.
     * @discussion  The picker will be dismissed automatically after a contact or property is picked.
     */
    public func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        let mypicker = picker as? MyCNContactPickerViewController ?? MyCNContactPickerViewController()
        mypicker.completion?(true, nil)
    }
    
    /*!
     * @abstract    Singular delegate methods.
     * @discussion  These delegate methods will be invoked when the user selects a single contact or property.
     */
    public func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let mypicker = picker as? MyCNContactPickerViewController ?? MyCNContactPickerViewController()
        DispatchQueue.main.async {
            
            mypicker.completion?(false, contact)
        }
    }
}

// MARK: - CNContactViewControllerDelegate
extension AQContactsManager: CNContactViewControllerDelegate {
    /*!
     * @abstract    Called when the user selects a single property.
     * @discussion  Return @c NO if you do not want anything to be done or if you are handling the actions yourself.
     * @return      @c YES if you want the default action performed for the property otherwise return @c NO.
     */
    public func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        
        return false
    }
    
    /*!
     * @abstract    Called when the view has completed.
     * @discussion  If creating a new contact, the new contact added to the contacts list will be passed.
     *              If adding to an existing contact, the existing contact will be passed.
     * @note        It is up to the delegate to dismiss the view controller.
     */
    public func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        let topView = UIApplication.shared.topViewController()
        topView?.navigationController?.popViewController(animated: true)
        if let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) {
            // Use the window here
            let statusBar = UIView(frame: window.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = .clear
            window.addSubview(statusBar)
        }
        
        
        if contact != nil {
            //Update contacts array
            AQContactsManager.shared.contactsList = AQContactsManager.shared.fetchTheDeviceContactsArray(forceFetch: true)
        }
    }
}
