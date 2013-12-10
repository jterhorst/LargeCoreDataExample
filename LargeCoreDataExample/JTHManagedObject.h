//
//  JTHManagedObject.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "JTHMappable.h"

@interface JTHManagedObject : NSManagedObject <JTHMappable>

+ (JTHManagedObject *)createOrUpdateWithDictionary:(NSDictionary *)dictionary withContext:(NSManagedObjectContext *)context;
- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary;

@end
