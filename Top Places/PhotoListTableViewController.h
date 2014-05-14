//
//  PhotoListTableViewController.h
//  Top Places
//
//  Created by Amy Bearman on 5/10/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoListTableViewController : UITableViewController
@property (nonatomic, strong) NSArray *photos;
@property (nonatomic, strong) NSString *placeId;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
