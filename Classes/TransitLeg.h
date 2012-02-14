//
//  Leg.h
//  kronos
//
//  Created by Ljuba Miljkovic on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Direction.h"
#import "Stop.h"
#import "Route.h"
#import "Agency.h"
#import <CoreLocation/CoreLocation.h>


@interface TransitLeg : NSObject {

	Agency *agency;
	Route *route;
	
	// There are multiple directions for BART TransitLegs
	// but only one direction for NextBus TransitLegs
	// because multiple BART directions can run through
	// the Start/End stop of a leg
	NSMutableArray *directions;
	NSString *vehicleId;	
	
	Stop *startStop;
	Stop *endStop;
	
	NSDate *startDate;
	NSDate *endDate;
	
	NSTimeInterval timeToTransfer;
}

@property (nonatomic, retain) Agency *agency;
@property (nonatomic, retain) Route *route;
@property (nonatomic, retain) NSMutableArray *directions;
@property (nonatomic, retain) NSString *vehicleId;

@property (nonatomic, retain) Stop *startStop;
@property (nonatomic, retain) Stop *endStop;

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;

@property (nonatomic) NSTimeInterval timeToTransfer;

- (void)setBartTransitInfoWithDirectionTitle:(NSString *)dirTag destinationStopTag:(NSString *)destinationStopTag stopTitle:(NSString *)stopTitle;
- (void)setTransitInfoWithAgencyShortTitle:(NSString *)agencyShortTitle routeTag:(NSString *)routeTag directionTag:(NSString *)dirTag stopTag:(NSString *)stopTag vehicleId:(NSString *) vehicleId;
- (void)setEndStopWithTag:(NSString *)stopTag;


@end
