
import Foundation

enum ArticleCacheFileWriterError: Error {
    case failureToGenerateURLFromItemKey
    case missingTemporaryFileURL
    case unableToDetermineSiteURLFromMigration
    case failureToSaveAllMigratedFiles
}

final public class ArticleCacheFileWriter: NSObject, CacheFileWriting {
    
    weak var delegate: CacheFileWritingDelegate?
    private let articleFetcher: ArticleFetcher
    private let cacheBackgroundContext: NSManagedObjectContext
    
    lazy private var baseCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("baseCSS.css", isDirectory: false)
    }()
    
    lazy private var pcsCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("pcsCSS.css", isDirectory: false)
    }()
    
    lazy private var pcsJSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("pcsJS.js", isDirectory: false)
    }()
    
    lazy private var siteCSSFileURL: URL = {
        URL(fileURLWithPath: WikipediaAppUtils.assetsPath())
            .appendingPathComponent("pcs-html-converter", isDirectory: true)
            .appendingPathComponent("siteCSS.css", isDirectory: false)
    }()
    
    var groupedTasks: [String : [IdentifiedTask]] = [:]
    
    init?(articleFetcher: ArticleFetcher,
                       cacheBackgroundContext: NSManagedObjectContext, delegate: CacheFileWritingDelegate? = nil) {
        self.articleFetcher = articleFetcher
        self.delegate = delegate
        self.cacheBackgroundContext = cacheBackgroundContext
        
        do {
            try FileManager.default.createDirectory(at: CacheController.cacheURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            assertionFailure("Failure to create article cache directory")
            return nil
        }
    }
    
    func add(groupKey: String, itemKey: String, completion: @escaping (CacheFileWritingResult) -> Void) {
        
        guard let url = URL(string: itemKey) else {
            completion(.failure(ArticleCacheFileWriterError.failureToGenerateURLFromItemKey))
            return
        }
        
        let urlToDownload = ArticleURLConverter.mobileHTMLURL(desktopURL: url, endpointType: .mobileHTML, scheme: Configuration.Scheme.https) ?? url
        
        let untrackKey = UUID().uuidString
        let task = articleFetcher.downloadData(url: urlToDownload) { (error, _, response, temporaryFileURL, mimeType) in
            
            defer {
                self.untrackTask(untrackKey: untrackKey, from: groupKey)
            }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let temporaryFileURL = temporaryFileURL else {
                completion(.failure(ArticleCacheFileWriterError.missingTemporaryFileURL))
                return
            }
            
            let etag = (response as? HTTPURLResponse)?.allHeaderFields[HTTPURLResponse.etagHeaderKey] as? String
            CacheFileWriterHelper.moveFile(from: temporaryFileURL, toNewFileWithKey: itemKey, mimeType: mimeType) { (result) in
                switch result {
                case .success, .exists:
                    completion(.success(etag: etag)) //tonitodo: when do we overwrite for .exists?
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        if let task = task {
            trackTask(untrackKey: untrackKey, task: task, to: groupKey)
        }
    }
}

//Migration

extension ArticleCacheFileWriter {
    
    func migrateCachedContent(desktopArticleURL: URL, content: String, itemKeys: [CacheController.ItemKey], mimeType: String, success: @escaping ([CacheController.ItemKey]) -> Void, failure: @escaping (Error) -> Void) {
        
        guard let siteURL = desktopArticleURL.wmf_site else {
            failure(ArticleCacheFileWriterError.unableToDetermineSiteURLFromMigration)
            return
        }
        
        let bundledItemKeys = articleFetcher.bundledOfflineResourceURLs(with: siteURL)
        
        var failedItemKeys: [CacheController.ItemKey] = []
        var succeededItemKeys: [CacheController.ItemKey] = []
        
        for itemKey in itemKeys {
            
            if let bundledItemKeys = bundledItemKeys {
                if itemKey == bundledItemKeys.baseCSS.absoluteString {
                    CacheFileWriterHelper.copyFile(from: baseCSSFileURL, toNewFileWithKey: itemKey, mimeType: "text/css") { (result) in
                        switch result {
                        case .success, .exists:
                            succeededItemKeys.append(itemKey)
                        case .failure:
                            failedItemKeys.append(itemKey)
                        }
                    }
                    return
                }
                
                if itemKey == bundledItemKeys.siteCSS.absoluteString {
                    CacheFileWriterHelper.copyFile(from: siteCSSFileURL, toNewFileWithKey: itemKey, mimeType: "text/css") { (result) in
                        switch result {
                        case .success, .exists:
                            succeededItemKeys.append(itemKey)
                        case .failure:
                            failedItemKeys.append(itemKey)
                        }
                    }
                    return
                }
                
                if itemKey == bundledItemKeys.pcsCSS.absoluteString {
                    CacheFileWriterHelper.copyFile(from: pcsCSSFileURL, toNewFileWithKey: itemKey, mimeType: "text/css") { (result) in
                        switch result {
                        case .success, .exists:
                            succeededItemKeys.append(itemKey)
                        case .failure:
                            failedItemKeys.append(itemKey)
                        }
                    }
                    return
                }
                
                if itemKey == bundledItemKeys.pcsJS.absoluteString {
                    CacheFileWriterHelper.copyFile(from: pcsJSFileURL, toNewFileWithKey: itemKey, mimeType: "application/javascript") { (result) in
                        switch result {
                        case .success, .exists:
                            succeededItemKeys.append(itemKey)
                        case .failure:
                            failedItemKeys.append(itemKey)
                        }
                    }
                    return
                }
            }
            
            //key will be desktop articleURL.wmf_databaseKey format
            CacheFileWriterHelper.saveContent(content, toNewFileWithKey: itemKey, mimeType: mimeType) { (result) in
                switch result {
                case .success, .exists:
                    succeededItemKeys.append(itemKey)
                case .failure:
                    failedItemKeys.append(itemKey)
                }
            }
        }

        if succeededItemKeys.count == 0 {
            failure(ArticleCacheFileWriterError.failureToSaveAllMigratedFiles)
            return
        }
        
        success(succeededItemKeys)
    }
}


