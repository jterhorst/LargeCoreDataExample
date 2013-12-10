//
//  Person.m
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import "Person.h"


@implementation Person

@dynamic remoteID;
@dynamic guid;
@dynamic isActive;
@dynamic balance;
@dynamic imageURL;
@dynamic age;
@dynamic name;
@dynamic gender;
@dynamic company;
@dynamic email;
@dynamic phone;
@dynamic address;
@dynamic about;
@dynamic registeredDate;
@dynamic latitude;
@dynamic longitude;
@dynamic favoriteFruit;

/*
	I've commented most of these out, as our people list view doesn't need most of these.
	If you can, try to keep the number of properties in the JSON small - bare minimum. It's much, much faster that way.
	I don't cover relationships in this demo, because you shouldn't include them with this much data - that's a huge performance hit.
 */

+ (NSDictionary *)mappableAttributes
{
	return @{@"id":@"remoteID",
			 @"guid":@"guid",
			 /*@"isActive":@"isActive",
			 @"balance":@"balance",
			 @"picture":@"imageURL",
			 @"age":@"age",*/
			 @"name":@"name",
			 /*@"gender":@"gender",
			 @"company":@"company",
			 @"email":@"email",
			 @"phone":@"phone",
			 @"address":@"address",
			 @"about":@"about",
			 @"registered":@"registeredDate",
			 @"latitude":@"latitude",
			 @"longitude":@"longitude",*/
			 @"randomArrayItem":@"favoriteFruit"
			 };
}

+ (NSString *)entityName
{
	return @"Person";
}

@end
