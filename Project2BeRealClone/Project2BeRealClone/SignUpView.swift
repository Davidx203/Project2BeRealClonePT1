//
//  SignUpView.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/22/24.
//

import SwiftUI
import ParseCore

struct SignUpView: View {
    @State var username = ""
    @State var password = ""
    @Binding var signUpTapped: Bool
    @State var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Create Account.")
                .font(.title)
            TextField("Username", text: $username)
                .padding(5)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            SecureField("Password", text: $password)
                .padding(5)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Button(action: {
                signUp()
            }, label: {
                Text("Sign Up")
                    .padding(10)
            })
            .frame(maxWidth: .infinity)
            .background(Color(red: 0.15, green: 0.15, blue: 0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(35)
        .foregroundColor(.white)
        .background(Color.black.ignoresSafeArea())
    }
    
    // Signup function
    func signUp() {
        let user = PFUser()
        user.username = username
        user.password = password
        
        user.signUpInBackground { (succeeded, error) in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Account created successfully!"
                signUpTapped = false
            }
        }
    }
}

#Preview {
    SignUpView(signUpTapped: .constant(true))
}
