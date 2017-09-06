//
//  DeviceMotion.m
//  Pods
//
//  Created by Nam Dam on 09/05/2017.
//
//

#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "DeviceMotion.h"

@implementation DeviceMotion

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"DeviceMotion");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
        //DeviceMotion
        if([self->_motionManager isDeviceMotionAvailable])
        {
            NSLog(@"DeviceMotion available");
            /* Start the devicemotion if it is not active already */
            if([self->_motionManager isDeviceMotionActive] == NO)
            {
                NSLog(@"DeviceMotion active");
            } else {
                NSLog(@"DeviceMotion not active");
            }
        }
        else
        {
            NSLog(@"DeviceMotion not Available!");
        }
    }
    return self;
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    NSLog(@"setUpdateInterval: %f", interval);
    double intervalInSeconds = interval / 1000;

    [self->_motionManager setDeviceMotionUpdateInterval:intervalInSeconds];
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    double interval = self->_motionManager.deviceMotionUpdateInterval;
    NSLog(@"getUpdateInterval: %f", interval);
    cb(@[[NSNull null], [NSNumber numberWithDouble:interval]]);
}

RCT_EXPORT_METHOD(getData:(RCTResponseSenderBlock) cb) {
    CMAcceleration gravity = self->_motionManager.deviceMotion.gravity;
    float rotation = (180 / M_PI) * atan2(gravity.x, gravity.y);
    if (rotation < 0) {
        rotation = rotation + 180;
    } else {
        rotation = rotation - 180;
    }
    double timestamp = self->_motionManager.deviceMotion.timestamp;

    NSLog(@"getData: %f, %f", rotation, timestamp);

    cb(@[[NSNull null], @{
             @"rotation" : [NSNumber numberWithDouble:rotation],
             @"timestamp" : [NSNumber numberWithDouble:timestamp]
             }]
       );
}

RCT_EXPORT_METHOD(startUpdates) {
    NSLog(@"startUpdates");
    [self->_motionManager startDeviceMotionUpdates];

    /* Receive the devicemotion data on this block */
    [self->_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                               withHandler:^(CMDeviceMotion *deviceMotion, NSError *error)
     {
         CMAcceleration gravity = deviceMotion.gravity;
         float rotation = (180 / M_PI) * atan2(gravity.x, gravity.y);
         if (rotation < 0) {
             rotation = rotation + 180;
         } else {
             rotation = rotation - 180;
         }

         double timestamp = deviceMotion.timestamp;
         [self.bridge.eventDispatcher sendDeviceEventWithName:@"DeviceMotion" body:@{
                                                                                  @"rotation" : [NSNumber numberWithDouble:rotation], @"timestamp" : [NSNumber numberWithDouble:timestamp]}];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    NSLog(@"stopUpdates");
    [self->_motionManager stopDeviceMotionUpdates];
}

@end
