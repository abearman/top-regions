//
//  NSUserDefaultsAccess.m
//  Top Places
//
//  Created by Amy Bearman on 5/11/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "NSUserDefaultsAccess.h"

@implementation NSUserDefaultsAccess

- (NSArray *) getSavedRecentPhotosArray {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPhotos"];
}

- (void)addPhotoToListOfRecentsWithPhoto: (NSDictionary *)photo {
    NSArray *recentPhotos = [[NSUserDefaults standardUserDefaults] objectForKey:@"recentPhotos"];
    
    if (recentPhotos == nil) {
        recentPhotos = [[NSArray alloc] initWithObjects:photo, nil];
    } else {
        NSMutableArray *recentPhotosMutable = [recentPhotos mutableCopy];
        if ([recentPhotosMutable containsObject:photo]) {
            [recentPhotosMutable removeObject:photo];
        }
        [recentPhotosMutable insertObject:photo atIndex:0];
        if ([recentPhotosMutable count] > 20) {
            [recentPhotosMutable removeLastObject];
        }
        
        recentPhotos = recentPhotosMutable;
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentPhotos forKey:@"recentPhotos"];
}
    
@end
