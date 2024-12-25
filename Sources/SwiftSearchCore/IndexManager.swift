import Foundation
import SQLite

/// Manages file indexing and metadata storage for SwiftSearch
@available(macOS 10.15, *)
public final class IndexManager: @unchecked Sendable {
    private let db: Connection
    private let files = Table("files")
    private var watchedDirectory: String?
    
    // File table columns
    private let id = Expression<Int64>(value: "id")
    private let path = Expression<String>(value: "path")
    private let fileName = Expression<String>(value: "fileName")
    private let modificationDate = Expression<Double>(value: "modificationDate")
    private let creationDate = Expression<Double>(value: "creationDate")
    private let fileSize = Expression<Int64>(value: "fileSize")
    
    /// Initialize IndexManager with a database path
    /// - Parameter dbPath: Path to SQLite database file
    public init(dbPath: String) throws {
        self.db = try Connection(dbPath)
        try setupDatabase()
    }
    
    /// Set up database schema
    private func setupDatabase() throws {
        let createTable = """
            CREATE TABLE IF NOT EXISTS files (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                path TEXT UNIQUE NOT NULL,
                fileName TEXT NOT NULL,
                modificationDate REAL NOT NULL,
                creationDate REAL NOT NULL,
                fileSize INTEGER NOT NULL
            )
        """
        
        try db.run(createTable)
        
        // Create indices for faster lookups
        try db.run("CREATE UNIQUE INDEX IF NOT EXISTS idx_files_path ON files(path)")
        try db.run("CREATE INDEX IF NOT EXISTS idx_files_name ON files(fileName)")
    }
    
    /// Index a single file
    /// - Parameter filePath: Path to the file to index
    /// - Throws: File operation or database errors
    public func indexFile(_ filePath: String) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            try? removeFromIndex(filePath)
            return
        }
        
        let url = URL(fileURLWithPath: filePath)
        var isDirectory: ObjCBool = false
        
        guard fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory),
              !isDirectory.boolValue else {
            return
        }
        
        let resourceValues = try url.resourceValues(forKeys: [
            .nameKey,
            .contentModificationDateKey,
            .creationDateKey,
            .fileSizeKey
        ])
        
        guard let name = resourceValues.name,
              let modDate = resourceValues.contentModificationDate,
              let createDate = resourceValues.creationDate,
              let size = resourceValues.fileSize else {
            return
        }
        
        let stmt = """
            INSERT OR REPLACE INTO files
            (path, fileName, modificationDate, creationDate, fileSize)
            VALUES (?, ?, ?, ?, ?)
        """
        
        try db.run(stmt, [
            filePath,
            name,
            modDate.timeIntervalSince1970,
            createDate.timeIntervalSince1970,
            Int64(size)
        ])
    }
    
    /// Index a directory and its contents
    /// - Parameter directoryPath: Path to directory to index
    /// - Throws: File operation or database errors
    public func indexDirectory(_ directoryPath: String) throws {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: directoryPath) else {
            throw IndexError.directoryAccessDenied
        }
        
        watchedDirectory = directoryPath
        
        // Get current files in the directory
        let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: [
                .pathKey,
                .nameKey,
                .contentModificationDateKey,
                .creationDateKey,
                .fileSizeKey
            ],
            options: [.skipsHiddenFiles]
        )
        
        guard let enumerator = enumerator else {
            throw IndexError.directoryAccessDenied
        }
        
        // Get current files in the directory
        var currentFiles = Set<String>()
        
        try db.transaction {
            for case let fileURL as URL in enumerator {
                let filePath = fileURL.path
                currentFiles.insert(filePath)
                try indexFile(filePath)
            }
            
            // Remove files that no longer exist
            let indexedFiles = try getIndexedFiles()
            for file in indexedFiles {
                if !currentFiles.contains(file.path) {
                    try removeFromIndex(file.path)
                }
            }
        }
    }
    
    /// Stop watching and clean up resources
    public func stopWatchingAll() {
        watchedDirectory = nil
    }
    
    /// Get all indexed files
    /// - Returns: Array of file metadata
    public func getIndexedFiles() throws -> [(path: String, name: String, modified: Date, created: Date, size: Int64)] {
        var results: [(path: String, name: String, modified: Date, created: Date, size: Int64)] = []
        
        let stmt = """
            SELECT path, fileName, modificationDate, creationDate, fileSize
            FROM files
            ORDER BY path
        """
        
        for row in try db.prepare(stmt) {
            guard let path = row[0] as? String,
                  let name = row[1] as? String,
                  let modTimestamp = row[2] as? Double,
                  let createTimestamp = row[3] as? Double,
                  let size = row[4] as? Int64 else {
                continue
            }
            
            results.append((
                path: path,
                name: name,
                modified: Date(timeIntervalSince1970: modTimestamp),
                created: Date(timeIntervalSince1970: createTimestamp),
                size: size
            ))
        }
        
        return results
    }
    
    /// Remove file from index
    /// - Parameter filePath: Path of file to remove
    public func removeFromIndex(_ filePath: String) throws {
        try db.run("DELETE FROM files WHERE path = ?", [filePath])
    }
    
    deinit {
        stopWatchingAll()
    }
}

/// Errors that can occur during indexing
public enum IndexError: Error {
    case directoryAccessDenied
}