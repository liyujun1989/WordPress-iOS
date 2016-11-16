import UIKit
import WordPressShared

class ReaderPostGalleryStripCell: UICollectionViewCell
{
    @IBOutlet private weak var galleryImageView: UIImageView!

    func setGalleryImage(galleryImageURL: NSURL, isPrivate: Bool) {

        let size = CGSize(width:self.galleryImageView.frame.width, height:self.galleryImageView.frame.height)

        if (!isPrivate) {
            let url = PhotonImageURLHelper.photonURLWithSize(size, forImageURL: galleryImageURL)
            galleryImageView.setImageWithURL(url, placeholderImage:nil)
        } else if (galleryImageURL.host != nil) && galleryImageURL.host!.hasSuffix("wordpress.com") {
            // private wpcom image needs special handling.
            let url = WPImageURLHelper.imageURLWithSize(size, forImageURL: galleryImageURL)
            let request = requestForURL(url)
            galleryImageView.setImageWithURLRequest(request, placeholderImage: WPStyleGuide.galleryPlaceholderImage(), success: nil, failure: nil)
        } else {
            // private but not a wpcom hosted image
            galleryImageView.setImageWithURL(galleryImageURL, placeholderImage:nil)
        }

        galleryImageView.setImageWithURL(galleryImageURL, placeholderImage: nil)
    }

    private func requestForURL(url:NSURL) -> NSURLRequest {
        var requestURL = url

        let absoluteString = requestURL.absoluteString
        if !(absoluteString!.hasPrefix("https")) {
            let sslURL = absoluteString!.stringByReplacingOccurrencesOfString("http", withString: "https")
            requestURL = NSURL(string: sslURL)!
        }

        let request = NSMutableURLRequest(URL: requestURL)

        let acctServ = AccountService(managedObjectContext: ContextManager.sharedInstance().mainContext)
        if let account = acctServ.defaultWordPressComAccount() {
            let token = account.authToken
            let headerValue = String(format: "Bearer %@", token)
            request.addValue(headerValue, forHTTPHeaderField: "Authorization")
        }

        return request
    }
}
