//
//  DataCache.h
//  uLink
//
//  Created by Bennie Kingwood on 12/8/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "UListCache.h"
#import "Listing.h"
#import "AppMacros.h"

#define UDataCache ((DataCache *)[DataCache instance])
@interface DataCache : NSObject {
    NSMutableDictionary *schools;
    NSMutableArray *schoolSections;
    NSMutableDictionary *_uListCategories;
    NSMutableArray *_uListCategorySections;
    NSMutableArray *_uListListings;
    User *sessionUser;
    User *topSnapper;
    NSMutableDictionary *images;
    NSMutableDictionary *_uListCache;
}
@property (strong, nonatomic) NSMutableDictionary *schools;
@property (strong, nonatomic) NSMutableArray *schoolSections;
@property (strong, nonatomic) NSMutableArray *featuredEvents;
@property (strong, nonatomic) NSMutableArray *events;
@property (strong, nonatomic) NSMutableDictionary *snapshots;
@property (strong, nonatomic) NSMutableDictionary *snapshotCategories;
@property (strong, nonatomic) NSMutableArray *trends;
@property (strong, nonatomic) NSMutableArray *tweets;
@property (strong, nonatomic) User *sessionUser;
@property (strong, nonatomic) User *topSnapper;
@property (strong, nonatomic) NSArray *times;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (strong, nonatomic) NSMutableDictionary *eventImageThumbs;
@property (strong, nonatomic) NSMutableDictionary *snapImageThumbs;
@property (strong, nonatomic) NSMutableDictionary *userImageThumbs;
@property (strong, nonatomic) NSMutableDictionary *eventImageMedium;
@property (strong, nonatomic) NSMutableDictionary *snapImageMedium;
@property (strong, nonatomic) NSMutableDictionary *userImageMedium;
@property (strong, nonatomic) NSMutableDictionary *tweetUserImages;
@property (strong, nonatomic) NSMutableDictionary *listingImageThumbs;
@property (strong, nonatomic) NSMutableDictionary *listingImageMedium;
@property (strong, nonatomic) NSMutableDictionary *uListCategories;
@property (strong, nonatomic) NSMutableArray *uListCategorySections;
@property (strong, nonatomic) NSMutableArray *uListListings;
@property (strong, nonatomic) UListCache *uListCache;
+ (DataCache*) instance;
- (UIImage*) imageExists:(NSString*)cacheKey cacheModel:(NSString*)cacheModel;
- (void) removeImage:(NSString*)cacheKey cacheModel:(NSString*)cacheModel;
- (void) removeListingImage:(NSString*)cacheKey schoolId:(NSInteger*)schoolId cacheModel:(NSString*)cacheModel;
- (void) clearCache;
- (void) rehydrateCaches:(BOOL)checkAge;
- (void) hydrateCaches;
- (void) hydrateSchoolCache;
- (void) hydrateEventsCache;
- (void) hydrateSnapshotsCache;
- (void) hydrateSnapshotCategoriesCache:(BOOL)implicitHydrateSnapshots;
- (void) hydrateTweetsCache;
- (void) hydrateTrendsCache;
- (void) hydrateImageCache;
- (void) hydrateUListCategoryCache;
- (void) hydrateUListListingsCache:(NSString*)query notification:(NSString*)notification;
- (void) hydrateSessionUserListings:(NSString*)notification;
- (void) rehydrateSessionUser;
- (void) rehydrateSchoolCache:(BOOL)checkAge;
- (void) rehydrateEventsCache:(BOOL)checkAge;
- (void) rehydrateSnapshotsCache:(BOOL)checkAge;
- (void) rehydrateSnapshotCategoriesCache:(BOOL)checkAge;
- (void) rehydrateTweetsCache:(BOOL)checkAge;
- (void) rehydrateTrendsCache:(BOOL)checkAge;
- (void) rehydrateImageCache:(BOOL)checkAge;
- (void) rehydrateUListCategoriesCache:(BOOL)checkAge;
- (void) rehydrateSessionUserListings:(BOOL)checkAge notification:(NSString*)notification;
- (void) rehydrateUListListingsCache:(BOOL)checkAge;
- (void) incrementActiveProcesses:(int)processCount;
- (void) decrementActiveProcesses;
- (BOOL) userIsLoggedIn;
- (void) storeUserLoginInfo;
- (void) removeLoginInfo;
- (void) clearAllModelImageCaches;
- (void) updateListingCaches:(Listing*)listing type:(ListingSaveType)type;
@end
