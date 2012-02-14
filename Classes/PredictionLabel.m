//
//  PredictionLabel.m
//  kronos
//
//  Created by Ljuba Miljkovic on 3/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PredictionLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "LineCellView.h"
#import "Constants.h"

@implementation PredictionLabel

@synthesize timer, arrivalTime, imminentArrivalMarker, isMarkerAnimating;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		//SETUP IMMINENT MARKER 
		imminentArrivalMarker = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-marker.png"]];
		imminentArrivalMarker.contentMode = UIViewContentModeScaleAspectFit;
		imminentArrivalMarker.hidden = YES;
		self.isMarkerAnimating = NO;
		
		int markerCenterX = floor(self.bounds.size.width/2);
		int markerCenterY = floor(self.bounds.size.height/2);
		int markerHeight = floor(self.bounds.size.height * 0.6);
		
		imminentArrivalMarker.bounds = CGRectMake(0,0,imminentArrivalMarker.frame.size.width, markerHeight);
		imminentArrivalMarker.center = CGPointMake(markerCenterX,markerCenterY);

		[self addSubview:imminentArrivalMarker];
		
	}
	
    return self;
}


- (void)setIsFirstArrival:(BOOL)first {
		
	isFirstArrival = first;
		
	if (isFirstArrival) {
		
		int markerCenterX = floor(self.bounds.size.width/2);
		int markerCenterY = floor(self.bounds.size.height/2) + 5;
		imminentArrivalMarker.center = CGPointMake(markerCenterX,markerCenterY);
	}

}

- (BOOL)isFirstArrival {
	
	return isFirstArrival;
}

//sets the actual time the bus will arrive
- (void)setEpochTime:(NSString *)time {
	
	//received epochTime is in miliseconds
	self.arrivalTime = [[NSDate dateWithTimeIntervalSince1970:([time doubleValue]/1000)] retain];
	
	//determine number of minutes-from-now label
	NSTimeInterval timeFromNow = [arrivalTime timeIntervalSinceNow];
	
	//if bus is less then 1 minute away
	if (timeFromNow < 60) {
		
		if (!isMarkerAnimating) {
			self.text = nil;
			imminentArrivalMarker.hidden = NO;
			isMarkerAnimating = YES;
			[self startAnimation];
		}
		
		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalYES" object:self.superview]];
		}
	}
	else {
		imminentArrivalMarker.hidden = YES;
		isMarkerAnimating = NO;
		[imminentArrivalMarker.layer removeAllAnimations];
		
		int minutes = (int)floor(timeFromNow/60);
		self.text = [NSString stringWithFormat:@"%d", minutes];
		 
		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalNO" object:self.superview]];
		}
		
	}	
}	

//called whenever you want to clear the prediction label
- (void)clear {
	
	self.text = nil;
	imminentArrivalMarker.hidden = YES;
	isMarkerAnimating = NO;
	
}

- (void)setBartTime:(NSString *)bartTime {
	
	self.arrivalTime = nil;		//dummy object so it can be released in dealloc
	
	if ([bartTime isEqual:@"Leaving"]) {
		self.text = nil;
		
		if (!isMarkerAnimating) {
			imminentArrivalMarker.hidden = NO;
			isMarkerAnimating = YES;
			[self startAnimation];
		}

		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalYES" object:self.superview]];
		}
		
	}
	else {
		imminentArrivalMarker.hidden = YES;
		isMarkerAnimating = NO;
		[imminentArrivalMarker.layer removeAllAnimations];
		self.text = bartTime;
		
		if (isFirstArrival) {
			NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
			[nc postNotification:[NSNotification notificationWithName:@"imminentArrivalNO" object:self.superview]];
		}	
	}
}

- (void)startAnimation {
	
	CABasicAnimation *theAnimation;
			
	theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
	theAnimation.duration=1.0;
	theAnimation.repeatCount=200;
	theAnimation.autoreverses=YES;
	theAnimation.fromValue=[NSNumber numberWithFloat:0.3];
	theAnimation.toValue=[NSNumber numberWithFloat:1.0];
	theAnimation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	[imminentArrivalMarker.layer addAnimation:theAnimation forKey:@"animateOpacity"];
}


- (void)dealloc {

    [arrivalTime release];
	[imminentArrivalMarker release];
	
	[super dealloc];
}


@end
