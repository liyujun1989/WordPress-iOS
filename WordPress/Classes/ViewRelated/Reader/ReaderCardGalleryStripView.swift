import Foundation
import WordPressShared
//import IDMPhotoBrowser

/// Stores gallery image details
internal struct GalleryImageInfo
{
    let imageURL: NSURL
    let isPrivate: Bool

    var description: String {
        return "Gallery Image - URL: \(imageURL) isPrivate: \(isPrivate)"
    }
}

@objc public class ReaderCardGalleryStripView: UIView
{
    @IBOutlet private weak var galleryImageCollectionView: UICollectionView!
    @IBOutlet private weak var numberOfImagesLabel: UILabel!
    @IBOutlet private weak var viewGalleryButton: UIButton!

    private var storedOffsets = [Int: CGFloat]()
    private let galleryCellIdentifier = "GalleryStripCell"
    private var galleryImages: [GalleryImageInfo] = []


    // MARK: - Lifecycle Methods

    public override func awakeFromNib() {
        super.awakeFromNib()

        let nibName = UINib(nibName: "ReaderCardGalleryStripCell", bundle:nil)
        galleryImageCollectionView.registerNib(nibName, forCellWithReuseIdentifier: galleryCellIdentifier)
    }


    // MARK: - Configuration

    public func configureView(contentProvider: ReaderPostContentProvider?) {

        guard let cp = contentProvider else {
            reset()
            return
        }

        configureGalleryImageStrip(cp)
        invalidateIntrinsicContentSize()
    }

    var collectionViewOffset: CGFloat {
        set {
            galleryImageCollectionView.contentOffset.x = newValue
        }

        get {
            return galleryImageCollectionView.contentOffset.x
        }
    }

    private func reset() {
        galleryImages.removeAll()
        galleryImageCollectionView.reloadData()
    }

    private func configureGalleryImageStrip(contentProvider: ReaderPostContentProvider) {
//        setCollectionViewDataSourceDelegate(self)
//        configureButtonForGalleryTitle()
//        numberOfImagesLabel.attributedText = attributedTextForGalleryCount(contentProvider.galleryImages().count)
//
//        for item in contentProvider.galleryImages() {
//
//            let galleryImageURL = NSURL(string: item as! String)
//            let galleryImage = GalleryImageInfo(imageURL: galleryImageURL!, isPrivate: contentProvider.isPrivate())
//            galleryImages.append(galleryImage)
//        }
//    }
//
//    private func attributedTextForGalleryCount(pictureCount:Int) -> NSAttributedString? {
//        let attrStr = NSMutableAttributedString()
//
//        let imagesStr = NSLocalizedString("images",
//                                         comment: "Part of a label letting the user know how many images are in a image gallery. For example: '6 images'")
//
//        let fullStr = String(format: "%d %@ ", pictureCount, imagesStr)
//        let attributes = WPStyleGuide.readerCardWordCountAttributes() as! [String: AnyObject]
//        let attrImageCount = NSAttributedString(string: fullStr, attributes: attributes)
//        attrStr.appendAttributedString(attrImageCount)
//
//        return attrStr
    }

    private func configureButtonForGalleryTitle() {
        let galleryTitleStr = NSLocalizedString("View Images",
                                          comment: "Label for a button that the user presses to view an image gallery.")

        viewGalleryButton.setTitle(galleryTitleStr, forState: .Normal)
        WPStyleGuide.applyReaderCardTagButtonStyle(viewGalleryButton)
    }

    private func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D) {
        galleryImageCollectionView.delegate = dataSourceDelegate
        galleryImageCollectionView.dataSource = dataSourceDelegate
        galleryImageCollectionView.setContentOffset(galleryImageCollectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        reset()
    }


    // MARK: - Instance Methods

    public func presentGalleryImages() {
        // Start on the first image by default
        presentLightBoxVC(0)
    }


    // MARK: - Helpers

    private func getCurrentViewController() -> UIViewController? {
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }

    private func presentLightBoxVC(startingGalleryImageIndex:Int) {
//        let photoURLs = NSMutableArray()
//
//        for galleryImage:GalleryImageInfo in galleryImages {
//            photoURLs.addObject(galleryImage.imageURL)
//        }
//
//        let urlArray: [NSURL] = photoURLs.flatMap({ $0 as? NSURL })
//        let browser = IDMPhotoBrowser(photos: IDMPhoto.photosWithURLs(urlArray))
//        browser.setInitialPageIndex(UInt(startingGalleryImageIndex))
//
//        let currentVC = self.getCurrentViewController()
//        currentVC?.presentViewController(browser, animated: true, completion: nil)
    }


    // MARK: -

}

//extension ReaderCardGalleryStripView: UICollectionViewDelegate, UICollectionViewDataSource
//{
//    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        // The following needs to be called here to prevent a NSInternalInconsistencyException in the collection view
//        // See: http://stackoverflow.com/questions/18339030/uicollectionview-assertion-error-on-stale-data
//        collectionView.collectionViewLayout.invalidateLayout()
//        return 1
//    }
//
//    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return galleryImages.count
//    }
//
//    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(galleryCellIdentifier, forIndexPath: indexPath) as! ReaderPostGalleryStripCell
//
//        let galleryImage: GalleryImageInfo = galleryImages[indexPath.row]
//        cell.setGalleryImage(galleryImage.imageURL, isPrivate: galleryImage.isPrivate)
//
//        return cell
//    }
//
//    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        presentLightBoxVC(indexPath.row)
//    }
//}
