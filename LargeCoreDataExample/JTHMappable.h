//
//  JTHMappable.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTHMappable <NSObject>

@required

+ (NSString *)primaryKeyElementName; // the name of the unique ID in the JSON
+ (NSString *)primaryKeyPropertyName; // the name of the unique ID property in model

+ (NSDictionary *)mappableAttributes; // the key from the JSON element (key), matched to its associated property in the model (value
									  // this allows your model to have clearer (or more Cocoa-like names), even if you can't control the JSON.

+ (NSString *)entityName;

/*
	I don't cover mappableRelationships in this demo, but they'd be the same as mappableAttributes,
	but instead of a string, number, or date, you're creating an NSManagedObject (to-one) or NSSet of NSManagedObjects (to-many),
	and applying those objects to the correct key in this object.
	These are expensive to do, so I don't recommend loading and mapping them for these huge JSON lists.
 */

@end
