//
//  DataCache.m
//  uLink
//
//  Created by Bennie Kingwood on 12/8/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "DataCache.h"
#import "School.h"
#import "TextUtil.h"
#import "SnapshotCategory.h"
#import "SnapshotUtil.h"
#import "EventUtil.h"
#import "Tweet.h"
#import "AppDelegate.h"
#import <SDWebImage/SDWebImageDownloader.h>
@interface DataCache() {
    TextUtil *textUtil;
    NSDateFormatter *tweetDateFormatter;
    int activeProcesses;
    BOOL indicatorVisible;
}
- (void) buildSchoolList:(id)schoolsRaw;
- (void) retrieveSnapshots:(NSString*)categoryId;
- (void) buildTrends:(id)trendsRaw;
- (void) buildTweets:(id)tweetsRaw;
- (void) buildTimes;
- (void) initImageCaches;
@end
@implementation DataCache
#pragma mark CACHE CONSTANTS
/*
 * The following are the cache age limits in seconds.  When 
 * rehydrating the caches will will only pull new 
 * data if the current cache data is older than the 
 * age limit.
 */
const double CACHE_AGE_LIMIT_SNAP_CATEGORIES = 604800;  // 7 days
const double CACHE_AGE_LIMIT_SNAPSHOTS = 1800;  // 30 minutes
const double CACHE_AGE_LIMIT_TWEETS = 900;  // 15 minutes
const double CACHE_AGE_LIMIT_EVENTS = 86400;  // 1 days
const double CACHE_AGE_LIMIT_SCHOOLS = 604800;  // 7 days
const double CACHE_AGE_LIMIT_IMAGES = 2419200; // 28 days

