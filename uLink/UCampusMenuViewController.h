//
//  UCampusMenuViewController.h
//  uLink
//
//  Created by Bennie Kingwood on 11/19/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
@protocol UCampusMenuViewControllerDelegate;
@protocol UCampusMenuViewControllerDelegate <NSObject>
-(void) performSegue:(NSInteger)item;
@end

@interface UCampusMenuViewController : UITableViewController
@property (nonatomic, assign) MFSideMenu *sideMenu;
@property (nonatomic, assign) id<UCampusMenuViewControllerDelegate> delegate;

-(void)hideMenu;
-(void)showMenu;
@end
