//
//  ASListViewController.m
//  ASTumblrClient
//
//  Created by sakahara on 2013/10/20.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import "ASListViewController.h"
#import "SettingInfo.h"
#import "TMAPIClient.h"
#import "ASListViewCell.h"
#import "ASDateUtil.h"
#import "UIImageView+WebCache.h"
#import "ASStringUtil.h"

@interface ASListViewController ()

@property (nonatomic, strong) NSString *tumblrBlogName;
@property (nonatomic, strong) NSMutableArray *dashboardPosts;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, assign) BOOL hasMorePage;

@end

@implementation ASListViewController

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

    SettingInfo *settingInfo = [SettingInfo sharedInstance];
    
    self.dashboardPosts = [NSMutableArray array];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction:)
                  forControlEvents:UIControlEventValueChanged];
    
    if (settingInfo.tumblrAuthToken.length > 0) {
        
        [TMAPIClient sharedInstance].OAuthToken = settingInfo.tumblrAuthToken;
        [TMAPIClient sharedInstance].OAuthTokenSecret = settingInfo.tumblrAuthTokenSecret;
        
        [self requestDashboardPosts];
        
    } else {
        
        __weak ASListViewController *weakSelf = self;
        [[TMAPIClient sharedInstance] authenticate:@"astumblrclient" callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error login to Tumblr");
            } else {
                NSLog(@"login to Tumblr");
                
                settingInfo.tumblrAuthToken = [TMAPIClient sharedInstance].OAuthToken;
                settingInfo.tumblrAuthTokenSecret = [TMAPIClient sharedInstance].OAuthTokenSecret;
                
                [settingInfo save];
                
                [weakSelf requestDashboardPosts];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.

    if (self.hasMorePage) {
        return self.dashboardPosts.count + 1;
    }
    
    return self.dashboardPosts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.dashboardPosts.count) {
        return [self configureCell:indexPath];
    } else {
        return [self loadingCell];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.tag == LOADING_CELL_TAG) {
        cell.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        if (self.hasMorePage) {
            [self requestDashboardPosts];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= self.dashboardPosts.count) {
        return 50.0;
    }
    
    return tableView.rowHeight;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)refreshAction:(id)sender
{
    self.isRefresh = YES;
    self.hasMorePage = YES;
    
    [self requestDashboardPosts];
}

#pragma mark - cell setup

// Setup a timeline cell.
- (UITableViewCell *)configureCell:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ASListViewCell";
    ASListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *post = self.dashboardPosts[indexPath.row];
    // caption
    cell.messageLabel.text = [ASStringUtil removeTag:post[@"caption"]];
    // date
    cell.dateLabel.text = [ASDateUtil parseDate:post[@"date"]];
    // image
    NSArray *photos = post[@"photos"];
    if (photos.count > 0) {
        NSArray *photoSizes = photos[0][@"alt_sizes"];
        if (photoSizes.count > 1) {
            NSDictionary *photoSize = photoSizes[1];
            [cell.listImageView setImageWithURL:[NSURL URLWithString:photoSize[@"url"]] placeholderImage:nil];
        }
    }
    
    return cell;
}

// Setup  a loading cell.
- (UITableViewCell *)loadingCell {
    UITableViewCell *cell = [[UITableViewCell alloc]
                             initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:nil];
    
    if (self.dashboardPosts.count > 0) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityIndicator.center = cell.center;
        [cell.contentView addSubview:activityIndicator];
        
        [activityIndicator startAnimating];
    }
    
    cell.tag = LOADING_CELL_TAG;
    
    return cell;
}


- (void)requestDashboardPosts
{
    __weak ASListViewController *weakSelf = self;
    
    int offset = 0;
    if (self.dashboardPosts.count > 0) {
        offset = self.dashboardPosts.count;
    }
    
    if (weakSelf.isRefresh) {
        offset = 0;
    }
    
    [[TMAPIClient sharedInstance] dashboard:@{@"type": @"photo",
                                              @"limit" : @"20",
                                              @"offset" : [NSString stringWithFormat:@"%d", offset]}
                                   callback:^(id results, NSError *error) {
        
        NSLog(@"results: %@", [results description]);
        
        NSArray *posts = results[@"posts"];
        if (posts.count > 0) {
            
            self.hasMorePage = YES;
            
            if (weakSelf.isRefresh) {
                [weakSelf.dashboardPosts removeAllObjects];
            }
            
            weakSelf.isRefresh = NO;
            
            [weakSelf.dashboardPosts addObjectsFromArray:posts];
            
            NSLog(@"posts: %@", posts.description);
            
            [weakSelf.tableView reloadData];
        } else {
            self.hasMorePage = NO;
        }
        
        [weakSelf.refreshControl endRefreshing];
    }];
}

@end
