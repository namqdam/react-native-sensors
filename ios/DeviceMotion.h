//
//  DeviceMotion.h
//  Pods
//
//  Created by Nam Dam on 09/05/2017.
//
//

#import <React/RCTBridgeModule.h>
#import <CoreMotion/CoreMotion.h>

@interface DeviceMotion : NSObject <RCTBridgeModule> {
    CMMotionManager *_motionManager;
}

- (void) setUpdateInterval:(double) interval;
- (void) getUpdateInterval:(RCTResponseSenderBlock) cb;
- (void) getData:(RCTResponseSenderBlock) cb;
- (void) startUpdates;
- (void) stopUpdates;

@end
