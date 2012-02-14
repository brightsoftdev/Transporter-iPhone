//
//  LinesVC.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Agency.h"
#import "TransitDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "LinesTableView.h"

@interface LinesVC : UIViewController {

	UISegmentedControl *segmentedControl;
	
	LinesTableView *tableView;
	
	TransitDelegate *transitDelegate;
	
	CLLocationManager *locationManager;
	
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;

@property (nonatomic, retain) IBOutlet LinesTableView *tableView;

@property (nonatomic, retain) TransitDelegate *transitDelegate;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)tapAgency;
- (Agency *)fetchAgencyData:(NSString *)agency;
- (void)loadNextViewController:(NSNotification *)note;


@end
