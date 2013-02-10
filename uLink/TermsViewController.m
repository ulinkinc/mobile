//
//  TermsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/30/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "TermsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TermsViewController ()

@end

@implementation TermsViewController
@synthesize termsTextView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.termsTextView.layer.cornerRadius = 5;
    self.termsTextView.layer.masksToBounds = YES;
    
    // adjust the height of the text view if it's an iPhone5
   /* CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (screenHeight > 560) {
        CGRect frame = self.termsTextView.frame;
        frame.size.height = screenHeight-30;
        self.termsTextView.frame = frame;
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