#pragma mark
@synthesize schools;
@synthesize schoolSections;
@synthesize sessionUser;
@synthesize topSnapper;
@synthesize events;
@synthesize featuredEvents;
@synthesize snapshots;
@synthesize snapshotCategories;
@synthesize tweets;
@synthesize trends;
@synthesize images;
@synthesize eventImageMedium, eventImageThumbs;
@synthesize snapImageMedium, snapImageThumbs;
@synthesize userImageThumbs, userImageMedium;
@synthesize tweetUserImages;
+ (DataCache*) instance {
    static DataCache* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) { 
            _one = [[ DataCache alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        textUtil = [TextUtil instance];
        tweetDateFormatter = [[NSDateFormatter alloc] init];
        [tweetDateFormatter setDateFormat:@"E, d MMMM yyyy HH:m:s Z"];
        [self buildTimes];
        activeProcesses = 0;
        [self initImageCaches];
    }
    return self;
}
- (void) clearCache {
    self.sessionUser = nil;
    self.topSnapper = nil;
    self.events = nil;
    self.snapshots = nil;
    self.tweets = nil;
    self.trends = nil;
    self.snapshotCategories = nil;
    [self clearAllModelImageCaches];
}

-(void) clearAllModelImageCaches {
    self.eventImageThumbs = nil;
    self.snapImageThumbs = nil;
    self.userImageThumbs = nil;
    self.eventImageMedium = nil;
    self.snapImageMedium = nil;
    self.userImageMedium = nil;
    self.tweetUserImages = nil;
}
- (void) initImageCaches {
    if(self.userImageThumbs == nil) {
        self.userImageThumbs = [[NSMutableDictionary alloc] init];
    } else {
        [self.userImageThumbs removeAllObjects];
    }
    if(self.userImageMedium == nil) {
        self.userImageMedium = [[NSMutableDictionary alloc] init];
    } else {
        [self.userImageMedium removeAllObjects];
    }
    if(self.snapImageThumbs == nil) {
        self.snapImageThumbs = [[NSMutableDictionary alloc] init];
    }
    if (self.eventImageThumbs == nil) {
        self.eventImageThumbs = [[NSMutableDictionary alloc] init];
    }
    if(self.snapImageMedium == nil) {
        self.snapImageMedium = [[NSMutableDictionary alloc] init];
    }
    if (self.eventImageMedium == nil) {
        self.eventImageMedium = [[NSMutableDictionary alloc] init];
    }
    if (self.tweetUserImages == nil) {
        self.tweetUserImages = [[NSMutableDictionary alloc] init];
    }
}
- (void) buildTimes {
    if (self.times == nil) {
        self.times = [[NSArray alloc] initWithObjects:@"",@"12:00 AM",@"12:15 AM",@"12:30 AM",@"12:45 AM",@"01:00 AM",@"01:15 AM",@"01:30 AM",@"01:45 AM",@"02:00 AM",@"02:15 AM",@"02:30 AM",@"02:45 AM",@"03:00 AM",@"03:15 AM",@"03:30 AM",@"03:45 AM",@"04:00 AM",@"04:15 AM",@"04:30 AM",@"04:45 AM",@"05:00 AM",@"05:15 AM",@"05:30 AM",@"05:45 AM",@"06:00 AM",@"06:15 AM",@"06:30 AM",@"06:45 AM",@"07:00 AM",@"07:15 AM",@"07:30 AM",@"07:45 AM",@"08:00 AM",@"08:15 AM",@"08:30 AM",@"08:45 AM",@"09:00 AM",@"09:15 AM",@"09:30 AM",@"09:45 AM",@"10:00 AM",@"10:15 AM",@"10:30 AM",@"10:45 AM",@"11:00 AM",@"11:15 AM",@"11:30 AM",@"11:45 AM",@"12:00 PM",@"12:15 PM",@"12:30 PM",@"12:45 PM",@"01:00 PM",@"01:15 PM",@"01:30 PM",@"01:45 PM",@"02:00 PM",@"02:15 PM",@"02:30 PM",@"02:45 PM",@"03:00 PM",@"03:15 PM",@"03:30 PM",@"03:45 PM",@"04:00 PM",@"04:15 PM",@"04:30 PM",@"04:45 PM",@"05:00 PM",@"05:15 PM",@"05:30 PM",@"05:45 PM",@"06:00 PM",@"06:15 PM",@"06:30 PM",@"06:45 PM",@"07:00 PM",@"07:15 PM",@"07:30 PM",@"07:45 PM",@"08:00 PM",@"08:15 PM",@"08:30 PM",@"08:45 PM",@"09:00 PM",@"09:15 PM",@"09:30 PM",@"09:45 PM",@"10:00 PM",@"10:15 PM",@"10:30 PM",@"10:45 PM",@"11:00 PM",@"11:15 PM",@"11:30 PM",@"11:45 PM", nil];
    }
}
- (void) incrementActiveProcesses:(int)processCount {
    @synchronized(self) {
        activeProcesses+=processCount;
        // if activity indicator is not shown, show it
        if(activeProcesses > 0 && !indicatorVisible) {
            //[UAppDelegate showActivityIndicator];
            indicatorVisible = YES;
        }
    }
}
- (void) decrementActiveProcesses {
    @synchronized(self) {
        activeProcesses--;
        // hide activity indicator
        if(activeProcesses <= 0 && indicatorVisible) {
            activeProcesses = 0;
            indicatorVisible = NO;
            //[UAppDelegate hideActivityIndicator];
        }
    }
}
- (void) rehydrateCaches:(BOOL)checkAge {
    [self initImageCaches];
    activeProcesses = 0;
    [self incrementActiveProcesses:5];
    [self rehydrateSessionUser];
    // rehydration of the snapshot categories will implicitly hydrate the Snapshots
    [self rehydrateSnapshotCategoriesCache:checkAge];
    [self rehydrateEventsCache:checkAge];
    [self rehydrateTweetsCache:checkAge];
    [self rehydrateTrendsCache:checkAge];
}
- (void) hydrateCaches {
    [self initImageCaches];
    [self hydrateSnapshotsCache];
    [self hydrateEventsCache];
    [self hydrateTweetsCache];
    [self hydrateTrendsCache];
}
- (void) rehydrateSchoolCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a school
        NSArray *values = [self.schools allValues];
        if ([values count] > 0) {
            NSMutableArray *sectionSchools = [values objectAtIndex:0];
            School *school = [sectionSchools objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:school.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SCHOOLS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        [self hydrateSchoolCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateEventsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.events count] > 0) {
            Event *event = [self.events objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:event.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_EVENTS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.eventImageMedium removeAllObjects];
        [self.eventImageThumbs removeAllObjects];
        [self hydrateEventsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateSnapshotsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a snapshot 
        NSArray *values = [self.snapshots allValues];
        if ([values count] > 0) {
            Snap *snap = [values objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:snap.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SNAPSHOTS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.snapImageMedium removeAllObjects];
        [self.snapImageThumbs removeAllObjects];
        [self hydrateSnapshotsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateSnapshotCategoriesCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        // grab a snapshot category
        NSArray *values = [self.snapshotCategories allValues];
        if ([values count] > 0) {
            SnapshotCategory *cat = [values objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:cat.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_SNAP_CATEGORIES) {
                rehydrate = FALSE;
            } 
        }
    }
    if (rehydrate) {
        [self hydrateSnapshotCategoriesCache:YES];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateTweetsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.tweets count] > 0) {
            Tweet *tweet = [self.tweets objectAtIndex:0];
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:tweet.cacheAge];
            if (timeElapsed <= CACHE_AGE_LIMIT_TWEETS) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        // clear out the image cache to maintain memory
        [self.tweetUserImages removeAllObjects];
        [self hydrateTweetsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateTrendsCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        /* NOTE: as of 01.12.13, we do not 
         * need to check an age for the trends
         * since we handle it on the server side.
         */
    }
    if (rehydrate) {
        [self hydrateTrendsCache];
    } else {
        [self decrementActiveProcesses];
    }
}
- (void) rehydrateImageCache:(BOOL)checkAge {
    BOOL rehydrate = TRUE;
    // check cache ages and refresh as necessary
    if (checkAge) {
        if ([self.images count] > 0) {
            // grab the cache age from the dictionary 
            double timeElapsed = [[NSDate date] timeIntervalSinceDate:[self.images objectForKey:KEY_CACHE_AGE]];
            if (timeElapsed <= CACHE_AGE_LIMIT_IMAGES) {
                rehydrate = FALSE;
            }
        }
    }
    if (rehydrate) {
        [self hydrateImageCache];
    }
}
- (void) rehydrateSessionUser {
    @try {
        clock_t start = clock();
        dispatch_queue_t userQueue = dispatch_queue_create(DISPATCH_USER, NULL);
        dispatch_async(userQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_USERS_USER];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                     
                    if([(NSString*)result isEqualToString:@"true"]) {
                        NSDictionary *response = [json objectForKey:JSON_KEY_RESPONSE];
                        @synchronized(self) {
                            // clear out the user's snaps and events
                            if(UDataCache.sessionUser.snaps != nil) {
                                [UDataCache.sessionUser.snaps removeAllObjects];
                            }
                            if(UDataCache.sessionUser.events != nil) {
                                [UDataCache.sessionUser.events removeAllObjects];
                            }
                            [UDataCache.sessionUser hydrateUser:response isSessionUser:YES];
                            // send a notification the ucampus view controller
                            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UCAMPUS_VIEW_CONTROLLER object:nil];
                        }
                    } else {
                    }
                    NSLog(@"rehydrateSessionUser complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                } else {// TODO: report error?
                }
                [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateImageCache {
    clock_t start = clock();
    // load the default images into the image dictionary
    if (self.images == nil) {
        self.images = [[NSMutableDictionary alloc] init];
    } else{
        [self.images removeAllObjects];
    }
    [self.images setValue:[NSDate date] forKey:KEY_CACHE_AGE];
    [self.images setValue:[UIImage imageNamed:@"default_user.jpg"] forKey:KEY_DEFAULT_USER_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_snap.png"] forKey:KEY_DEFAULT_SNAP_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_campus_event.png"] forKey:KEY_DEFAULT_EVENT_IMAGE];
    [self.images setValue:[UIImage imageNamed:@"default_featured_event.png"] forKey:KEY_DEFAULT_FEATURED_EVENT_IMAGE];
    NSLog(@"hydrateImageCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
}
- (void) hydrateSchoolCache {
    @try {
        clock_t start = clock();
        dispatch_queue_t schoolQueue = dispatch_queue_create(DISPATCH_SCHOOL, NULL);
        dispatch_async(schoolQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SCHOOLS_SCHOOL]]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized(self) {
                                if(self.schoolSections == nil) {
                                    self.schoolSections = [[NSMutableArray alloc] initWithObjects:@"", nil];
                                }  else {
                                    [self.schoolSections removeAllObjects];
                                }
                                if (self.schools == nil) {
                                    self.schools = [[NSMutableDictionary alloc] init];
                                } else{
                                    [self.schools removeAllObjects];
                                }
                                [self buildSchoolList:(NSArray*)[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                        NSLog(@"hydrateSchoolCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                    } else {// TODO: report error?
                    }
                 [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateEventsCache {
    @try {
        clock_t start = clock();
        dispatch_queue_t eventsQueue = dispatch_queue_create(DISPATCH_EVENTS, NULL);
        dispatch_async(eventsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_EVENTS_EVENTS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.userId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                   
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                    if([(NSString*)result isEqualToString:@"true"]) {
                        @synchronized(self) {
                            if(self.events == nil) {
                                self.events = [[NSMutableArray alloc] init];
                            } else {
                                [self.events removeAllObjects];
                            }
                            
                            if (self.featuredEvents == nil) {
                                self.featuredEvents = [[NSMutableArray alloc] init];
                            } else {
                                [self.featuredEvents removeAllObjects];
                            }
                            // build the events, and featured events
                            self.events = [UEventUtil hydrateEvents:[json objectForKey:JSON_KEY_RESPONSE] eventCollection:self.events hydrationType:kEventHydrationRegular];
                            self.featuredEvents = [UEventUtil hydrateEvents:[json objectForKey:JSON_KEY_RESPONSE] eventCollection:self.featuredEvents hydrationType:kEventHydrationFeatured];
                        }
                    } else {
                        // TODO: report error?
                    }
                } else {// TODO: report error?
                }
                NSLog(@"hydrateEventsCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                 [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateSnapshotCategoriesCache:(BOOL)implicitHydrateSnapshots {
    @try {
        clock_t start = clock();
        dispatch_queue_t snapCategoriesQueue = dispatch_queue_create(DISPATCH_SNAPSHOT_CATEGORIES, NULL);
        dispatch_async(snapCategoriesQueue, ^{
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[URL_SERVER stringByAppendingString:API_SNAPSHOTS_SNAP_CATEGORIES]]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                if ([data length] > 0 && error == nil) {
                    NSError* err;
                    NSDictionary* json = [NSJSONSerialization
                                          JSONObjectWithData:data
                                          options:kNilOptions
                                          error:&err];
                    NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                    if([(NSString*)result isEqualToString:@"true"]) {
                        @synchronized(self) {
                            if(self.snapshotCategories == nil) {
                                self.snapshotCategories = [[NSMutableDictionary alloc] init];
                            } else {
                                [self.snapshotCategories removeAllObjects];
                            }
                            self.snapshotCategories = [USnapshotUtil buildSnapshotCategories:(NSArray*)[json objectForKey:JSON_KEY_RESPONSE] snapshotCategories:self.snapshotCategories];
                            if(implicitHydrateSnapshots) {
                                [self hydrateSnapshotsCache];
                            }
                        }
                    } else {
                        // TODO: report error?
                    }
                } else {// TODO: report error?
                }
                NSLog(@"hydrateSnapshotCategoriesCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                [self decrementActiveProcesses];
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateSnapshotsCache {
    @synchronized(self) {
        // iterate over the categories
        NSEnumerator *e = [self.snapshotCategories keyEnumerator];
        id catId;
        while (catId = [e nextObject]) {
            /*
             * Retreive the snapshot data for each category
             *   
             * Format [category_id][NSMutableArray]
             */
            [self performSelectorInBackground:@selector(retrieveSnapshots:) withObject:catId];
        }
    }
}

- (void) hydrateTrendsCache {
    @try {
        clock_t start = clock();
        dispatch_queue_t trendsQueue = dispatch_queue_create(DISPATCH_TRENDS, NULL);
        dispatch_async(trendsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_UCAMPUS_TRENDS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized(self) {
                                if(self.trends == nil) {
                                    self.trends = [[NSMutableArray alloc] init];
                                } else {
                                    [self.trends removeAllObjects];
                                }
                                [self buildTrends:[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                         NSLog(@"hydrateTrendsCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                    } else {// TODO: report error?
                    }
                [self decrementActiveProcesses];

            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) hydrateTweetsCache {
    @try {
        clock_t start = clock();
        dispatch_queue_t tweetsQueue = dispatch_queue_create(DISPATCH_TWEETS, NULL);
        dispatch_async(tweetsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_UCAMPUS_TWEETS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                            @synchronized( self ) {
                                if(self.tweets == nil) {
                                    self.tweets = [[NSMutableArray alloc] init];
                                } else {
                                    [self.tweets removeAllObjects];
                                }
                                [self buildTweets:[json objectForKey:JSON_KEY_RESPONSE]];
                            }
                        } else {
                            // TODO: report error?
                        }
                        NSLog(@"hydrateTweetsCache complete: %f ms", (double)(clock()-start) / CLOCKS_PER_SEC);
                    } else {// TODO: report error?
                    }
                [self decrementActiveProcesses];

            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}

- (void) buildTrends:(id)trendsRaw {
    for(int idx = 0; idx < 5; idx++) {
        [self.trends addObject:[trendsRaw objectAtIndex:idx]];
    }
}
-(void) buildSchoolList:(id)schoolsRaw {
    // iterate over list of schools
    NSEnumerator *e = [schoolsRaw keyEnumerator];
    id schoolId;
    NSString *schoolSectionKey = nil;
    while (schoolId = [e nextObject]) {
        NSString* schoolName = [(NSDictionary*)schoolsRaw valueForKey:schoolId];
        
        // captialize the first letter of school name
        schoolName = [textUtil capitalizeString:schoolName];
        schoolSectionKey = [schoolName substringToIndex:1];
        // grab array from schools dictionary based on captialized letter
        NSMutableArray *sectionSchools = [self.schools objectForKey:schoolSectionKey];
        // if there is no array for that letter, create one
        if(sectionSchools == nil) {
            sectionSchools = [[NSMutableArray alloc] init];
        }
        // create school object, and add it to the retreived array
        School *school = [[School alloc] init];
        // set the name and id for the school
        school.name = schoolName;
        school.schoolId = schoolId;
        school.cacheAge = [NSDate date];
        [sectionSchools addObject:school];
        [self.schools setObject:sectionSchools forKey:schoolSectionKey];
    }
    
    NSArray *keys = [self.schools allKeys];
    // sort the cacheSchools by key
    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSEnumerator *ee = [sortedKeys objectEnumerator];
    id key;
    // iterate over the cacheSchools putting each section school in an array
    while (key = [ee nextObject]) { 
        [self.schoolSections addObject:(NSString*)key];
    }
}
-(void) retrieveSnapshots:(NSString*)categoryId {
    @try {
        dispatch_queue_t snapsQueue = dispatch_queue_create(DISPATCH_SNAPS, NULL);
        dispatch_async(snapsQueue, ^{
            NSString *requestData = [URL_SERVER stringByAppendingString:API_SNAPSHOTS_SNAPS];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:UDataCache.sessionUser.schoolId];
            requestData = [requestData stringByAppendingString:@"/"];
            requestData = [requestData stringByAppendingString:categoryId];
            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestData]];
            [req setHTTPMethod:HTTP_GET];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [NSURLConnection sendAsynchronousRequest:req queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    if ([data length] > 0 && error == nil) {
                        NSError* err;
                        NSDictionary* json = [NSJSONSerialization
                                              JSONObjectWithData:data
                                              options:kNilOptions
                                              error:&err];
                        NSArray* result = [json objectForKey:JSON_KEY_RESULT];
                        if([(NSString*)result isEqualToString:@"true"]) {
                                if(self.snapshots == nil) {
                                    self.snapshots = [[NSMutableDictionary alloc] init];
                                } 
                                // build the snapshots
                                NSMutableArray *snaps = [[NSMutableArray alloc] init];
                                snaps = [USnapshotUtil hydrateSnaps:[json objectForKey:JSON_KEY_RESPONSE] snapCollection:snaps];
                                [self.snapshots setValue:snaps forKey:categoryId];
                            NSLog(@"hydrateSnapshots Category %@ Complete.", ((SnapshotCategory*)[UDataCache.snapshotCategories objectForKey:categoryId]).name);
                        } else {
                            // TODO: report error?
                        }
                    } else {// TODO: report error?
                    }
            }];
        });
    }
    @catch (NSException *exception) {} // TODO: report error?
}
#pragma mark Cache Helpers
- (void) buildTweets:(id)tweetsRaw {
    // iterate over the tweets
    for(int idx=0;idx<[tweetsRaw count]; idx++) {
        // create the Tweet object
        Tweet *tweet = [[Tweet alloc] init];
        tweet.cacheAge = [NSDate date];
        tweet.created = [tweetDateFormatter dateFromString:[tweetsRaw[idx] objectForKey:@"created_at"]];
        tweet.tweetAge = [tweetsRaw[idx] objectForKey:@"age"];
        tweet.twitterUsername = [@"@" stringByAppendingString:[tweetsRaw[idx] objectForKey:@"from_user"]];
        tweet.twitterUserImage = [UDataCache.images objectForKey:KEY_DEFAULT_USER_IMAGE];
        tweet.twitterImageURL = [tweetsRaw[idx] objectForKey:@"profile_image_url"];
        tweet.tweetText = [tweetsRaw[idx] objectForKey:@"text"];
        NSDictionary *userRaw = [tweetsRaw[idx] objectForKey:@"ulinkuser"];
        if(userRaw != nil) {
            User *user = [[User alloc] init];
            [user hydrateUser:userRaw isSessionUser:NO];
            tweet.user = user;
        }
        [self.tweets insertObject:tweet atIndex:idx];
    }
}

#pragma mark

#pragma mark IMAGE CACHE
- (UIImage*)imageExists:(NSString*)cacheKey cacheModel:(NSString*)cacheModel {
    UIImage *retVal = nil;
    if ([cacheModel isEqualToString:IMAGE_CACHE_USER_THUMBS]) {
        for (NSString *key in [self.userImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.userImageThumbs objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_USER_MEDIUM]) {
        for (NSString *key in [self.userImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.userImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_THUMBS]) {
        for (NSString *key in [self.eventImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.eventImageThumbs objectForKey:key];
                break;
            }
        }
    }  else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_MEDIUM]) {
        for (NSString *key in [self.eventImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.eventImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_THUMBS]) {
        for (NSString *key in [self.snapImageThumbs allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.snapImageThumbs objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_MEDIUM]) {
        for (NSString *key in [self.snapImageMedium allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.snapImageMedium objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_TWEET_PROFILE]) {
        for (NSString *key in [self.tweetUserImages allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.tweetUserImages objectForKey:key];
                break;
            }
        }
    } else if ([cacheModel isEqualToString:IMAGE_CACHE]) {
        for (NSString *key in [self.images allKeys]) {
            if ([cacheKey isEqualToString:key]) {
                retVal = [self.images objectForKey:key];
                break;
            }
        }
    }
    return retVal;
}
- (void) removeImage:(NSString*)cacheKey cacheModel:(NSString*)cacheModel {
    if ([cacheModel isEqualToString:IMAGE_CACHE_USER_THUMBS]) {
        [self.userImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_USER_MEDIUM]) {
        [self.userImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_MEDIUM]) {
        [self.eventImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_EVENT_THUMBS]) {
        [self.eventImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_MEDIUM]) {
        [self.snapImageMedium removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_SNAP_THUMBS]) {
        [self.snapImageThumbs removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE_TWEET_PROFILE]) {
        [self.tweetUserImages removeObjectForKey:cacheKey];
    } else if ([cacheModel isEqualToString:IMAGE_CACHE]) {
        [self.images removeObjectForKey:cacheKey];
    }
}

- (BOOL) userIsLoggedIn {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return ([defaults objectForKey:@"userIsLoggedIn"] != nil);
}

- (void) storeUserLoginInfo {
    // persist last successful login data on the device
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.sessionUser.username forKey:@"username"];
    [defaults setObject:self.sessionUser.password forKey:@"password"];
    [defaults setObject:@"YES" forKey:@"userIsLoggedIn"];
    [defaults synchronize];
}
- (void) removeLoginInfo {
    // remove last successful login data on the device
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"password"];
    [defaults removeObjectForKey:@"userIsLoggedIn"];
    [defaults synchronize];
}
@end
