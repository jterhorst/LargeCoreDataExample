//
//  Person.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "JTHManagedObject.h"


@interface Person : JTHManagedObject

@property (nonatomic) int64_t remoteID;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic) BOOL isActive;
@property (nonatomic, retain) NSString * balance;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic) int64_t age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * about;
@property (nonatomic) NSTimeInterval registeredDate;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
@property (nonatomic, retain) NSString * favoriteFruit;

@end
