//
//  Project2BeRealCloneApp.swift
//  Project2BeRealClone
//
//  Created by David Perez on 9/20/24.
//

import SwiftUI

@main
struct Project2BeRealCloneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
