//
//  JTHDetailViewController.h
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTHDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
