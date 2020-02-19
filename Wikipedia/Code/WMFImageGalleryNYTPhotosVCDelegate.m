#import <Foundation/Foundation.h>
#import "WMFImageGalleryNYTPhotosVCDelegate.h"
#import "WMFImageGalleryViewController.h"
#import "WMFImageGalleryDetailOverlayView.h"
#import "Wikipedia-Swift.h"

@import NYTPhotoViewer;
@import WMF;

@implementation WMFImageGalleryNYTPhotosVCDelegate

- (UIView *_Nullable)photosViewController:(NYTPhotosViewController *)photosViewController referenceViewForPhoto:(id<NYTPhoto>)photo {
    return nil; //TODO: remove this and re-enable animations when tickets for fixing anmimations are addressed
    WMFImageGalleryViewController* parentController = (WMFImageGalleryViewController*)photosViewController;
    return [parentController.referenceViewDelegate referenceViewForImageController:parentController];
}

- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id<NYTPhoto>)photo {
    return 2.0;
}

- (NSString *_Nullable)photosViewController:(NYTPhotosViewController *)photosViewController titleForPhoto:(id<NYTPhoto>)photo atIndex:(NSUInteger)photoIndex totalPhotoCount:(NSUInteger)totalPhotoCount {
    return @"";
}

- (UIView *_Nullable)photosViewController:(NYTPhotosViewController *)photosViewController captionViewForPhoto:(id<NYTPhoto>)photo {
    MWKImageInfo *imageInfo = [(id<WMFPhoto>)photo bestImageInfo];
    WMFImageGalleryViewController* parentController = (WMFImageGalleryViewController*)photosViewController;

    if (!imageInfo || !parentController) {
        return nil;
    }
    WMFImageGalleryDetailOverlayView *caption = [WMFImageGalleryDetailOverlayView wmf_viewFromClassNib];
    caption.imageDescriptionIsRTL = imageInfo.imageDescriptionIsRTL;

    caption.imageDescription =
        [imageInfo.imageDescription stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *ownerOrFallback = imageInfo.owner ? [imageInfo.owner stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                : WMFLocalizedStringWithDefaultValue(@"image-gallery-unknown-owner", nil, nil, @"Author unknown.", @"Fallback text for when an item in the image gallery doesn't have a specified owner.");
    
    [caption setLicense:imageInfo.license owner:ownerOrFallback];
    caption.ownerTapCallback = ^{
        if (imageInfo.license.URL) {
            [parentController wmf_navigateToURL:imageInfo.license.URL.wmf_urlByPrependingSchemeIfSchemeless];
        } else if (imageInfo.filePageURL) {
            [parentController wmf_navigateToURL:imageInfo.filePageURL.wmf_urlByPrependingSchemeIfSchemeless];
        } else {
            // There should always be a file page URL, but log an error anyway
            DDLogError(@"No license URL or file page URL for %@", imageInfo);
        }
    };
    caption.infoTapCallback = ^{
        if (imageInfo.filePageURL) {
            [parentController wmf_navigateToURL:imageInfo.filePageURL.wmf_urlByPrependingSchemeIfSchemeless];
        }
    };
    @weakify(caption);
    caption.descriptionTapCallback = ^{
        [UIView animateWithDuration:0.3
                         animations:^{
                             @strongify(caption);
                             [caption toggleDescriptionOpenState];
                             [parentController.view layoutIfNeeded];
                         }
                         completion:NULL];
    };

    caption.maximumDescriptionHeight = parentController.view.frame.size.height;

    return caption;
}

@end
