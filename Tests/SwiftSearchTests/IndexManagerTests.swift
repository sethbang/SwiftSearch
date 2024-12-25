import XCTest
import Foundation
@testable import SwiftSearchCore

final class IndexManagerTests: XCTestCase {
    var tempDir: URL!
    var dbPath: String!
    var indexManager: IndexManager!
    
    override func setUp() async throws {
        // Create temporary directory for test files
        tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Standardize the temp directory path
        tempDir = URL(fileURLWithPath: tempDir.path).standardizedFileURL
        
        // Create temporary database
        dbPath = FileManager.default.temporaryDirectory.appendingPathComponent("test.db").path
        indexManager = try IndexManager(dbPath: dbPath)
        
        // Create test files
        let testFile1 = tempDir.appendingPathComponent("test1.txt")
        let testFile2 = tempDir.appendingPathComponent("test2.txt")
        
        try "Test content 1".write(to: testFile1, atomically: true, encoding: .utf8)
        try "Test content 2".write(to: testFile2, atomically: true, encoding: .utf8)
    }
    
    override func tearDown() async throws {
        // Stop watching
        indexManager.stopWatchingAll()
        
        // Clean up test files and directory
        try? FileManager.default.removeItem(at: tempDir)
        
        // Clean up database
        if FileManager.default.fileExists(atPath: dbPath) {
            try? FileManager.default.removeItem(atPath: dbPath)
        }
    }
    
    func testDirectoryIndexing() async throws {
        // Index the temporary directory
        try indexManager.indexDirectory(tempDir.path)
        
        // Get indexed files
        let indexedFiles = try indexManager.getIndexedFiles()
        
        // Verify that we have exactly 2 files indexed
        XCTAssertEqual(indexedFiles.count, 2)
        
        // Verify file names
        let fileNames = Set(indexedFiles.map { $0.name })
        XCTAssertTrue(fileNames.contains("test1.txt"))
        XCTAssertTrue(fileNames.contains("test2.txt"))
        
        // Get standardized temp directory path
        let standardizedTempPath = URL(fileURLWithPath: tempDir.path).standardizedFileURL.path
        
        // Verify file metadata
        for file in indexedFiles {
            // Get standardized file path
            let standardizedFilePath = URL(fileURLWithPath: file.path).standardizedFileURL.path
            
            // Verify path starts with temp directory
            XCTAssertTrue(
                standardizedFilePath.starts(with: standardizedTempPath),
                "File path '\(standardizedFilePath)' should start with temp directory '\(standardizedTempPath)'"
            )
            
            // Verify timestamps and size
            XCTAssertNotNil(file.modified)
            XCTAssertNotNil(file.created)
            XCTAssertGreaterThan(file.size, 0)
        }
    }
    
    func testRemoveFromIndex() async throws {
        // First index the directory
        try indexManager.indexDirectory(tempDir.path)
        
        // Get the first file's path
        let files = try indexManager.getIndexedFiles()
        XCTAssertFalse(files.isEmpty)
        
        let firstFilePath = files[0].path
        
        // Remove the file from index
        try indexManager.removeFromIndex(firstFilePath)
        
        // Verify file was removed
        let remainingFiles = try indexManager.getIndexedFiles()
        XCTAssertEqual(remainingFiles.count, files.count - 1)
        XCTAssertFalse(remainingFiles.contains(where: { $0.path == firstFilePath }))
    }
    
    func testFileWatching() async throws {
        // Create a new file
        let newFile = tempDir.appendingPathComponent("watched.txt")
        let initialContent = "Initial content"
        try initialContent.write(to: newFile, atomically: true, encoding: .utf8)
        
        // Index the new file
        try indexManager.indexFile(newFile.path)
        
        // Verify the new file was indexed
        var files = try indexManager.getIndexedFiles()
        let initialFile = files.first(where: { $0.path == newFile.path })
        XCTAssertNotNil(initialFile, "New file should be indexed")
        XCTAssertEqual(initialFile?.size, Int64(initialContent.utf8.count))
        
        // Modify the file
        let modifiedContent = "Modified content with more text"
        try modifiedContent.write(to: newFile, atomically: true, encoding: .utf8)
        
        // Re-index the modified file
        try indexManager.indexFile(newFile.path)
        
        // Verify the file was updated
        files = try indexManager.getIndexedFiles()
        let modifiedFile = files.first(where: { $0.path == newFile.path })
        XCTAssertNotNil(modifiedFile, "Modified file should still be indexed")
        XCTAssertEqual(modifiedFile?.size, Int64(modifiedContent.utf8.count))
        
        // Delete the file
        try FileManager.default.removeItem(at: newFile)
        
        // Try to index the deleted file (should remove it from index)
        try indexManager.indexFile(newFile.path)
        
        // Verify the file was removed from index
        files = try indexManager.getIndexedFiles()
        XCTAssertFalse(files.contains(where: { $0.path == newFile.path }))
    }
}