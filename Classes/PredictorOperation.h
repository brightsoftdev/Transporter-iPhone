//
//  Predictor.h
//  Fetches Predictions from BART and NEXTBUS
//
//  Created by Ljuba Miljkovic on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prediction.h"
#import "PredictionsManager.h"

@interface PredictorOperation : NSOperation {

	NSArray *requests;
	PredictionsManager *predictionsManager;
	NSString *agencyShortTitle;
	
}

@property (nonatomic, retain) NSArray *requests;
@property (nonatomic, retain) PredictionsManager *predictionsManager;
@property (nonatomic, retain) NSString *agencyShortTitle;

- (id)initWithAgencyShortTitle:(NSString *)_agencyShortTitle requests:(NSArray *)_requests recipient:(id)_recipient;

- (NSDictionary *)fetchNextBusPredictions;
- (NSDictionary *)fetchBARTPredictions;

@end
