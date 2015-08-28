//
//  ViewController.m
//  loc
//
//  Created by saifing_87 on 15/8/10.
//  Copyright (c) 2015年 saifing_87. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <Accelerate/Accelerate.h>

#define K_UpdateInterval 0.001f
@interface ViewController ()
{
    CMAttitude *referenceAttitude;
    
    
}

@property (strong ,nonatomic) CMMotionManager *motionManager;

@property (nonatomic) double xV;
@property (nonatomic) double yV;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.motionManager = [[CMMotionManager alloc]init];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:imageView];
    
    ViewController * __weak weakSelf = self;
    __block double xPoint = 0.0000;
    __block double yPoint = 0.0000;
    __block int pointCount = 0;
    NSString *locPoint = @"0.000000,0.000000";
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [arr addObject:locPoint];
    if (self.motionManager.deviceMotionAvailable) {
        self.motionManager.deviceMotionUpdateInterval = K_UpdateInterval;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
//            NSLog(@"\nroll--->%f\npitch--->%f\nyaw--->%f",motion.attitude.roll,motion.attitude.pitch,motion.attitude.yaw);
            if (!referenceAttitude) {
                referenceAttitude = motion.attitude;
            }else{
                CMAttitude *attitude = motion.attitude;
                if (referenceAttitude != nil) {
                    [attitude multiplyByInverseOfAttitude:referenceAttitude];
                }
                CMRotationMatrix rotation = attitude.rotationMatrix;
//                NSLog(@"\n%f %f %f\n%f %f %f\n%f %f %f \n%f--%f--%f ",rotation.m11,rotation.m12,rotation.m13,rotation.m21,rotation.m22,rotation.m23,rotation.m31,rotation.m32,rotation.m33,motion.userAcceleration.x,motion.userAcceleration.y,motion.userAcceleration.z);
                
                double x = motion.userAcceleration.x *rotation.m11 +motion.userAcceleration.x *rotation.m21+motion.userAcceleration.x *rotation.m31;
                double y = motion.userAcceleration.y *rotation.m12 +motion.userAcceleration.y *rotation.m22+motion.userAcceleration.y *rotation.m32;
                NSLog(@"x_%f___y_%f",x,y);
//                NSLog(@"####%f_____%f",motion.userAcceleration.x,motion.userAcceleration.y);
                xPoint = xPoint + (weakSelf.xV*K_UpdateInterval) +((sqrt(x*x))*K_UpdateInterval*K_UpdateInterval)/2;
                yPoint = yPoint + (weakSelf.yV*K_UpdateInterval) +((sqrt(y*y))*K_UpdateInterval*K_UpdateInterval)/2;
                weakSelf.xV = x*K_UpdateInterval +weakSelf.xV;
                weakSelf.yV = y*K_UpdateInterval +weakSelf.yV;
                pointCount++;
                NSString *nowPoint = [NSString stringWithFormat:@"%f,%f",xPoint,yPoint];
                [arr addObject:nowPoint];

                double dis = sqrt(xPoint*xPoint + yPoint*yPoint);
                weakSelf.lbl.text = [NSString stringWithFormat:@"dis:%f",dis];
                
                for (int index = 0; index < arr.count; index++) {
                    if (index == 0) {
                        continue ;
                    }
                    NSArray *endPoint = [arr[index] componentsSeparatedByString:@","];
                    NSArray *startPoint = [arr[index - 1] componentsSeparatedByString:@","];
                    //下一点
                    CGPoint lineEndPoint = CGPointMake([endPoint[0] doubleValue]*100+[UIScreen mainScreen].bounds.size.width/2, [endPoint[1] doubleValue]*100+[UIScreen mainScreen].bounds.size.height/2);
//                    CGPoint lineStartPoint = CGPointMake([startPoint[0] doubleValue]*100+[UIScreen mainScreen].bounds.size.width/2, [startPoint[1] doubleValue]*100+[UIScreen mainScreen].bounds.size.height/2);
                    
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
