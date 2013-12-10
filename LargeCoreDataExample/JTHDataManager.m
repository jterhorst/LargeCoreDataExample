//
//  JTHDataManager.m
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import "JTHDataManager.h"

#import "Person.h"

@interface JTHDataManager ()
{
	NSString * localStoragePath;
}

@end

static NSString * StoreFilename = @"coredatatest.sqlite";

@implementation JTHDataManager

- (id)init
{
	self = [super init];
	if (self)
	{
		NSString * executableName = nil;

#if !TARGET_OS_IPHONE
		executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
#endif

		NSError *error;

		localStoragePath = [JTHDataManager _findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponent:executableName error:&error];

		_managedObjectModelName = @"LargeCoreDataExample";

		parsingQueue = dispatch_queue_create("com.jterhorst.cdexample.parsing", DISPATCH_QUEUE_SERIAL);

		_parsingOperationQueue = [[NSOperationQueue alloc] init];
		[_parsingOperationQueue setMaxConcurrentOperationCount:1000];

		[_parsingOperationQueue addObserver:self forKeyPath:@"operations" options:0 context:NULL];

	}

	return self;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"operations"])
	{
		NSOperationQueue * queue = object;

        if ([object operationCount] == 0)
		{
            NSLog(@"queue has completed: %@", queue);

			dispatch_async(dispatch_get_main_queue(), ^{

				[self _informDelegatesOfUpdatedPeople];

			});
        }
	}
    else
	{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Update methods

- (void)updatePeople;
{
	NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Person"];
    for (NSManagedObject *obj in [[self managedObjectContext] executeFetchRequest:fetch error:nil]) {
        [[self managedObjectContext] deleteObject:obj];
    }

	[self _informDelegatesOfStartedUpdatingPeople];

	dispatch_async(parsingQueue, ^{

		@autoreleasepool {
			NSInputStream * exampleFileStream = [NSInputStream inputStreamWithFileAtPath:[[NSBundle mainBundle] pathForResource:@"10000_example" ofType:@"json"]];
			[exampleFileStream open];

			NSError * readError = nil;

			NSArray * peopleRawArray = [NSJSONSerialization JSONObjectWithStream:exampleFileStream options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&readError];

			if (!readError)
			{
				NSInteger currentOffset = 0;
				while (currentOffset < [peopleRawArray count]) {
					NSInteger pageLength = 100;
					if (currentOffset + pageLength > [peopleRawArray count])
					{
						pageLength = [peopleRawArray count] - currentOffset;
					}

					NSArray * pageArray = [peopleRawArray subarrayWithRange:NSMakeRange(currentOffset, pageLength)];

					[_parsingOperationQueue addOperationWithBlock:^{

						@autoreleasepool {
							NSManagedObjectContext * context = [[NSManagedObjectContext alloc] init];
							[context setParentContext:[self managedObjectContext]];

							for (NSDictionary * personDictionary in pageArray)
							{
								Person * newPerson = (Person *)[Person createOrUpdateWithDictionary:personDictionary withContext:context];

								[context obtainPermanentIDsForObjects:@[newPerson] error:nil];

								// use something this if you want to communicate to another thread when the object is ready
								//[_completedObjects setObject:[newPerson objectID] forKey:@(newPerson.remoteID)];
							}

							[self saveContext:context];
						}
						
					}];

					currentOffset = currentOffset + 100;
				}
			}
			else
			{
				NSLog(@"error reading JSON: %@", readError);
			}
		}

	});
}

- (BOOL)currentlyUpdatingPeople
{
	return ([_parsingOperationQueue operationCount] > 0);
}


- (void)_informDelegatesOfStartedUpdatingPeople
{
	for (id<JTHDataManagerDelegate> del in _delegates)
	{
		if ([del respondsToSelector:@selector(dataManagerBeganUpdatingPeople)])
		{
			[del dataManagerBeganUpdatingPeople];
		}
	}
}

- (void)_informDelegatesOfUpdatedPeople
{
	for (id<JTHDataManagerDelegate> del in _delegates)
	{
		if ([del respondsToSelector:@selector(dataManagerDidUpdatePeople)])
		{
			[del dataManagerDidUpdatePeople];
		}
	}
}



#pragma mark - Paths

- (NSString *)localDataStorageDirectoryPath;
{
	return localStoragePath;
}

- (NSString *)dataStoreFilePath
{
	return [localStoragePath stringByAppendingPathComponent:StoreFilename];
}

+ (NSString *)_findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory inDomain:(NSSearchPathDomainMask)domainMask appendPathComponent:(NSString *)appendComponent error:(NSError **)errorOut;
{
	//
	// Search for the path
	//
	NSArray * paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory, domainMask, YES);
	if ([paths count] == 0)
	{
		if (errorOut)
		{
			NSDictionary *userInfo =
			[NSDictionary dictionaryWithObjectsAndKeys:
			 NSLocalizedStringFromTable(
										@"No path found for directory in domain.",
										@"Errors",
										nil),
			 NSLocalizedDescriptionKey,
			 [NSNumber numberWithInteger:searchPathDirectory],
			 @"NSSearchPathDirectory",
			 [NSNumber numberWithInteger:domainMask],
			 @"NSSearchPathDomainMask",
			 nil];
			*errorOut =
			[NSError
			 errorWithDomain:@"Directory Location"
			 code:0
			 userInfo:userInfo];
		}
		return nil;
	}

	if ([paths count] == 0) return nil;

	//
	// Normally only need the first path returned
	//
	NSString *resolvedPath = [paths objectAtIndex:0];

	//
	// Append the extra path component
	//
	if (appendComponent)
	{
		resolvedPath = [resolvedPath
						stringByAppendingPathComponent:appendComponent];
	}

	//
	// Create the path if it doesn't exist
	//
	NSError *error = nil;
	BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:resolvedPath withIntermediateDirectories:YES attributes:nil error:&error];
	if (!success)
	{
		if (errorOut)
		{
			*errorOut = error;
		}
		return nil;
	}

	//
	// If we've made it this far, we have a success
	//
	if (errorOut)
	{
		*errorOut = nil;
	}
	return resolvedPath;
}


