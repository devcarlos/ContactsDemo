//
//  ContentView.swift
//  contacts
//
//  Created by Carlos Alcala on 29/9/22.
//

import SwiftUI

struct ContactResult: Identifiable {
    var id: String { value }
    let value: String
    let errortype: Bool
}

struct ContactResultError: Identifiable {
    var id: String { error }
    let error: String
}

struct BlueButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}

struct ContentView: View {
    var viewModel = ContactsViewModel()
    @State private var showAlert: ContactResult?
//    @State private var showErrorAlert: ContactResultError?

    var body: some View {
        VStack(spacing: 20) {
            Button("Import Contacts", role: nil, action: {
                viewModel.postContacts(handler: { result in
                    switch result {
                    case .success(let message):
                        showAlert = ContactResult(value: message, errortype: false)
                    case .failure(let error):
                        showAlert = ContactResult(value: error.localizedDescription, errortype: true)
//                        showErrorAlert = ContactResultError(error: error.localizedDescription)
                    }
                })
            })
            .buttonStyle(BlueButton())
        }
        .alert(item: $showAlert) { result in
            Alert(title: Text(result.errortype == true ? "Error" : "Information"), message: Text(result.value), dismissButton: .default(Text("Ok")))
        }
//        .alert(item: $showErrorAlert) { result in
//            Alert(title: Text("Error"), message: Text(result.error), dismissButton: .default(Text("Ok")))
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
