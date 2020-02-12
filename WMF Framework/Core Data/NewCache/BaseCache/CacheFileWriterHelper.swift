
import Foundation

final class CacheFileWriterHelper {
    static func fileURL(for key: String) -> URL {
        let pathComponent = key.sha256 ?? key
        return CacheController.cacheURL.appendingPathComponent(pathComponent, isDirectory: false)
    }
    
    static func moveFile(from fileURL: URL, toNewFileWithKey key: String, mimeType: String?, completion: @escaping (FileMoveResult) -> Void) {
        do {
            let newFileURL = self.fileURL(for: key)
            try FileManager.default.moveItem(at: fileURL, to: newFileURL)
            if let mimeType = mimeType {
                FileManager.default.setValue(mimeType, forExtendedFileAttributeNamed: WMFExtendedFileAttributeNameMIMEType, forFileAtPath: newFileURL.path)
            }
            completion(.success)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain, error.code == NSFileWriteFileExistsError {
                completion(.exists)
            } else {
                completion(.failure(error))
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    static func saveContent(_ content: String, toNewFileWithKey key: String, mimeType: String?, completion: @escaping (FileMoveResult) -> Void) {
        
        do {
            let newFileURL = self.fileURL(for: key)
            try content.write(to: newFileURL, atomically: true, encoding: .utf8)
            if let mimeType = mimeType {
                FileManager.default.setValue(mimeType, forExtendedFileAttributeNamed: WMFExtendedFileAttributeNameMIMEType, forFileAtPath: newFileURL.path)
            }
            completion(.success)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain, error.code == NSFileWriteFileExistsError {
                completion(.exists)
            } else {
                completion(.failure(error))
            }
        } catch let error {
            completion(.failure(error))
        }
    }
}

enum FileMoveResult {
    case exists
    case success
    case failure(Error)
}