#pragma mark - Core Data stack

- (void)save
{
    [self.managedObjectContext performBlockAndWait:^{
        NSAssert([[NSThread currentThread] isMainThread], @"Save the managed object context from the main thread");
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error != nil) {
            NSLog(@"%@",error);
        }
        [self.diskMOC performBlock:^{
            NSAssert(![[NSThread currentThread] isMainThread], @"Save the master managed object context on a background thread");
            NSError *bgError = nil;
            [self.diskMOC save:&bgError];
            if (bgError == nil) {

            } else {
                NSLog(@"%@",error);
            }
        }];
    }];
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    [context save:nil];
    [self save];
}


- (NSManagedObjectModel *)_managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    if (_managedObjectModelName == nil) {
        [NSException raise:@"No name for the managed object model found" format:@"Please set a managed object model name by calling setManagedObjectModelName:"];
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *modelURL = [bundle URLForResource:_managedObjectModelName withExtension:@"mom"];
    if (modelURL == nil) {
        modelURL = [bundle URLForResource:_managedObjectModelName withExtension:@"momd"];

		if (!modelURL)
		{
			NSLog(@"Error finding any mom or momd file");
		}
    }
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSManagedObjectContext*)managedObjectContext
{
	if (_managedObjectContext) return _managedObjectContext;

	[self willChangeValueForKey:@"managedObjectContext"];

	NSManagedObjectModel *mom = [self _managedObjectModel];

	if (![[NSFileManager defaultManager] fileExistsAtPath:[self localDataStorageDirectoryPath]])
	{
		if ([[NSFileManager defaultManager] createDirectoryAtPath:[self localDataStorageDirectoryPath] withIntermediateDirectories:YES attributes:nil error:nil])
		{
			NSLog(@"created data directory");
		}
	}

	NSURL *storeUrl = [NSURL fileURLWithPath: [self dataStoreFilePath]];
	NSLog(@"attempting to save at %@", [storeUrl absoluteString]);

	NSError *error = nil;

    void(^SetupCoreDataStack)(NSPersistentStoreCoordinator *) = ^(NSPersistentStoreCoordinator *psc) {
        _diskMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _diskMOC.persistentStoreCoordinator = psc;

		_managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		[_managedObjectContext setParentContext:self.diskMOC];

        [self save];
    };

	// setup our context. if we get an exception, it's probably an invalid model or store file.
	// deleting the local file is fine to try to get us up and running again.
	@try {
		NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

		NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

		if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
		{
			if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataStoreFilePath]])
			{
				[[NSFileManager defaultManager] removeItemAtPath:[self dataStoreFilePath] error:nil];
			}

			NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

			NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

			if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error])
			{
				NSAssert(1, @"Failed to setup persistent store. Can't continue.");
			}
		}

        SetupCoreDataStack(psc);
	}
	@catch (NSException *exception) {

		if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataStoreFilePath]])
		{
			[[NSFileManager defaultManager] removeItemAtPath:[self dataStoreFilePath] error:nil];
		}

		NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

		NSDictionary *options = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

		NSAssert([psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error], @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);

		SetupCoreDataStack(psc);
	}


	[self didChangeValueForKey:@"managedObjectContext"];

	return _managedObjectContext;
}


#pragma mark - Fetching

- (id)objectWithID:(NSManagedObjectID *)objectID
{
	NSAssert([[NSThread currentThread] isMainThread], @"Must call objectWithID: on main thread. Otherwise, use inContext:");

    return [self objectWithID:objectID inContext:self.managedObjectContext];
}

- (id)objectWithID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context
{
    if (objectID == nil)
	{
        NSLog(@"Can't find object with a nil id!");
        return nil;
    }

    NSError *err = nil;
    id obj = [context existingObjectWithID:objectID error:&err];
    if (err != nil)
	{
        NSLog(@"Couldn't get data for object ID %@: %@; details: %@", objectID, err.localizedDescription, [err userInfo]);
    }
	
    return obj;
}



#pragma mark - Util

- (void)addDelegate:(id <JTHDataManagerDelegate>)delegate;
{
	if (!_delegates)
	{
		_delegates = [[NSMutableArray alloc] init];
	}

	[_delegates addObject:delegate];
}

- (void)removeDelegate:(id <JTHDataManagerDelegate>)delegate;
{
	[_delegates removeObject:delegate];
}

+ (JTHDataManager *)sharedManager;
{
	static dispatch_once_t pred = 0;
	__strong static JTHDataManager * _sharedObject = nil;
	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init]; // or some other init method
	});
	return _sharedObject;
}

@end
