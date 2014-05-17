//
//  Photo.h
//  Top Regions
//
//  Created by Amy Bearman on 5/17/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Region;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * photoURL;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSDate * dateLastViewed;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) Region *whereTaken;

@end
