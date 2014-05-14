//
//  NSUserDefaultsAccess.h
//  Top Places
//
//  Created by Amy Bearman on 5/11/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsAccess : NSObject

- (NSArray *) getSavedRecentPhotosArray;
- (void) addPhotoToListOfRecentsWithPhoto: (NSDictionary *)photo;

@end
