#import "WMFArticle+CoreDataClass.h"

@class MWKSearchResult;
@class WMFFeedArticlePreview;

typedef NS_ENUM(NSUInteger, WMFGeoType) {
    WMFGeoTypeUnknown = 0,
    WMFGeoTypeCountry,
    WMFGeoTypeSatellite,
    WMFGeoTypeAdm1st,
    WMFGeoTypeAdm2nd,
    WMFGeoTypeAdm3rd,
    WMFGeoTypeCity,
    WMFGeoTypeAirport,
    WMFGeoTypeMountain,
    WMFGeoTypeIsle,
    WMFGeoTypeWaterBody,
    WMFGeoTypeForest,
    WMFGeoTypeRiver,
    WMFGeoTypeGlacier,
    WMFGeoTypeEvent,
    WMFGeoTypeEdu,
    WMFGeoTypePass,
    WMFGeoTypeRailwayStation,
    WMFGeoTypeLandmark
};

typedef NS_ENUM(NSUInteger, WMFArticleAction) {
    WMFArticleActionNone = 0,
    WMFArticleActionRead,
    WMFArticleActionSave,
    WMFArticleActionShare,
};

NS_ASSUME_NONNULL_BEGIN

@interface WMFArticle (WMFExtensions)

@property (nonatomic, readonly, nullable) NSURL *URL;

@property (nonatomic, copy, nonnull) NSString *displayTitleHTML;

@property (nonatomic, readonly, nullable) NSString *capitalizedWikidataDescription;

@property (nonatomic, nullable) NSURL *thumbnailURL; // Deprecated. Use imageURLForWidth:

+ (nullable NSURL *)imageURLForTargetImageWidth:(NSInteger)width fromImageSource:(NSString *)imageSource withOriginalWidth:(NSInteger)originalWidth;
- (nullable NSURL *)imageURLForWidth:(NSInteger)width;

@property (nonatomic, readonly, nullable) NSArray<NSNumber *> *pageViewsSortedByDate;

@property (nonatomic, readonly) WMFGeoType geoType;

@property (nonatomic, readonly) int64_t geoDimension;

- (void)updateViewedDateWithoutTime; // call after setting viewedDate

- (void)updateWithSearchResult:(nullable MWKSearchResult *)searchResult;

@end

@interface NSManagedObjectContext (WMFArticle)

- (nullable WMFArticle *)fetchArticleWithURL:(nullable NSURL *)articleURL;

- (nullable WMFArticle *)fetchArticleWithKey:(nullable NSString *)key;

- (nullable NSArray<WMFArticle *> *)fetchArticlesWithKey:(nullable NSString *)key error:(NSError **)error;

- (nullable WMFArticle *)createArticleWithKey:(nullable NSString *)key;

- (nullable WMFArticle *)fetchOrCreateArticleWithKey:(nullable NSString *)key;

- (nullable WMFArticle *)fetchOrCreateArticleWithURL:(nullable NSURL *)articleURL;

- (nullable WMFArticle *)fetchOrCreateArticleWithURL:(nullable NSURL *)articleURL updatedWithSearchResult:(nullable MWKSearchResult *)searchResult;

- (nullable WMFArticle *)fetchOrCreateArticleWithURL:(nullable NSURL *)articleURL updatedWithFeedPreview:(nullable WMFFeedArticlePreview *)feedPreview pageViews:(nullable NSDictionary<NSDate *, NSNumber *> *)pageViews;

- (nullable WMFArticle *)fetchArticleWithWikidataID:(nullable NSString *)wikidataID;

@end

NS_ASSUME_NONNULL_END
