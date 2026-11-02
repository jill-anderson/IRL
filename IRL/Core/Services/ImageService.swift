import Foundation
import UIKit
import Combine
import Amplify

/// Service responsible for uploading and managing images in S3
class ImageService: ObservableObject {

    // MARK: - Published Properties

    @Published var isUploading: Bool = false
    @Published var uploadProgress: Double = 0.0
    @Published var error: Error?

    // MARK: - Private Properties

    private let maxImageSize: CGFloat = 1024 // Max dimension in pixels
    private let jpegQuality: CGFloat = 0.8

    // MARK: - Singleton

    static let shared = ImageService()

    private init() {}

    // MARK: - Upload Operations

    /// Upload an image to S3
    /// - Parameters:
    ///   - image: UIImage to upload
    ///   - key: S3 object key (path)
    /// - Returns: Public URL of the uploaded image
    func uploadImage(_ image: UIImage, key: String) async throws -> String {
        isUploading = true
        uploadProgress = 0.0
        defer {
            isUploading = false
            uploadProgress = 0.0
        }

        // Compress and resize image
        guard let processedImage = processImage(image),
              let imageData = processedImage.jpegData(compressionQuality: jpegQuality) else {
            throw NSError(domain: "ImageService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Failed to process image"])
        }

        // Upload to S3 with Amplify Storage
        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: imageData,
            options: .init(
                accessLevel: .guest,
                contentType: "image/jpeg"
            )
        )

        // Track progress
        Task {
            for await progress in await uploadTask.progress {
                await MainActor.run {
                    self.uploadProgress = progress.fractionCompleted
                }
            }
        }

        // Wait for upload to complete
        let result = try await uploadTask.value
        print("✅ Image uploaded to S3: \(result.key)")

        // Get public URL
        let urlResult = try await Amplify.Storage.getURL(
            key: key,
            options: .init(accessLevel: .guest)
        )

        return urlResult.url.absoluteString
    }

    /// Upload profile photo for current user
    /// - Parameter image: UIImage to upload
    /// - Returns: CloudFront URL of the uploaded photo
    func uploadProfilePhoto(_ image: UIImage) async throws -> String {
        guard let userId = AuthenticationService.shared.getCurrentUserId() else {
            throw NSError(domain: "ImageService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])
        }

        // Generate unique key for profile photo
        let timestamp = Int(Date().timeIntervalSince1970)
        let key = "profile-photos/\(userId)/\(timestamp).jpg"

        return try await uploadImage(image, key: key)
    }

    /// Download an image from URL
    /// - Parameter url: URL of the image
    /// - Returns: UIImage
    func downloadImage(from url: String) async throws -> UIImage {
        // Check cache first
        if let cachedImage = getCachedImage(for: url) {
            return cachedImage
        }

        guard let imageURL = URL(string: url) else {
            throw NSError(domain: "ImageService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }

        // Download image data
        let (data, _) = try await URLSession.shared.data(from: imageURL)

        guard let image = UIImage(data: data) else {
            throw NSError(domain: "ImageService", code: -1,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
        }

        // Cache the image
        cacheImage(image, for: url)

        return image
    }

    /// Delete an image from S3
    /// - Parameter key: S3 object key to delete
    func deleteImage(key: String) async throws {
        // Delete from S3
        try await Amplify.Storage.remove(
            key: key,
            options: .init(accessLevel: .guest)
        )

        print("✅ Image deleted from S3: \(key)")
    }

    // MARK: - Image Processing

    /// Process image for upload (resize and compress)
    /// - Parameter image: Original UIImage
    /// - Returns: Processed UIImage
    private func processImage(_ image: UIImage) -> UIImage? {
        // Calculate new size maintaining aspect ratio
        let size = calculateNewSize(for: image.size)

        // Resize image
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: size))
        }

        return resizedImage
    }

    /// Calculate new size for image while maintaining aspect ratio
    /// - Parameter originalSize: Original image size
    /// - Returns: New size with max dimension of maxImageSize
    private func calculateNewSize(for originalSize: CGSize) -> CGSize {
        let maxDimension = maxImageSize

        if originalSize.width <= maxDimension && originalSize.height <= maxDimension {
            return originalSize
        }

        let aspectRatio = originalSize.width / originalSize.height

        if originalSize.width > originalSize.height {
            let newWidth = maxDimension
            let newHeight = newWidth / aspectRatio
            return CGSize(width: newWidth, height: newHeight)
        } else {
            let newHeight = maxDimension
            let newWidth = newHeight * aspectRatio
            return CGSize(width: newWidth, height: newHeight)
        }
    }

    // MARK: - Cache Management

    private var imageCache = NSCache<NSString, UIImage>()

    /// Get image from cache
    /// - Parameter key: Cache key (usually URL)
    /// - Returns: Cached UIImage if exists
    func getCachedImage(for key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }

    /// Cache an image
    /// - Parameters:
    ///   - image: UIImage to cache
    ///   - key: Cache key
    func cacheImage(_ image: UIImage, for key: String) {
        imageCache.setObject(image, forKey: key as NSString)
    }

    /// Clear image cache
    func clearCache() {
        imageCache.removeAllObjects()
    }
}
