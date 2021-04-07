//
//  ViewController.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/22.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "ViewController.h"
#import "SpeedTestViewController.h"
#import <MobileSpeedLib/MobileSpeedLib.h>

@interface ViewController ()

@property (copy, nonatomic) NSString *intranetIP;
@property (strong, nonatomic) SpeedUpUtils *speedUpUtils;
@property (strong, nonatomic) SpeedUpAreaInfoModel *areaInfoModel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initSpeedUpUtils];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WeakSelf;
    [[TestUtils getSharedInstance] getDeviceInfo:^(DeviceInfoModel *_Nullable infoModel) {
        NSLog(@"%@", infoModel);
//        weakSelf.areaInfoModel = model;
        weakSelf.osVerLabel.text = [NSString stringWithFormat:@"iOS版本：%@", infoModel.osVer];
        weakSelf.phoneModelLabel.text = [NSString stringWithFormat:@"手机型号：%@", infoModel.phoneModel];
        weakSelf.mobileNetworkStandardLabel.text = [NSString stringWithFormat:@"移动网络：%@", infoModel.mobileNetworkStandard];
        weakSelf.imeiLabel.text = [NSString stringWithFormat:@"UUID：%@", infoModel.uuid];
        weakSelf.extranetIPLabel.text = [NSString stringWithFormat:@"外网IP：%@", infoModel.publicIP];
        weakSelf.intranetIP = infoModel.intranetIP;
        weakSelf.intranetIPLabel.text = [NSString stringWithFormat:@"内网IP：%@", infoModel.intranetIP];
//        weakSelf.locationLabel.text = [NSString stringWithFormat:@"当前位置：%@",  infoModel.location];
//        weakSelf.latitudeLabel.text = [NSString stringWithFormat:@"经度：%@", infoModel.latitude];
//        weakSelf.longitudeLabel.text = [NSString stringWithFormat:@"纬度：%@", infoModel.longitude];
    }];
}

- (void)initSpeedUpUtils {
    NSString *correlationId = [MSLTools loadStringFromUserDefaults:SP_KEY_CORRELATION_ID];
    if (correlationId && correlationId.length > 1) {
        [self.speedUpButton setTitle:@"停止加速" forState:UIControlStateNormal];
    }
}

- (IBAction)gotoTestAction:(id)sender {
    SpeedTestViewController *speedTestVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SpeedTest"];
    speedTestVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:speedTestVC animated:YES completion:^{
    }];
}

- (IBAction)speedUpAction:(id)sender {
    DeviceInfoModel *infoModel = [DeviceInfoModel shared];
    if (infoModel) {
        WeakSelf;
        NSString *correlationId = [MSLTools loadStringFromUserDefaults:SP_KEY_CORRELATION_ID];
        if (correlationId && correlationId.length > 1) {
            // 取消加速
            [[TestUtils getSharedInstance] cancalSpeedUp:correlationId
                                               partnerId:@"huiyibao"
                                              intranetIp:infoModel.intranetIP
                                                publicIp:infoModel.publicIP
                                                areaCode:infoModel.areaInfo.code
                                                  mobile:@"13811111111"
                                                     res:^(SpeedUpCancelTecentGamesQoSModel *_Nonnull qoModel) {
                                                    NSLog(@"%@", qoModel);
                                                    if (qoModel && ([qoModel.ResultCode integerValue] == 0 || [qoModel.ResultCode integerValue] == 201)) {
                                                        [weakSelf.speedUpButton setTitle:@"一键加速" forState:UIControlStateNormal];
                                                    }

                                                    if (qoModel && qoModel.ResultMessage) {
                                                        [MSLTools showPrompt:qoModel.ResultMessage superView:weakSelf.view numberOfLines:0 afterDelay:3.0];
                                                    }
                                                }];
        } else {
            [[TestUtils getSharedInstance] speedUp:@"huiyibao"
                                         serviceId:@"Games100K"
                                     destAddresses:@[infoModel.publicIP]
                                     qosSreamSpeed:[[QosSreamSpeed alloc] init]
                                        intranetIp:infoModel.intranetIP
                                          publicIp:infoModel.publicIP
                                             ispId:infoModel.areaInfo.ispId
                                          areaCode:infoModel.areaInfo.code
                                            mobile:@"13811111111"
                                               res:^(SpeedUpApplyTecentGamesQoSModel *_Nonnull qoModel) {
                                                   NSLog(@"%@", qoModel);
                                                   if (qoModel && ([qoModel.ResultCode integerValue] == 0 || [qoModel.ResultCode integerValue] == 203)) {
                                                       [weakSelf.speedUpButton setTitle:@"取消加速" forState:UIControlStateNormal];
                                                   }

                                                   if (qoModel && qoModel.ResultMessage) {
                                                       [MSLTools showPrompt:qoModel.ResultMessage superView:weakSelf.view numberOfLines:0 afterDelay:3.0];
                                                   }
                                               }];
        }
    } else {
        [MSLTools showPrompt:@"无法获取区域信息" superView:self.view numberOfLines:1 afterDelay:3.0];
    }
}

@end
