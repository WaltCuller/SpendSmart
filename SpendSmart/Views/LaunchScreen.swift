//
//  LaunchScreen.swift
//  SpendSmart
//
//  Created by Shaurya Gupta on 2025-03-17.
//

import SwiftUI
import AuthenticationServices
import Supabase

struct LaunchScreen: View {
    @ObservedObject var appState: AppState
    @State private var currentPage = 0
    @Environment(\.colorScheme) private var colorScheme

    // Onboarding feature pages
    private let features = [
        FeatureItem(
            icon: "doc.text.viewfinder",
            title: "Scan Receipts Instantly",
            description: "Just snap a photo and our AI does the rest. No manual data entry needed."
        ),
        FeatureItem(
            icon: "folder.badge.gearshape",
            title: "Automatic Organization",
            description: "Receipts are automatically categorized and sorted for easy retrieval."
        ),
        FeatureItem(
            icon: "chart.pie.fill",
            title: "Smart Spending Insights",
            description: "Track spending patterns and see where your money goes each month."
        ),
        FeatureItem(
            icon: "arrow.counterclockwise.circle.fill",
            title: "Easy Returns",
            description: "Find receipts quickly when you need to return items or file warranty claims."
        )
    ]

    // Add timer for auto-scrolling
    @State private var autoScrollTimer: Timer?

    // Add gradient animation state
    @State private var gradientStart = UnitPoint(x: -1, y: 0.5)
    @State private var gradientEnd = UnitPoint(x: 0, y: 0.5)

    // Add button animation state
    @State private var isButtonHovered = false

    // Alert state
    @State private var showGuestModeAlert = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea(.all)

