//
//  Listing.h
//  ulink
//
//  Created by Christopher Cerwinski on 5/10/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Location.h"

@interface Listing : NSObject
@property (nonatomic) NSString *_id;
@property (nonatomic) NSInteger userId;
@property (nonatomic) NSInteger schoolId;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *replyTo;
@property (nonatomic) NSString *listDescription;
@property (nonatomic) NSString *shortDescription;
@property (nonatomic) NSString *mainCategory;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *email;
@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) NSMutableArray *imageUrls;
@property (strong, nonatomic) NSMutableArray *tags;
@property (strong, nonatomic) NSMutableArray *meta;
@property (strong, nonatomic) NSMutableArray *files;
@property (nonatomic) NSDate *created;
@property (nonatomic) NSDate *expires;
@property (nonatomic) NSDate *cacheAge;
@end
