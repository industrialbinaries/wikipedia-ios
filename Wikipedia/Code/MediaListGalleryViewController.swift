class MediaListGalleryViewController: WMFImageGalleryViewController {
    let imageController: ImageController = ImageController.shared
    let imageInfoFetcher = MWKImageInfoFetcher()
    let imageFetcher = ImageFetcher()
    let articleURL: URL
    required init(articleURL: URL, mediaList: MediaList, initialItem: MediaListItem?, theme: Theme, overlayViewTopBarHidden: Bool = false) {
        self.articleURL = articleURL
        let photos = mediaList.items.compactMap { MediaListItemNYTPhotoWrapper($0) }
        let initialPhoto: WMFPhoto?
        if let initialItem = initialItem {
            initialPhoto = photos.first { $0.mediaListItem.title == initialItem.title }
        } else {
            initialPhoto = photos.first
        }
        super.init(photos: photos, initialPhoto: initialPhoto, delegate: nil, theme: theme, overlayViewTopBarHidden:overlayViewTopBarHidden)
        fetchImageForPhoto(initialPhoto)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageInfos: [String: MWKImageInfo] = [:]
    func fetchImageInfoForTitle(_ title: String, completion: @escaping (Result<MWKImageInfo, Error>) -> Void) {
        assert(Thread.isMainThread, "Protect accesss to imageInfos")
        // If we have the cached version, return it
        if let info = imageInfos[title] {
            completion(.success(info))
            return
        }
        // Otherwise fetch it and cache it
        imageInfoFetcher.fetchGalleryInfo(forImageFiles: [title], fromSiteURL: articleURL, success: { (info) in
            DispatchQueue.main.async {
                guard let info = info.first as? MWKImageInfo else {
                    completion(.failure(RequestError.unexpectedResponse))
                    return
                }
                self.imageInfos[title] = info
                completion(.success(info))
            }
        }) { (error) in
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
    
    func fetchImageForPhoto(_ photo: NYTPhoto?) {
        guard
            let photo = photo as? MediaListItemNYTPhotoWrapper,
            let title = photo.mediaListItem.title
        else {
            return
        }
        
        fetchImageInfoForTitle(title) { (result) in
            switch result {
            case .failure(let error):
                self.wmf_showAlertWithError(error as NSError)
            case .success(let imageInfo):
                self.fetchImageForPhoto(photo, imageInfo: imageInfo)
            }
        }
    }
    
    func fetchImageForPhoto(_ photo: MediaListItemNYTPhotoWrapper, imageInfo: MWKImageInfo) {
        if (photo.imageInfo == nil) {
            // Set the image info on the photo object
            // And update the overlay info so the caption is shown
            photo.imageInfo = imageInfo
            updateOverlayInformation()
        }
        // Gallery image width is based on the trait collection
        let width = traitCollection.wmf_galleryImageWidth
        guard let imageURL = imageInfo.imageURL(forTargetWidth: width) else {
            self.wmf_showAlertWithError(RequestError.unexpectedResponse as NSError)
            return
        }
        
        let urlRequest = imageFetcher.request(for: imageURL, forceCache: false)
        
        imageFetcher.data(for: urlRequest) { [weak self] (result) in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    photo.image = image
                    self?.updateImageForPhoto(afterUserInteractionIsFinished: photo)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.wmf_showAlertWithError(error as NSError)
                }
            }
        }
    }
    
    override func photosViewController(_ photosViewController: NYTPhotosViewController, didNavigateTo photo: NYTPhoto, at photoIndex: UInt) {
        fetchImageForPhoto(photo)
    }
}

// Model object for the NYTGalleryViewController
// Holds state for the gallery view
class MediaListItemNYTPhotoWrapper: NSObject, WMFPhoto {
    func bestImageURL() -> URL? {
        return nil
    }
    
    func bestImageInfo() -> MWKImageInfo? {
        return imageInfo
    }
    
    var image: UIImage?
    var imageData: Data?
    var imageDataUTType: String?
    var placeholderImage: UIImage?
    var attributedCaptionTitle: NSAttributedString?
    var attributedCaptionSummary: NSAttributedString?
    var attributedCaptionCredit: NSAttributedString?
    
    let mediaListItem: MediaListItem
    var imageInfo: MWKImageInfo?
    
    init?(_ mediaListItem: MediaListItem?) {
        guard let mediaListItem = mediaListItem, mediaListItem.type == "image" else {
            return nil
        }
        self.mediaListItem = mediaListItem
    }
}
