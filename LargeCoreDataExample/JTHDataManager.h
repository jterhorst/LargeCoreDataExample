//
//  JTHDataManager.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JTHDataManagerDelegate <NSObject>

@optional

- (void)dataManagerBeganUpdatingPeople;
- (void)dataManagerDidUpdatePeople;

@end

@interface JTHDataManager : NSObject
{
	NSMutableArray * _delegates;

	dispatch_queue_t parsingQueue;
	NSOperationQueue * _parsingOperationQueue;

	NSManagedObjectModel * _managedObjectModel;
	NSString * _managedObjectModelName;
}

#pragma mark - Update methods

- (void)updatePeople;
- (BOOL)currentlyUpdatingPeople;

#pragma mark - Util

- (void)addDelegate:(id <JTHDataManagerDelegate>)delegate;
- (void)removeDelegate:(id <JTHDataManagerDelegate>)delegate;

+ (JTHDataManager *)sharedManager;


#pragma mark - Core Data

// Core Data
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext; // use this context to handle UI tasks. don't take it to another thread.
@property (nonatomic, retain) NSManagedObjectContext *diskMOC; // for saving to disk only. don't use this context directly.

- (void)save;
- (void)saveContext:(NSManagedObjectContext *)context;


#pragma mark - Fetching

- (id)objectWithID:(NSManagedObjectID *)objectID;
- (id)objectWithID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context;

@end
