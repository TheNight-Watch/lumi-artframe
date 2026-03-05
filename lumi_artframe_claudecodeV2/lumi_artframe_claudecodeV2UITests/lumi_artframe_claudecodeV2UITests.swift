//
//  lumi_artframe_claudecodeV2UITests.swift
//  lumi_artframe_claudecodeV2UITests
//
//  Created by LIUHAIFENG on 2026/3/3.
//

import XCTest

final class lumi_artframe_claudecodeV2UITests: XCTestCase {

    private var app: XCUIApplication!
    private static let screenshotDir = "/Users/liuhaifeng/Desktop/Lumi_artframe_claudecode_V2/.claude/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]

        try FileManager.default.createDirectory(
            atPath: Self.screenshotDir,
            withIntermediateDirectories: true
        )

        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Screenshot Helper

    private func takeScreenshot(name: String, file: StaticString = #file, line: UInt = #line) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.8))

        let screenshot = XCUIScreen.main.screenshot()

        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let filePath = "\(Self.screenshotDir)/\(name).png"
        do {
            try screenshot.pngRepresentation.write(to: URL(fileURLWithPath: filePath))
        } catch {
            XCTFail("Failed to save screenshot \(name): \(error)", file: file, line: line)
        }
    }

    // MARK: - Full Flow Screenshot Test

    @MainActor
    func testFullFlowScreenshots() throws {
        // ── 1. Splash View ──
        takeScreenshot(name: "SplashView-initial")

        // ── 2. Login View - empty ──
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5), "Login view should appear")
        takeScreenshot(name: "LoginView-empty")

        // ── 3. Login View - filled ──
        emailField.tap()
        emailField.typeText("test@example.com")
        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")
        takeScreenshot(name: "LoginView-filled")

        // ── 4. Login → MainTabView (Gallery) ──
        app.buttons["loginButton"].tap()
        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10), "MainTabView should appear")
        takeScreenshot(name: "MainTabView-gallery")

        // ── 5. Profile Tab ──
        let profileTab = app.buttons["profileTab"]
        if profileTab.waitForExistence(timeout: 3) {
            profileTab.tap()
            takeScreenshot(name: "MainTabView-profile")
            app.buttons["galleryTab"].tap()
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.5))
        }

        // ── 6. FAB → CameraView ──
        // In --uitesting mode, creation flow is shown as inline overlay (not fullScreenCover)
        // so XCUITest can query all elements directly.
        createButton.tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5), "CameraView should appear")
        takeScreenshot(name: "CameraView-withImage")

        // ── 7. Tap Confirm → DescriptionView ──
        let confirmButton = app.buttons["confirmImageButton"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 3), "Confirm button should appear")
        confirmButton.tap()

        // Wait for DescriptionView to fully appear
        let descView = app.otherElements["descriptionView"]
        XCTAssertTrue(descView.waitForExistence(timeout: 5), "DescriptionView should appear")

        let recordButton = app.buttons["recordButton"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 3), "Record button should exist")
        takeScreenshot(name: "DescriptionView-initial")

        // ── 8. Tap Skip → GenerationView ──
        let skipButton = app.buttons["skipRecordingButton"]
        XCTAssertTrue(skipButton.exists, "Skip button should exist")
        skipButton.tap()

        // Wait for GenerationView to appear and start processing
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.5))
        takeScreenshot(name: "GenerationView-loading")

        // ── 9. Wait for generation → DetailView ──
        // MockCreationService: upload(1.5s) + story(3s) + video(1s) = ~5.5s
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 8))
        takeScreenshot(name: "DetailView-result")
    }

    // MARK: - Auth Flow Tests

    @MainActor
    func testSplashNavigatesToLogin() throws {
        let splash = app.otherElements["splashView"]
        XCTAssertTrue(splash.waitForExistence(timeout: 3))

        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
    }

    @MainActor
    func testLoginFormInteraction() throws {
        let emailField = app.textFields["emailField"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))

        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password123")

        XCTAssertTrue(app.buttons["loginButton"].exists)
    }

    // MARK: - Creation Flow Navigation Tests

    @MainActor
    func testCreationFlowNavigation() throws {
        navigateToMainTab()

        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5), "CameraView should appear")
        XCTAssertTrue(closeButton.exists, "Close button should exist")
    }

    @MainActor
    func testCameraToDescriptionNavigation() throws {
        navigateToMainTab()

        app.buttons["createButton"].tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))

        let confirmButton = app.buttons["confirmImageButton"]
        if confirmButton.waitForExistence(timeout: 5) {
            confirmButton.tap()

            let recordButton = app.buttons["recordButton"]
            XCTAssertTrue(recordButton.waitForExistence(timeout: 5), "DescriptionView should appear")

            let skipButton = app.buttons["skipRecordingButton"]
            XCTAssertTrue(skipButton.exists, "Skip button should exist")
        }
    }

    @MainActor
    func testDescriptionToGenerationNavigation() throws {
        navigateToMainTab()

        app.buttons["createButton"].tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))

        let confirmButton = app.buttons["confirmImageButton"]
        if confirmButton.waitForExistence(timeout: 5) {
            confirmButton.tap()

            let skipButton = app.buttons["skipRecordingButton"]
            XCTAssertTrue(skipButton.waitForExistence(timeout: 5))
            skipButton.tap()

            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1.0))
            XCTAssertFalse(skipButton.exists, "Should have left DescriptionView")
        }
    }

    @MainActor
    func testCreationFlowDismissal() throws {
        navigateToMainTab()

        let createButton = app.buttons["createButton"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()

        let closeButton = app.buttons["cameraCloseButton"]
        XCTAssertTrue(closeButton.waitForExistence(timeout: 5))
        closeButton.tap()

        XCTAssertTrue(createButton.waitForExistence(timeout: 5),
                       "Should return to MainTabView")
    }

    // MARK: - Helpers

    private func navigateToMainTab() {
        let emailField = app.textFields["emailField"]
        guard emailField.waitForExistence(timeout: 5) else { return }

        emailField.tap()
        emailField.typeText("test@example.com")

        let passwordField = app.secureTextFields["passwordField"]
        passwordField.tap()
        passwordField.typeText("password123")

        app.buttons["loginButton"].tap()

        let createButton = app.buttons["createButton"]
        _ = createButton.waitForExistence(timeout: 10)
    }

    // MARK: - Performance

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
