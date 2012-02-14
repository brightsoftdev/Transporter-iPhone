    //
//  StopDetails.m
//  transporter
//
//  Created by Ljuba Miljkovic on 4/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "StopDetails.h"


@implementation StopDetails

@synthesize stop, stopTitleImageView, stopTitleLabel, tableView, contents, lastIndexPath, buttonRowPlaceholder, cellStatus;
@synthesize timer, errors, isFirstPredictionsFetch, predictions, tableFooterHeight, tableHeaderHeight;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//GENERAL SETTINGS
	self.title = @"Arrivals";
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Stop" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];

	self.view.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	cellStatus = kCellStatusSpinner;
	isFirstPredictionsFetch = YES;
	buttonRowPlaceholder = [[NSNull alloc] init];
	self.predictions = [[NSMutableDictionary alloc] init];
	
	//SETUP TABLE VIEW
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 69, 320, 298)];
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	tableView.showsVerticalScrollIndicator = NO;
	tableView.delaysContentTouches = NO;
	[self.view addSubview:tableView];
	
	//SETUP TABLE HEADER/FOOTER
	//Table footer shadow
	UIImageView *tableFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table-footer-shadow.png"]];
	tableView.tableFooterView = tableFooter;
	
	UIImageView	*tableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table-header-shadow.png"]];
	tableView.tableHeaderView = tableHeader;
	
	self.tableHeaderHeight = tableHeader.frame.size.height;
	self.tableFooterHeight = tableFooter.frame.size.height;
	
	[tableFooter release];
	[tableHeader release];
	
	// Have the tableview ignore our 2 views when computing size
	tableView.contentInset = UIEdgeInsetsMake(-tableHeaderHeight, 0, -tableFooterHeight, 0);
	
	//SETUP STOP TITLE IMAGE VIEW
	stopTitleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 76)];
	[self.view addSubview:stopTitleImageView];
	
	//SETUP STOP TITLE LABEL
	stopTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 4, 304, 60)];
	stopTitleLabel.font = [UIFont boldSystemFontOfSize:22];
	stopTitleLabel.textAlignment = UITextAlignmentCenter;
	stopTitleLabel.numberOfLines = 2;
	stopTitleLabel.textColor = [UIColor whiteColor];
	stopTitleLabel.shadowColor = [UIColor colorWithWhite:0.5 alpha:0.5];
	stopTitleLabel.shadowOffset = CGSizeMake(-1, -1);
	stopTitleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
	[self.view addSubview:stopTitleLabel];
	
	[FlurryAnalytics logEvent:@"Stop Details - viewDidLoad" withParameters:[DataHelper dictionaryFromStop:stop]];
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	//setup notification observing for when a user taps on button row button (prev. stop, next stop, etc.)
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(goToPreviousStop:) name:@"goToPreviousStop" object:nil];
	[notificationCenter addObserver:self selector:@selector(goToNextStop:) name:@"goToNextStop" object:nil];
	[notificationCenter addObserver:self selector:@selector(loadLiveRoute:) name:@"loadLiveRoute" object:nil];
	
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(toggleRequestPredictionsTimer:) name:UIApplicationDidBecomeActiveNotification object:nil];
	
}

// Overriden by subclasses
- (void)setupInitialContents {

	//reset lastIndexPath because whenever you load a new contents array, all rows are retracted
	lastIndexPath = nil;

	//SETUP CONTENTS ARRAY
	contents = [[NSMutableArray alloc] init];
	
	//REMOVE ANY OLD PREDICTIONS
	[predictions removeAllObjects];
	
}

//fetch predictions once the view loads
- (void)viewDidAppear:(BOOL)animated {
	
	[super viewDidAppear:animated];
	
	errors = [[NSMutableArray alloc] init];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
	
	//fetch the first request for predictions
	[timer fire];	
	
}

//stop the automatic fetching of predictions once the view is gone
- (void)viewWillDisappear:(BOOL)animated {
	
	[super viewWillDisappear:animated];
	
	[timer invalidate];
	
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self];
	
}

//turns off the timer that fetches predictions when the app is locked, and turns it back on again when it unlocks
- (void)toggleRequestPredictionsTimer:(NSNotification *)note {
	
	if ([note.name isEqual:UIApplicationWillResignActiveNotification]) {
		
		NSLog(@"STOPDETAILS: Prediction Requests OFF"); /* DEBUG LOG */
		[timer invalidate];
	}
	else if ([note.name isEqual:UIApplicationDidBecomeActiveNotification]) {
		
		NSLog(@"STOPDETAILS: Prediction Requests ON"); /* DEBUG LOG */
		cellStatus = kCellStatusSpinner;
		[tableView reloadData];
		self.timer = [NSTimer scheduledTimerWithTimeInterval:20.0 target:self selector:@selector(requestPredictions) userInfo:nil repeats:YES];
		[timer fire];
	}
	
}

#pragma mark -
#pragma mark Navigation Buttons

- (void)goToPreviousStop:(NSNotification *)note {

	[FlurryAnalytics logEvent:@"Stop Details - Previous Stop" withParameters:[DataHelper dictionaryFromStop:stop]];

}
- (void)goToNextStop:(NSNotification *)note {
	
	[FlurryAnalytics logEvent:@"Stop Details - Next Stop" withParameters:[DataHelper dictionaryFromStop:stop]];

}

