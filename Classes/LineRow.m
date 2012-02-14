//
//  LineRow.m
//  kronos
//
//  Created by Ljuba Miljkovic on 4/18/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LineRow.h"

#import "Constants.h"

@implementation LineRow

@synthesize isBARTRow, backgroundImage, minorTitle, majorTitle, arrivals, rowHeight, lightColor, darkColor, colorsView;
@synthesize prediction1Label, prediction2Label, prediction3Label, spinner;

//range has two values: location and length. length if the number of lines for this stop. location is the position of this line row.
- (id)initWithLineItem:(NSDictionary *)lineItem withColors:(NSArray *)colors inRange:(NSRange)range {
	
	if (self = [super init]) {

		if (colors != nil) {
			isBARTRow = YES;
		}
		else {
			isBARTRow = NO;
		}
				
		arrivals = [[NSArray alloc] init];
		
		int rowIndex = range.location;
		int numberOfRows = range.length;
		
		//SETUP BACKGROUND IMAGE
		BOOL isLastRow = (rowIndex == numberOfRows-1);
		
		self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		
		if (isLastRow) {
			backgroundImage = [[UIImage imageNamed:@"fav-last-line-background.png"] retain];
		}
		else {
			backgroundImage = [[UIImage imageNamed:@"fav-line-background.png"] retain];
		}

		rowHeight = [UIImage imageNamed:@"fav-line-background.png"].size.height;
		
		//SET ROW POSITION
		int frameY = 35 + (rowIndex * rowHeight);
		
		//create the appropriate frame given the index of the line row
		CGRect frame = CGRectMake(0, frameY, backgroundImage.size.width, backgroundImage.size.height);
		
		self.frame = frame;
		
		//SETUP ROW CONTENTS		
		if (isBARTRow) {
			
			majorTitle = [[NSString alloc] initWithString:[lineItem objectForKey:@"destinationStopTitle"]];
			minorTitle = [[NSString alloc] initWithString:@""];
			
			colorsView = [[BartColorsView alloc] initWithColors:colors atPoint:CGPointMake(19, 24)];
   		    [self addSubview:colorsView];
			
			
		}
		else {
			
			NSString *routeTag = [lineItem objectForKey:@"routeTag"];
			NSString *lineName = [lineItem objectForKey:@"name"];
			NSString *lineTitle = [lineItem objectForKey:@"title"];
			
			majorTitle = [[NSString alloc] initWithFormat:@"%@ %@", routeTag, lineName];
			minorTitle = [[NSString alloc] initWithFormat:@"→ %@", lineTitle];
			
			colorsView = [[BartColorsView alloc] init];
			
		}
		
		//SETUP PREDICTION LABELS
		
		prediction1Label = [[PredictionLabel alloc] initWithFrame: CGRectMake(243, 0, 43, rowHeight-2)];
		prediction1Label.textAlignment = UITextAlignmentCenter;
		prediction1Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction1Label.font = [UIFont boldSystemFontOfSize:24];
		prediction1Label.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
		//prediction1Label.text = @"86";
		
		prediction2Label = [[PredictionLabel alloc] initWithFrame: CGRectMake(288, 1, 21, 19)];
		prediction2Label.textAlignment = UITextAlignmentCenter;
		prediction2Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction2Label.font = [UIFont systemFontOfSize:12];
		prediction2Label.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
		//prediction2Label.text = @"87";
		
		prediction3Label = [[PredictionLabel alloc] initWithFrame: CGRectMake(288, 22, 21, 19)];
		prediction3Label.textAlignment = UITextAlignmentCenter;
		prediction3Label.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
		prediction3Label.font = [UIFont systemFontOfSize:12];
		prediction3Label.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
		//prediction3Label.text = @"88";
		
		[self addSubview:prediction1Label];
		[self addSubview:prediction2Label];
		[self addSubview:prediction3Label];
		
		spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		spinner.center = prediction1Label.center;
		spinner.hidden = YES;
		
		[self addSubview:spinner];
		
	}
	
    return self;

}

- (int)cellStatus {
	
	return cellStatus;
}

