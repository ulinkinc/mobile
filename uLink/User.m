//
//  User.m
//  uLink
//
//  Created by Bennie Kingwood on 11/16/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "User.h"
#import "AppMacros.h"
#import "Snap.h"
#import "SnapshotComment.h"
#import "SnapshotUtil.h"
#import "EventUtil.h"

@implementation User
@synthesize cacheAge,
userId,username,firstname,lastname,password,email,schoolId,major,year,schoolStatus, schoolName;
@synthesize bio,twitterEnabled,twitterUsername, profileImage, userImgURL;
@synthesize events;
@synthesize snaps;

-(id)init {
    if (self = [super init]) {
        // Initialization code here
    }
    return self;
}

- (void) hydrateUser:(NSDictionary *)rawData  {
    // password is already set in the caller
    self.userId = [rawData objectForKey:@"id"];
    self.username = [rawData objectForKey:@"username"];
    self.bio = [rawData objectForKey:@"bio"];
    self.email = [rawData objectForKey:@"email"];
    self.major = [rawData objectForKey:@"major"];
    self.year = [rawData objectForKey:@"year"];
    self.firstname = [rawData objectForKey:@"firstname"];
    self.lastname  = [rawData objectForKey:@"lastname"];
    self.schoolId = [rawData objectForKey:@"school_id"];
    self.schoolStatus = [rawData objectForKey:@"school_status"];
    self.twitterEnabled = (BOOL)[rawData objectForKey:@"twitter_enabled"];
    self.twitterUsername = [rawData objectForKey:@"twitter_username"];
    self.schoolName = [rawData objectForKey:@"school_name"];
    // load the image from the image url
    self.userImgURL =[rawData objectForKey:@"image_url"];
    if(self.userImgURL != nil) {
        NSURL *url = [NSURL URLWithString:[URL_USER_IMAGE stringByAppendingString:self.userImgURL]];
        self.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        if (self.profileImage == nil) {
             self.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_USER_IMAGE]]];
        }
    } else {
         self.profileImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:URL_DEFAULT_USER_IMAGE]]];
    }
    self.cacheAge = [NSDate date];
    self.events = [UEventUtil hydrateEvents:[rawData objectForKey:@"Events"] eventCollection:self.events hydrationType:kEventHydrationAll];
    self.snaps = [USnapshotUtil hydrateSnaps:[rawData objectForKey:@"Snaps"] snapCollection:self.snaps];
}
@end