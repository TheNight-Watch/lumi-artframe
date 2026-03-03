import XCTest
@testable import lumi_artframe_claudecodeV2

final class AuthServiceTests: XCTestCase {
    var authService: MockAuthService!

    override func setUp() {
        authService = MockAuthService()
    }

    func testLoginSuccess() async throws {
        let user = try await authService.login(email: "test@example.com", password: "password123")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertFalse(user.id.isEmpty)
    }

    func testLoginFailsWithShortPassword() async {
        do {
            _ = try await authService.login(email: "test@example.com", password: "123")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func testSignupSuccess() async throws {
        try await authService.signup(email: "new@example.com", password: "password123")
        // No error means success
    }

    func testSignupFailsWithInvalidEmail() async {
        do {
            try await authService.signup(email: "invalid", password: "password123")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func testSignupFailsWithWeakPassword() async {
        do {
            try await authService.signup(email: "test@example.com", password: "12345")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is AuthError)
        }
    }

    func testLogout() async throws {
        _ = try await authService.login(email: "test@example.com", password: "password123")
        let isAuthBefore = await authService.isAuthenticated()
        XCTAssertTrue(isAuthBefore)

        try await authService.logout()
        let isAuthAfter = await authService.isAuthenticated()
        XCTAssertFalse(isAuthAfter)
    }

    func testIsAuthenticatedWhenNotLoggedIn() async {
        let isAuth = await authService.isAuthenticated()
        XCTAssertFalse(isAuth)
    }

    func testPreAuthenticated() async {
        let preAuth = MockAuthService(preAuthenticated: true)
        let isAuth = await preAuth.isAuthenticated()
        XCTAssertTrue(isAuth)
        let user = await preAuth.currentUser()
        XCTAssertNotNil(user)
    }
}

final class GalleryServiceTests: XCTestCase {
    var galleryService: MockGalleryService!

    override func setUp() {
        galleryService = MockGalleryService()
    }

    func testFetchGalleryReturnsArtworks() async throws {
        let artworks = try await galleryService.fetchGallery()
        XCTAssertFalse(artworks.isEmpty)
        XCTAssertEqual(artworks.count, 3)
    }

    func testGetArtworkById() async throws {
        let artwork = try await galleryService.getArtwork(id: "mock-001")
        XCTAssertEqual(artwork.id, "mock-001")
        XCTAssertEqual(artwork.title, "Rainbow Dragon")
    }

    func testGetArtworkNotFound() async {
        do {
            _ = try await galleryService.getArtwork(id: "nonexistent")
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is GalleryError)
        }
    }
}

final class CreationServiceTests: XCTestCase {
    var creationService: MockCreationService!

    override func setUp() {
        creationService = MockCreationService()
    }

    func testUploadImage() async throws {
        let result = try await creationService.uploadImage(imageData: Data())
        XCTAssertFalse(result.id.isEmpty)
        XCTAssertFalse(result.imageURL.isEmpty)
    }

    func testGenerateStory() async throws {
        let result = try await creationService.generateStory(imageURL: "https://example.com/img.jpg", audioTranscript: nil)
        XCTAssertFalse(result.storyTitle.isEmpty)
        XCTAssertFalse(result.storyContent.isEmpty)
        XCTAssertFalse(result.videoPrompt.isEmpty)
        XCTAssertFalse(result.creativityAnalysis.isEmpty)
        XCTAssertFalse(result.moodAnalysis.isEmpty)
    }

    func testGenerateVideo() async throws {
        let result = try await creationService.generateVideo(imageURL: "https://example.com/img.jpg", prompt: "test prompt")
        XCTAssertFalse(result.taskID.isEmpty)
        XCTAssertEqual(result.status, "processing")
    }

    func testCheckVideoStatus() async throws {
        let status = try await creationService.checkVideoStatus(taskID: "task-001")
        XCTAssertEqual(status, .completed)
    }
}

final class ArtworkModelTests: XCTestCase {
    func testArtworkDecoding() throws {
        let json = """
        {
            "id": "test-001",
            "image_url": "https://example.com/img.jpg",
            "video_status": "completed",
            "created_at": "2026-03-01T10:30:00Z"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let artwork = try decoder.decode(Artwork.self, from: json)
        XCTAssertEqual(artwork.id, "test-001")
        XCTAssertEqual(artwork.imageURL, "https://example.com/img.jpg")
        XCTAssertEqual(artwork.videoStatus, .completed)
    }

    func testArtworkEncoding() throws {
        let artwork = Artwork(
            id: "test-001",
            title: "Test",
            imageURL: "https://example.com/img.jpg",
            videoURL: nil,
            videoTaskID: nil,
            videoStatus: .pending,
            storyTitle: nil,
            storyContent: nil,
            videoPrompt: nil,
            creativityAnalysis: nil,
            moodAnalysis: nil,
            additionalInsights: nil,
            createdAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(artwork)
        XCTAssertNotNil(data)
    }

    func testVideoStatusValues() {
        XCTAssertEqual(Artwork.VideoStatus.pending.rawValue, "pending")
        XCTAssertEqual(Artwork.VideoStatus.processing.rawValue, "processing")
        XCTAssertEqual(Artwork.VideoStatus.completed.rawValue, "completed")
        XCTAssertEqual(Artwork.VideoStatus.failed.rawValue, "failed")
    }
}
