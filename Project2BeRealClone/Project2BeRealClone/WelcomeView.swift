//
//  ContentView.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/20/24.
//
import SwiftUI
import ParseCore

struct WelcomeView: View {
    @State var username = ""
    @State var password = ""
    
    @State var signUpTapped = false
    @State var errorMessage = ""
    @State var isLoggedIn = false // New state for navigation
    
    var body: some View {
        NavigationView {
            VStack {
                Text("BeReal.")
                    .font(.title)
                TextField("Username", text: $username)
                    .padding(5)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                SecureField("Password", text: $password) // Use SecureField for password
                    .padding(5)
                    .background(Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: {
                    logIn()
                }, label: {
                    Text("Login")
                        .padding(10)
                })
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Button(action: {
                    signUpTapped = true
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
                
                // Navigate to HomeScreenView if logged in
                NavigationLink(destination: HomeScreenView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(35)
            .foregroundColor(.white)
            .background(Color.black.ignoresSafeArea())
            .sheet(isPresented: $signUpTapped, content: {
                SignUpView(signUpTapped: $signUpTapped)
            })
        }
    }
    
    // Login function
    func logIn() {
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = ""
                isLoggedIn = true // Set this to true to trigger navigation
            }
        }
    }
}

#Preview {
    WelcomeView()
}
