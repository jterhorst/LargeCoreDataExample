//
//  JTHMasterViewController.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "JTHDataManager.h"

@interface JTHMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, JTHDataManagerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) UIActivityIndicatorView * loadingIndicatorView;

@end
