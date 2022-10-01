//
//  ContactsViewModel.swift
//  Contacts
//
//  Created by Carlos Alcala on 29/9/22.
//

import Foundation
import Contacts
import SwiftUI

typealias Handler<T> = (Result<T, Error>) -> Void

enum ContactError: Error {
    case createURL
    case modelJSON
    case requestFailed
    case dataParseJSON
    case prettyJSON
    case printJSON
}

extension ContactError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .createURL:
            return "Cannot create URL"
        case .modelJSON:
            return "Trying to convert model to JSON data"
        case .requestFailed:
            return "The request failed"
        case .dataParseJSON:
            return "The Data Failed parse to JSON"
        case .prettyJSON:
            return "The Pretty JSON process failed"
        case .printJSON:
            return "The Print Pretty JSON failed"
        }
    }
}

class ContactsViewModel {

    var phoneContacts: [Contact] = []

    init() {
        fetchContacts()
    }

    private func fetchContacts() {
        var contacts = [CNContact]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactPostalAddressesKey, CNContactBirthdayKey, CNContactEmailAddressesKey, CNContactUrlAddressesKey, CNContactIdentifierKey] as [CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        let contactStore = CNContactStore()
        do {
            try contactStore.enumerateContacts(with: request) {
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                contacts.append(contact)
            }
        }
        catch {
            debugPrint("unable to fetch contacts")
        }

        formatContact(contacts: contacts)
    }

    private func formatContact(contacts: [CNContact]) {
        contacts.forEach { c in
            var emails: [String] = []
            for email in c.emailAddresses {
                emails.append(email.value.description)
            }

            var websites: [WebSite] = []
            for website in c.urlAddresses {
                let w = WebSite(url: website.value.description)
                websites.append(w)
            }

            var phoneNumbers: [String] = []
            for phoneNumber in c.phoneNumbers {
                phoneNumbers.append(phoneNumber.value.stringValue)
            }

            let birthday = Birthday(day: c.birthday?.day, month: c.birthday?.month, year: c.birthday?.year)

            var locations: [Location] = []
            for location in c.postalAddresses {
                let l = Location(region: location.value.state , street: location.value.street, city: location.value.city, country: location.value.country, postal: location.value.postalCode)
                locations.append(l)
            }

            let singleContact = Contact(emails: emails, websites: websites, phoneNumbers: phoneNumbers, provider: "", providerId: c.identifier, firstName: c.givenName, lastName: c.familyName, birthday: birthday, locations: locations)

            phoneContacts.append(singleContact)
        }
    }

    func postContacts(handler: @escaping Handler<String>) {
        
        guard let url = URL(string: "https://clay-ios-import.herokuapp.com/import") else {
            print("Error: Cannot create URL")

            handler(.failure(ContactError.createURL))
            return
        }

        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(phoneContacts) else {
            print("Error: Trying to convert model to JSON data")
            handler(.failure(ContactError.modelJSON))
            return
        }
        // Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                guard let error = error else {
                    return
                }
                print("Error: error calling POST \(error)")

                handler(.failure(error))
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")

                handler(.failure(ContactError.requestFailed))
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")

                    handler(.failure(ContactError.dataParseJSON))
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")

                    handler(.failure(ContactError.prettyJSON))
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")

                    handler(.failure(ContactError.printJSON))
                    return
                }

                handler(.success("Import Success"))
                print(prettyPrintedJson)

            } catch {
                print("Error: Trying to convert JSON data to string")
                handler(.failure(error))
                return
            }

        }.resume()
    }
}
