//
//  SpeedTestViewController.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Charts-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpeedTestViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *pingTestResultView;
//@property (weak, nonatomic) IBOutlet UIView *httpTestResultView;
//@property (weak, nonatomic) IBOutlet UIView *udpTestResultView;
@property (weak, nonatomic) IBOutlet UIView *traceTestResultView;
@property (weak, nonatomic) IBOutlet UIView *lineResultView;

@property (weak, nonatomic) IBOutlet UITextView *resultTextView;
@property (weak, nonatomic) IBOutlet UITextView *traceResultTextView;

@property (weak, nonatomic) IBOutlet UITextField *ipTextField;
@property (weak, nonatomic) IBOutlet UITextField *portTextField;
@property (weak, nonatomic) IBOutlet UITextField *timeTextField;

@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ativityIndicatorView;

@property (weak, nonatomic) IBOutlet UIButton *pingButton;
@property (weak, nonatomic) IBOutlet UIButton *httpButton;
@property (weak, nonatomic) IBOutlet UIButton *udpButton;
@property (weak, nonatomic) IBOutlet UIButton *traceButton;

//@property (weak, nonatomic) IBOutlet BarChartView *chartView;

//@property (weak, nonatomic) IBOutlet UILabel *osVerLabel;

@end

NS_ASSUME_NONNULL_END
