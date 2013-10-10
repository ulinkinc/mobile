//
//  ImageUtil.m
//  uLink
//
//  Created by Bennie Kingwood on 1/20/13.
//  Copyright (c) 2013 uLink, Inc. All rights reserved.
//

#import "ImageUtil.h"
#import "AppMacros.h"
@implementation ImageUtil
NSString *letters;
+ (ImageUtil*) instance {
    static ImageUtil* _one = nil;
    
    @synchronized( self ) {
        if( _one == nil ) {
            _one = [[ ImageUtil alloc ] init ];
        }
    }
    return _one;
}
-(id)init {
    if (self = [super init]) {
        // TODO: move this to it's own class
        letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    }
    return self;
}
- (NSData*) compressImageToData:(UIImage*)image {
    NSData *retVal = nil;
    if(image != nil) {
        CGFloat compression = 0.9f; // start the compression at 90% image quality
        CGFloat maxCompression = 0.1f; // go as low as 10% image quality
        int maxFileSize = IMAGE_MAX_FILE_SIZE*1024; // measured in bytes
        retVal = UIImageJPEGRepresentation(image, compression);
        while ([retVal length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            retVal = UIImageJPEGRepresentation(image, compression);
        }
    }
    return retVal;
}
- (UIImage*) compressImage:(UIImage*)image {
    return [UIImage imageWithData:[self compressImageToData:image]];
}


-(NSString *) generateRandomString: (int) length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

-(UIImage *) resizeImageForTableViewCellWithName: (NSString*)name size:(CGSize)size {
    UIImage *bigImage = [UIImage imageNamed:name];
    UIImage *thumb = [self makeThumbnailOfSizeWithImage:bigImage size:size];
    return thumb;
}

- (UIImage *) makeThumbnailOfSizeWithImage: (UIImage*)image size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    //UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
    // draw scaled image into thumbnail context
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    if(newThumbnail == nil)
        NSLog(@"could not scale image");
    return newThumbnail;
}
@end
