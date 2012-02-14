//
//  PredictionRequest.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Route.h"

@interface PredictionRequest : NSObject {

	//bart prediciton requests only require stopTag and agencyShortTitle. All other variables are irrelevant.
	
	
	NSString *stopTag;
	NSString *agencyShortTitle;
	Route *route;
	BOOL isMainRoute;		//indicates whether this route is the one navigated to in the Lines section of the app
	
}

@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSString *stopTag;
@property (nonatomic, retain) NSString *agencyShortTitle;
@property BOOL isMainRoute;


@end
