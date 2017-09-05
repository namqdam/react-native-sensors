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
    NSLog(@"Gyroscope");

    if (self) {
        self->_motionManager = [[CMMotionManager alloc] init];
        //Gyroscope
        if([self->_motionManager isGyroAvailable])
        {
            NSLog(@"Gyroscope available");
            /* Start the gyroscope if it is not active already */
            if([self->_motionManager isGyroActive] == NO)
            {
                NSLog(@"Gyroscope active");
            } else {
                NSLog(@"Gyroscope not active");
            }
        }
        else
        {
            NSLog(@"Gyroscope not Available!");
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
    double pitch = (180/M_PI) * self->_motionManager.deviceMotion.attitude.pitch;
    double roll = (180/M_PI) * self->_motionManager.deviceMotion.attitude.roll;
    double yaw = (180/M_PI) * self->_motionManager.deviceMotion.attitude.yaw;
    double timestamp = self->_motionManager.deviceMotion.timestamp;

    NSLog(@"getData: %f, %f, %f, %f", pitch, roll, yaw, timestamp);

    cb(@[[NSNull null], @{
             @"pitch" : [NSNumber numberWithDouble:pitch],
             @"roll" : [NSNumber numberWithDouble:roll],
             @"yaw" : [NSNumber numberWithDouble:yaw],
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
         CMAttitude *attitude;
         attitude = deviceMotion.attitude;

         float pitch =  (180/M_PI) * attitude.pitch;
         float roll = (180/M_PI) * attitude.roll;
         float yaw = (180/M_PI) * attitude.yaw;

         [self.bridge.eventDispatcher sendDeviceEventWithName:@"DeviceMotion" body:@{
                                                                                  @"pitch" : [NSNumber numberWithDouble:pitch],
                                                                                  @"roll" : [NSNumber numberWithDouble:roll],
                                                                                  @"yaw" : [NSNumber numberWithDouble:yaw]
                                                                                  }];
     }];

}

RCT_EXPORT_METHOD(stopUpdates) {
    NSLog(@"stopUpdates");
    [self->_motionManager stopDeviceMotionUpdates];
}

@end