                VStack(spacing: 0) {
                    // Header - responsive sizing
                    VStack(spacing: adaptiveSpacing(base: 8, geometry: geometry)) {
                        Text("SpendSmart")
                            .font(.instrumentSerifItalic(size: adaptiveFontSize(base: 42, geometry: geometry)))
                            .bold()
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "1E293B"))
                        Text("Less clutter, more clarity.")
                            .font(.instrumentSans(size: adaptiveFontSize(base: 16, geometry: geometry)))
                            .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "64748B"))
                            .padding(.bottom, adaptiveSpacing(base: 20, geometry: geometry))

                        // AI Pill Badge
                        Text("AI-POWERED • 100% FREE")
                            .font(.instrumentSans(size: adaptiveFontSize(base: 12, geometry: geometry)))
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(colorScheme == .dark ? Color(hex: "3B82F6").opacity(0.2) : Color(hex: "DBEAFE"))
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(hex: "60A5FA").opacity(0.2),
                                                Color(hex: "818CF8").opacity(0.8),
                                                Color(hex: "C084FC").opacity(0.8),
                                                Color(hex: "60A5FA").opacity(0.2)
                                            ]),
                                            startPoint: gradientStart,
                                            endPoint: gradientEnd
                                        ),
                                        lineWidth: 1
                                    )
                                    .animation(
                                        Animation.linear(duration: 3)
                                            .repeatForever(autoreverses: false),
                                        value: gradientStart
                                    )
                            )
                            .foregroundColor(colorScheme == .dark ? Color(hex: "60A5FA") : Color(hex: "2563EB"))
                            .onAppear {
                                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                                    gradientStart = UnitPoint(x: 1, y: 0.5)
                                    gradientEnd = UnitPoint(x: 2, y: 0.5)
                                }
                            }
                    }
                    .padding(.top, adaptiveTopPadding(geometry: geometry))

                    // Feature carousel - responsive height
                    TabView(selection: $currentPage) {
                        ForEach(0..<features.count, id: \.self) { index in
                            FeatureView(feature: features[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(height: adaptiveCarouselHeight(geometry: geometry))
                    .padding(.top, adaptiveSpacing(base: 24, geometry: geometry))
                    .animation(.easeInOut(duration: 0.3), value: currentPage)

                    // Page indicator
                    HStack(spacing: 12) {
                        ForEach(0..<features.count, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(currentPage == index ?
                                      (colorScheme == .dark ? Color.white : Color(hex: "3B82F6")) :
                                        (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2)))
                                .frame(width: currentPage == index ? 20 : 12, height: 4)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    .padding(.top, adaptiveSpacing(base: 20, geometry: geometry))

                    Spacer(minLength: adaptiveSpacing(base: 20, geometry: geometry))

                    // Sign in button - at bottom
                    VStack(spacing: 16) {
                        CustomSignInWithAppleButton { result in
                            switch result {
                            case .success(let authResults):
                                handleSignInWithApple(authResults)
                            case .failure(let error):
                                print("Sign in with Apple failed: \(error.localizedDescription)")
                            }
                        }
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.1) : .black.opacity(0.05), radius: 10, x: 0, y: 4)

                        // Continue as guest button
                        Button {
                            showGuestModeAlert = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 16))

                                Text("Continue as guest")
                                    .font(.instrumentSans(size: 16, weight: .medium))
                            }
                            .foregroundColor(colorScheme == .dark ? .white : Color(hex: "3B82F6"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        colorScheme == .dark ? Color.white.opacity(0.2) : Color(hex: "3B82F6").opacity(0.5),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .padding(.top, 8)

                        Text("No in-app purchases or ads. We respect your privacy.")
                            .font(.instrumentSans(size: adaptiveFontSize(base: 12, geometry: geometry)))
                            .foregroundColor(colorScheme == .dark ? .gray : Color(hex: "64748B"))
                            .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, adaptiveBottomPadding(geometry: geometry))
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            checkForExistingSession()
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
        .alert("Continue as Guest", isPresented: $showGuestModeAlert) {
            Button("Continue", role: .none) {
                enableGuestMode()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your receipts will be saved on this device only. To save receipts in the cloud, please sign in with Apple.")
        }
    }

    private var backgroundColor: some View {
        colorScheme == .dark ?
        Color(hex: "0A0A0A").edgesIgnoringSafeArea(.all) :
        Color(hex: "F8FAFC").edgesIgnoringSafeArea(.all)
    }

    private func checkForExistingSession() {
        // Check if there's an active session
        if let user = supabase.auth.currentUser {
            DispatchQueue.main.async {
                appState.userEmail = user.email ?? "No Email"
                appState.isLoggedIn = true
            }
        }
    }

    private func handleSignInWithApple(_ authResults: ASAuthorization) {
        guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = credential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8) else {
            print("Error: Invalid Apple ID credentials")
            return
        }

        Task {
            do {
                let session = try await supabase.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: tokenString))

                print(session.user.id)
//                self.userId = session.user.id

                if let user = supabase.auth.currentUser {
                    DispatchQueue.main.async {
                        // Check if this is a new user (first login)
                        let isNewUser = credential.user == user.id.uuidString && credential.email != nil

                        appState.userEmail = user.email ?? "No Email"
                        appState.isLoggedIn = true

                        // Set first login flag to trigger onboarding
                        if isNewUser {
                            appState.isFirstLogin = true
                        }
                    }
                }

                print("✅ Successfully signed in with Apple via Supabase!")

            } catch {
                print("❌ Supabase authentication failed: \(error.localizedDescription)")
            }
        }
    }

    // Add auto-scroll functions
    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation {
                currentPage = (currentPage + 1) % features.count
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    // Enable guest mode
    private func enableGuestMode() {
        // Create a guest user in Supabase with anonymous sign-in
        Task {
            do {
                // Try to use a standard email/password approach since anonymous auth might not be enabled
                let randomNum = Int.random(in: 10000...99999)
                let guestEmail = "guest\(randomNum)@spend-smart.co"
                let guestPassword = "Guest123!_\(randomNum)"

                // Create a session with email/password
                let session = try await supabase.auth.signUp(
                    email: guestEmail,
                    password: guestPassword,
                    data: ["is_guest": true] // Add metadata to mark as guest user
                )

                print("✅ Created guest user with ID: \(session.user.id)")

                // Enable guest mode in app state with the user ID
                DispatchQueue.main.async {
                    appState.enableGuestMode(userId: session.user.id)

                    // Set first login flag to trigger onboarding for new guest users
                    appState.isFirstLogin = true
                }

            } catch {
                print("❌ Failed to create guest user: \(error.localizedDescription)")

                // Try a different approach - create a local-only guest mode
                print("Falling back to local-only guest mode")
                DispatchQueue.main.async {
                    appState.enableGuestMode()
                }
            }
        }
    }

    // MARK: - Adaptive Layout Helpers

    /// Calculate adaptive font size based on screen height
    private func adaptiveFontSize(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let scaleFactor = screenHeight / 844.0 // iPhone 14 Pro height as baseline
        return max(base * scaleFactor, base * 0.8) // Minimum 80% of base size
    }

    /// Calculate adaptive spacing based on screen height
    private func adaptiveSpacing(base: CGFloat, geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let scaleFactor = screenHeight / 844.0
        return max(base * scaleFactor, base * 0.6) // Minimum 60% of base spacing
    }

    /// Calculate adaptive top padding
    private func adaptiveTopPadding(geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let safeAreaTop = geometry.safeAreaInsets.top

        // For shorter screens (like 16:9), reduce top padding significantly
        if screenHeight < 750 {
            return max(safeAreaTop + 20, 40)
        } else if screenHeight < 800 {
            return max(safeAreaTop + 40, 60)
        } else {
            return max(safeAreaTop + 60, 80)
        }
    }

    /// Calculate adaptive bottom padding
    private func adaptiveBottomPadding(geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height
        let safeAreaBottom = geometry.safeAreaInsets.bottom

        // For shorter screens, reduce bottom padding
        if screenHeight < 750 {
            return max(safeAreaBottom + 20, 30)
        } else {
            return max(safeAreaBottom + 30, 40)
        }
    }

    /// Calculate adaptive carousel height
    private func adaptiveCarouselHeight(geometry: GeometryProxy) -> CGFloat {
        let screenHeight = geometry.size.height

        // Adjust carousel height based on available screen space
        if screenHeight < 750 {
            // For 16:9 displays and shorter screens
            return min(screenHeight * 0.35, 280)
        } else if screenHeight < 800 {
            return min(screenHeight * 0.4, 320)
        } else {
            return min(screenHeight * 0.45, 400)
        }
    }
}