- (void)loadLiveRoute:(NSNotification *)note {
	
	ButtonBarCell *cell = (ButtonBarCell *)note.object;
	LiveRouteTVC *liveRouteTVC = [[LiveRouteTVC alloc] init];
	liveRouteTVC.direction = cell.direction;
	liveRouteTVC.startingStop = stop;
		
	[self.navigationController pushViewController:liveRouteTVC animated:YES];
	
	[liveRouteTVC release];
	
	
}

//called when the next/prev stop animation is done
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	
	[self enableUserInteraction];
	
}

- (void)enableUserInteraction {
	
	NSLog(@"enabledUserInteraction"); /* DEBUG LOG */
	self.view.userInteractionEnabled = YES;
	self.navigationController.navigationBar.userInteractionEnabled = YES;
}


#pragma mark -
#pragma mark Prediction Methods

- (void)requestPredictions {};
- (void)didReceivePredictions:(NSDictionary *)predictions {}


#pragma mark -
#pragma mark TableView Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	id object = [[contents objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
	
	if ([object isMemberOfClass:[Direction class]] || [object isMemberOfClass:[Destination class]]) {
		
		return kLineRowHeight;
		
	}
	else {
		return kButtonRowHeight;
	}
		
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return kRowDividerHeight;

}

//don't let button rows be selected
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	LineCell *cell = (LineCell *)[self.tableView cellForRowAtIndexPath:indexPath]; 
	LineCellView *lineCellView = [cell.contentView.subviews objectAtIndex:0];

	//only let users tap on rows when there are predictions
	if (lineCellView.cellStatus != kCellStatusDefault) {
		return nil;
	}
	
	int section = indexPath.section;
	int row = indexPath.row;
	
	id rowContents = [[contents objectAtIndex:section] objectAtIndex:row];
	
	if ([rowContents isMemberOfClass:[NSNull class]]){

		return nil;

	}
	
	return indexPath;
	
}

- (void)setupContentsBasedOnPredictions {}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[FlurryAnalytics logEvent:@"Stop Details - Row Tapped" withParameters:nil];
	
	int row = indexPath.row;
	int section = indexPath.section;
	
	//if you tapped on a row that is already activated, retract it's buttons...
	if ([indexPath compare: lastIndexPath] == NSOrderedSame) {
		NSLog(@"retract tapped");
		lastIndexPath = nil;
		
		int buttonRowIndex = [[self.contents objectAtIndex:section] indexOfObject:buttonRowPlaceholder];
		[[self.contents objectAtIndex:section] removeObjectAtIndex:buttonRowIndex];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:buttonRowIndex inSection:indexPath.section]] 
						 withRowAnimation: UITableViewRowAnimationFade];
		
	}
	else {
		//if you tap a retracted row, show its button
		if (lastIndexPath == nil){
			NSLog(@"show tapped");
			
			[[self.contents objectAtIndex:section] insertObject:buttonRowPlaceholder atIndex:row+1];
			
			NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:row+1 inSection:section];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation: UITableViewRowAnimationBottom];
			
			self.lastIndexPath = indexPath;	//retained so it stays in the ivar
			
			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section] 
							 atScrollPosition:UITableViewScrollPositionNone animated:YES];
			tableView.contentInset = UIEdgeInsetsMake(-tableHeaderHeight, 0, -tableFooterHeight, 0);
			
		}
		else {
			//otherwise retract the previously active row's buttons and show the current ones
			NSLog(@"retract previous and show tapped");
			
			//FIND THE LEG OBJECT THAT WAS TAPPED
			id object = [[contents objectAtIndex:section] objectAtIndex:row];
			
			//remove button bar placeholder from content array and record its indexpath
			NSIndexPath *buttonRowIndexPath = nil;
			
			for (NSMutableArray *sectionArray in contents) {
				
				if ([sectionArray containsObject:buttonRowPlaceholder]) {
									
					int sectionIndex = [contents indexOfObject:sectionArray];
					int rowIndex = [sectionArray indexOfObject:buttonRowPlaceholder];
					
					buttonRowIndexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
					[sectionArray removeObject:buttonRowPlaceholder];
				
					break;
				}
				
			}
									
			//determine the next index of the row that was tapped and add a button row placeholder there
			int indexToAdd = [[contents objectAtIndex:section] indexOfObject:object];
			[[contents objectAtIndex:section] insertObject:buttonRowPlaceholder atIndex:indexToAdd+1];
			
			[tableView beginUpdates];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:buttonRowIndexPath] 
							 withRowAnimation: UITableViewRowAnimationFade];
			
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexToAdd+1 inSection:section]] 
							 withRowAnimation: UITableViewRowAnimationFade];
			
			
			[tableView endUpdates];
			
			
			self.lastIndexPath = [NSIndexPath indexPathForRow:indexToAdd inSection:section];	//retained so it stays in the ivar
			
			tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
			[tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexToAdd+1 inSection:section] 
							 atScrollPosition:UITableViewScrollPositionNone animated:YES];
			tableView.contentInset = UIEdgeInsetsMake(-tableHeaderHeight, 0, -tableFooterHeight, 0);
		}
		
		
	}
	
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    return [contents count];
}


- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    return [[contents objectAtIndex:section] count];
}


// Overriden by subclasses
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}



- (void)dealloc {

	
	
	[errors release];
	[timer release];
	[predictions release];
	[buttonRowPlaceholder release];
    [contents release];
	[stop release];
	[stopTitleLabel release];
	[stopTitleImageView release];
	[tableView release];
	
	[super dealloc];
}


@end
