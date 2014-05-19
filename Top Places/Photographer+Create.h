//
//  Photographer+Create.h
//  Top Regions
//
//  Created by Amy Bearman on 5/19/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
