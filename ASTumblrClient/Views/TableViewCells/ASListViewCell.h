//
//  ASListViewCell.h
//  ASTumblrClient
//
//  Created by sakahara on 2013/10/20.
//  Copyright (c) 2013年 Mocology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASListViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *listImageView;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *messageLabel;

@end
