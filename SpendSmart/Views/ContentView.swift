//
//  ContentView.swift
//  SpendSmart
//
//  Created by Shaurya Gupta on 2025-03-12.
//

import SwiftUI
import AuthenticationServices
import Supabase
import UIKit

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.isFirstLogin && !appState.isOnboardingComplete {
                    // Show onboarding for first-time users after account creation
                    OnboardingView()
                        .environmentObject(appState)
                } else {
                    // Main app interface
                    TabView {
                        DashboardView(email: appState.userEmail)
                            .environmentObject(appState)
                            .tabItem {
                                Image(systemName: "house")
                                Text("Home")
                            }

                        NavigationView {
                            HistoryView()
                                .environmentObject(appState)
                        }
                        .tabItem {
                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                            Text("History")
                        }

                        NavigationView {
                            SettingsView()
                                .environmentObject(appState)
                        }
                        .tabItem {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                    }
                }
            } else {
                LaunchScreen(appState: appState)
                    .task {
                        // Check for existing session on app launch
                        if appState.isGuestUser && appState.guestUserId != nil {
                            // Guest mode already restored from UserDefaults in AppState init
                            print("✅ Using guest mode from UserDefaults")
                        } else if let user = supabase.auth.currentUser {
                            // Check if this is a guest user by looking at the email
                            let isGuest = user.email?.contains("guest") ?? false

                            if isGuest {
                                // Restore guest mode
                                appState.enableGuestMode(userId: user.id)
                                print("✅ Restored guest session from Supabase for user: \(user.id)")
                            } else {
                                // Regular user
                                appState.userEmail = user.email ?? "No Email"
                                appState.isLoggedIn = true
                                print("✅ Restored regular user session for: \(user.email ?? "unknown")")
                            }
                        } else {
                            print("No existing session found")
                        }
                    }
            }
        }
        .overlay(
            // Version update alert overlay
            Group {
                if appState.showVersionUpdateAlert {
                    VersionUpdateAlert(
                        versionInfo: VersionInfo(
                            currentVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                            latestVersion: appState.availableVersion,
                            releaseNotes: appState.releaseNotes.isEmpty ? nil : appState.releaseNotes
                        ),
                        onAction: { action in
                            handleVersionUpdateAction(action)
                        }
                    )
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: appState.showVersionUpdateAlert)
                }
            }
        )
    }

    private func handleVersionUpdateAction(_ action: VersionUpdateAction) {
        let versionUpdateManager = VersionUpdateManager.shared
        versionUpdateManager.handleUserAction(action, for: appState.availableVersion)

        // Dismiss the alert
        appState.showVersionUpdateAlert = false

        // Clear the version update state
        appState.availableVersion = ""
        appState.releaseNotes = ""
    }
}
