//
//  ViewController.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/22.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *osVerLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneModelLabel;
//@property (weak, nonatomic) IBOutlet UILabel *networkTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mobileNetworkStandardLabel;
@property (weak, nonatomic) IBOutlet UILabel *imeiLabel;
@property (weak, nonatomic) IBOutlet UILabel *imsiLabel;
@property (weak, nonatomic) IBOutlet UILabel *extranetIPLabel;
@property (weak, nonatomic) IBOutlet UILabel *intranetIPLabel;

@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIButton *speedUpButton;

@end