- (void)setCellStatus:(int)status {
	
	cellStatus = status;
	
	//show spinner if the status is set to it
	if (cellStatus == kCellStatusSpinner) {
		
		//NSLog(@"%@", @"spinner ON"); /* DEBUG LOG */
		
		spinner.hidden = NO;
		[spinner startAnimating];
		
		return;
	}
	else {
		//remove spinner		
		
		//NSLog(@"%@", @"spinner OFF");
		[spinner stopAnimating];
		spinner.hidden = YES;
		
	}
	
	if (cellStatus == kCellStatusPredictionFail) {
		
		lightColor = [[UIColor alloc] initWithWhite:0.55 alpha:1.0];
		darkColor = lightColor;
		
		colorsView.alpha = 0.5;
		
	}
	else {
		
		lightColor = [[UIColor alloc] initWithWhite:0.3 alpha:1.0];
		darkColor = [[UIColor alloc] initWithWhite:0.1 alpha:1.0];
		
		colorsView.alpha = 1.0;
	}

}

- (void)setArrivals:(NSArray *)_arrivals {
	
	arrivals = [_arrivals retain];

	BOOL isBART = NO;
	
	int numberOfArrivals = [arrivals count];
	
	//determine if this is a bart arrival
	if (numberOfArrivals > 0) {
		
		if ([[arrivals objectAtIndex:0] objectForKey:@"platform"]){		
			isBART = YES;
		}
	}
			
	switch (numberOfArrivals) {
		case 0:
			if (cellStatus == kCellStatusInternetFail) {
				prediction1Label.text = @"";
			}
			else {
				prediction1Label.text = @"—";
				prediction1Label.alpha = 0.45;
			}
			break;
		case 1:
			if (isBART) {
				[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
			}
			else {
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
			}
			prediction2Label.text = @"-";
			prediction3Label.text = @"-";
			//majorLabel.alpha = 1.0;
			//minorLabel.alpha = 1.0;
			prediction1Label.alpha = 1.0;
			break;
		case 2:
			if (isBART) {
				[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
				[prediction2Label setBartTime:[[arrivals objectAtIndex:1] valueForKey:@"minutes"]];
			}
			else {
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
				[prediction2Label setEpochTime:[[arrivals objectAtIndex:1] valueForKey:@"epochTime"]];
			}	
			prediction3Label.text = @"-";
			//majorLabel.alpha = 1.0;
			//minorLabel.alpha = 1.0;
			prediction1Label.alpha = 1.0;
			
			break;
		default:
			if (isBART) {
				[prediction1Label setBartTime:[[arrivals objectAtIndex:0] valueForKey:@"minutes"]];
				[prediction2Label setBartTime:[[arrivals objectAtIndex:1] valueForKey:@"minutes"]];
				[prediction3Label setBartTime:[[arrivals objectAtIndex:2] valueForKey:@"minutes"]];
				
			}
			else {
				[prediction1Label setEpochTime:[[arrivals objectAtIndex:0] valueForKey:@"epochTime"]];
				[prediction2Label setEpochTime:[[arrivals objectAtIndex:1] valueForKey:@"epochTime"]];
				[prediction3Label setEpochTime:[[arrivals objectAtIndex:2] valueForKey:@"epochTime"]];
			}
			//majorLabel.alpha = 1.0;
			//minorLabel.alpha = 1.0;
			prediction1Label.alpha = 1.0;

			
			break;
	}	
	

}



- (void)drawRect:(CGRect)rect {
	
    [backgroundImage drawAtPoint:CGPointZero];
	
	CGRect majorLabelRect = CGRectMake(19, 3, 160, 21);
	UIFont *font = [UIFont boldSystemFontOfSize:18];
	[darkColor set];
	[majorTitle drawInRect:majorLabelRect withFont:font];

	if (isBARTRow) {
		
		//add number of cars

	}
	
	else {
		
		//add direction title
		CGRect minorLabelRect = CGRectMake(19, 23, 220, 21);
		font = [UIFont systemFontOfSize:13];
		[lightColor set];
		[minorTitle drawInRect:minorLabelRect withFont:font];
		
	}

	
}



- (void)dealloc {

	[colorsView release];
    [majorTitle release];
	[minorTitle release];
	[spinner release];
	[prediction1Label release];
	[prediction2Label release];
	[prediction3Label release];
	[backgroundImage release];
	
	[super dealloc];
}


@end
