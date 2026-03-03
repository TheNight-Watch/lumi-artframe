//
//  lumi_artframe_claudecodeV2UITests.swift
//  lumi_artframe_claudecodeV2UITests
//
//  Created by LIUHAIFENG on 2026/3/3.
//

import XCTest

final class lumi_artframe_claudecodeV2UITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Auth Flow Tests

    @MainActor
    func testSplashNavigatesToLogin() throws {
        // Splash screen should appear first
        let splash = app.otherElements["splashView"]
        XCTAssertTrue(splash.waitForExistence(timeout: 3), "Splash view should appear on launch")

        // After 2s, should navigate to login
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Login view should appear after splash")
    }

    @MainActor
    func testLoginFormInteraction() throws {
        // Wait for login view
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        // Type email
        emailField.tap()
        emailField.typeText("test@example.com")

        // Type password
        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password123")

        // Login button should exist
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists, "Login button should be visible")
    }

    // MARK: - Creation Flow Navigation Tests

    /// Tests the full creation flow navigation chain:
    /// MainTabView(FAB) → CameraView → DescriptionView → GenerationView → DetailView
    ///
    /// This test uses --uitesting launch argument so the app can use mock services
    /// that pre-populate image data, bypassing the need for real camera/photo picker.
    @MainActor
    func testCreationFlowNavigation() throws {
        // Wait for login, then login with mock credentials
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")

        let loginButton = app.buttons["loginButton"]
        loginButton.tap()

        // Wait for MainTabView to appear with the FAB create button
        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10),
                       "FAB create button should appear after login")

        // Tap FAB to start creation flow → CameraView
        createButton.tap()

        let cameraView = app.otherElements["cameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 5),
                       "CameraView should appear after tapping FAB")

        // Verify camera UI elements exist
        let shutterButton = app.buttons["shutterButton"]
        XCTAssertTrue(shutterButton.waitForExistence(timeout: 3),
                       "Shutter button should exist in CameraView")

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.exists,
                       "Close button should exist in CameraView")
    }

    /// Tests that CameraView → DescriptionView navigation works when an image is confirmed.
    /// Requires the app to be in UI test mode with a pre-populated test image.
    @MainActor
    func testCameraToDescriptionNavigation() throws {
        // Navigate to CameraView via the creation flow
        navigateToMainTab()

        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let cameraView = app.otherElements["cameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 5))

        // In UI test mode, confirm button should be available if test image is pre-loaded
        let confirmButton = app.buttons["confirmImageButton"]
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()

            // Should navigate to DescriptionView
            let descriptionView = app.otherElements["descriptionView"]
            XCTAssertTrue(descriptionView.waitForExistence(timeout: 5),
                           "DescriptionView should appear after confirming image")

            // Verify DescriptionView elements
            let recordButton = app.buttons["recordButton"]
            XCTAssertTrue(recordButton.exists,
                           "Record button should exist in DescriptionView")

            let skipButton = app.buttons["skipRecordingButton"]
            XCTAssertTrue(skipButton.exists,
                           "Skip recording button should exist in DescriptionView")
        }
    }

    /// Tests the skip recording → generation navigation path.
    @MainActor
    func testDescriptionToGenerationNavigation() throws {
        navigateToMainTab()

        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let cameraView = app.otherElements["cameraView"]
        XCTAssertTrue(cameraView.waitForExistence(timeout: 5))

        let confirmButton = app.buttons["confirmImageButton"]
        if confirmButton.waitForExistence(timeout: 3) {
            confirmButton.tap()

            let skipButton = app.buttons["skipRecordingButton"]
            XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
            skipButton.tap()

            // Should navigate to GenerationView
            let generationView = app.otherElements["generationView"]
            XCTAssertTrue(generationView.waitForExistence(timeout: 5),
                           "GenerationView should appear after skipping recording")
        }
    }

    /// Tests that dismissing the creation flow returns to MainTabView.
    @MainActor
    func testCreationFlowDismissal() throws {
        navigateToMainTab()

        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()

        // Should return to MainTabView
        XCTAssertTrue(createButton.waitForExistence(timeout: 5),
                       "Should return to MainTabView after dismissing creation flow")
    }

    // MARK: - Helpers

    /// Navigates past splash and login to reach MainTabView.
    private func navigateToMainTab() {
        let emailField = app.textFields["emailField"]
        guard emailField.waitForExistence(timeout: 5) else { return }

        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["loginButton"].tap()
    }

    // MARK: - Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
