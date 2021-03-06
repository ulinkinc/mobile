//
//  SettingsViewController.m
//  uLink
//
//  Created by Bennie Kingwood on 11/29/12.
//  Copyright (c) 2012 uLink, Inc. All rights reserved.
//

#import "SettingsViewController.h"
#import "UlinkButton.h"
#import "AppMacros.h"
#import "DataCache.h"
#import "MainNavigationViewController.h"
#import "ImageUtil.h"
@interface SettingsViewController () {
    UIFont *cellFont;
    UlinkButton *logoutButton;
}
- (void)logout;
- (void) hydrateInitialCaches;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //Initialization
    UITableView *tv = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                                   style:UITableViewStyleGrouped];
    
    // assuming that your controller adopts the UITableViewDelegate and
    // UITableViewDataSource protocols, add the following 2 lines:
    
    tv.delegate = self;
    tv.dataSource = self;
    
    
    self.tableView = tv;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor colorWithRed:182.0f / 255.0f green:204.0f / 255.0f blue:213.0f / 255.0f alpha:1.0f];
    cellFont = [UIFont fontWithName:FONT_GLOBAL size:15.0f];
    CGRect logoutButtonFrame  = CGRectMake(20, 300, 280, 50);
    logoutButton = [UlinkButton buttonWithType:UIButtonTypeCustom];
    logoutButton.frame = logoutButtonFrame;
    [logoutButton setTitle:@"Log Out" forState:UIControlStateNormal];
    [logoutButton createRedButton:logoutButton];
    [logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:logoutButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) logout {
    // change the nav bar to be back to the main color
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ulink-mobile-nav-bar-bg.png"] forBarMetrics:UIBarMetricsDefault];
    [UDataCache removeLoginInfo];
    // clear all cache data
    [UDataCache clearCache];
    // remove the school image, NOTE: this can probably be removed once we add a schoolImage cache
    [UDataCache removeImage:KEY_SESSION_USER_SCHOOL cacheModel:IMAGE_CACHE];
    // pop back to the login screen 
    MainNavigationViewController *parent = (MainNavigationViewController*)self.presentingViewController;
    [parent popToRootViewControllerAnimated:NO];
    // rehydrate school cache in background 
    [self performSelectorInBackground:@selector(hydrateInitialCaches) withObject:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) hydrateInitialCaches {
    [UDataCache rehydrateSchoolCache:YES];
    [UDataCache hydrateSnapshotCategoriesCache:NO];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = CELL_SETTINGS;
    int section = [indexPath section];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.font = cellFont;
    switch (section) {
        case 0:
            cell.textLabel.text = @"About";
            break;
        case 1:
            cell.textLabel.text = @"Help";
            break;
        case 2:
            cell.textLabel.text = @"Terms";
            break;
    }
    return cell;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view;
    if(section > 0) {
        UILabel *retVal = nil;

        // Create label with section title
        retVal = [[UILabel alloc] init];
        retVal.frame = CGRectMake(20, 10, 150, 20);
        retVal.textColor = [UIColor darkGrayColor];
        retVal.font = [UIFont fontWithName:FONT_GLOBAL size:14];
        retVal.backgroundColor = [UIColor clearColor];
        retVal.shadowColor = [UIColor whiteColor];
        retVal.shadowOffset = CGSizeMake(0.0f, -0.5f);
        if(section == 1) {
            retVal.text = @"Looking for help?";
        } else {
            retVal.text = @"Legal";
        }
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        [view addSubview:retVal];
    }
    return view;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
             [self performSegueWithIdentifier:SEGUE_SHOW_ABOUT_VIEW_CONTROLLER sender:self];
            break;
        case 1: [self performSegueWithIdentifier:SEGUE_SHOW_HELP_VIEW_CONTROLLER sender:self];
            break;
        case 2: [self performSegueWithIdentifier:SEGUE_SHOW_TERMS_VIEW_CONTROLLER sender:self];
            break;
    }
}

- (IBAction)doneClick:(UIBarButtonItem *)sender {
    // change the nav bar to be back to the main color
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"ulink-mobile-nav-bar-bg.png"] forBarMetrics:UIBarMetricsDefault];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
