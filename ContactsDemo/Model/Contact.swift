//
//  Contact.swift
//  ContactsProject
//
//  Created by Carlos Alcala on 29/9/22.
//

import Foundation

struct Contact: Codable {
    let emails: [String]
    let websites: [WebSite]
    let phoneNumbers: [String]
    let provider: String
    let providerId: String
    let firstName: String
    let lastName: String
    let birthday: Birthday
    let locations: [Location]

    private enum CodingKeys : String, CodingKey {
        case emails, websites, phoneNumbers = "phone_numbers", provider, providerId = "provider_id", firstName = "first_name", lastName = "last_name", birthday, locations
    }
}

struct WebSite: Codable {
    let url: String

    private enum CodingKeys : String, CodingKey {
        case url
    }
}

struct Birthday: Codable {
    let day: Int?
    let month: Int?
    let year: Int?

    private enum CodingKeys : String, CodingKey {
        case day, month, year
    }
}

struct Location: Codable {
    let region: String
    let street: String
    let city: String
    let country: String
    let postal: String

    private enum CodingKeys : String, CodingKey {
        case region, street, city, country, postal
    }
}
