//
//  SpeedTestViewController.m
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/23.
//  Copyright © 2020 邹程. All rights reserved.
//

#import "SpeedTestViewController.h"
#import "Marco.h"
#import "Tools.h"
#import "TestUtils.h"
#import "SpeedUpUtils.h"
#import "Traceroute.h"
#import "NSString+Extension.h"

@interface SpeedTestViewController () <ChartViewDelegate>

@property (strong, nonatomic) UIColor *enabledColor;
@property (strong, nonatomic) UIColor *disabledColor;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *verticalSeparateArray;
@property (strong, nonatomic) NSMutableArray *resultTextArray;

@property (strong, nonatomic) SpeedUpUtils *speedUpUtils;
@property (strong, nonatomic) PNTcpPing *tcpPing;
@property (strong, nonatomic) PNUdpTraceroute *pnUdpTraceroute;
@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) Traceroute *traceroute;

@property (assign, nonatomic) BOOL pingTesting;
@property (assign, nonatomic) BOOL httpTesting;
@property (assign, nonatomic) BOOL udpTesting;
@property (assign, nonatomic) BOOL traceTesting;

@end

@implementation SpeedTestViewController

- (void)dealloc {
    NSLog(@"\n SpeedTestViewController delloc \n");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    [self initSpeedUpUtils];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_timer invalidate];
    _timer = nil;
}

- (void)initUI {
    self.enabledColor = [UIColor colorWithRed:16 / 255.0 green:171 / 255.0 blue:226 / 255.0 alpha:1.0];
    self.disabledColor = [UIColor colorWithRed:198 / 255.0 green:198 / 255.0 blue:200 / 255.0 alpha:1.0];

    _ipTextField.text = defaultIp;
    _portTextField.text = defaultPort;

    _verticalSeparateArray = [[NSMutableArray alloc] init];

    _chartView.delegate = self;
    _chartView.noDataText = @"暂无测试数据";
    _chartView.noDataFont = [UIFont systemFontOfSize:14];
    _chartView.noDataTextColor = [UIColor systemGrayColor];
    _chartView.drawBarShadowEnabled = NO;
    _chartView.drawValueAboveBarEnabled = YES;
    _chartView.maxVisibleCount = 2000;

    [self buttonTitleChange];
    [self setChartData];
}

- (BOOL)ipCheck {
    NSString *str = _ipTextField.text;
    if (str && str.length > 0) {
//        NSString *pattern1 = @"^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$";
//        BOOL match1 = [str match:pattern1];
//
//        NSString *pattern2 = @"^[^\\s]+\\.[^\\s]*$";
//        BOOL match2 = [str match:pattern2];
//        if (match1 || match2) {
//            return YES;
//        } else {
//            [Tools showPrompt:@"网址或者IP格式错误" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
//        }
        return [self portCheck];
    } else {
        [Tools showPrompt:@"请输入网址或者IP地址" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
    }
    return NO;
}

- (BOOL)portCheck {
    NSString *str = _portTextField.text;
    if (str && str.length > 0) {
        NSString *pattern = @"^\\d{1,6}$";
        BOOL match = [str match:pattern];

        if (match) {
            return [self timeCheck];
        } else {
            [Tools showPrompt:@"请输入正确的端口号" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
        }
    } else {
        [Tools showPrompt:@"请输入正确的端口号" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
    }
    return NO;
}

- (BOOL)timeCheck {
    NSString *str = _timeTextField.text;
    if (str && str.length > 0) {
        NSInteger time = [str integerValue];
        if (time && time > 0) {
            return YES;
        } else {
            [Tools showPrompt:@"请输入正确的测试秒数" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
        }
    } else {
        [Tools showPrompt:@"请输入正确的测试秒数" superView:self.view numberOfLines:1 afterDelay:3.0 completion:nil];
    }
    return NO;
}

- (void)initTestStartText:(UITextView *)textView {
    NSDateFormatter *dateStringFormatter = [[NSDateFormatter alloc] init];
    [dateStringFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *currentDate = [NSDate date];
    NSString *text1 = [NSString stringWithFormat:@"测试启动时间：%@\n", [dateStringFormatter stringFromDate:currentDate]];
    NSString *text2 = @"正在测试中，请稍等...";
    textView.text = [NSString stringWithFormat:@"%@%@", text1, text2];
}

- (void)initSpeedUpUtils {
    _speedUpUtils = [[SpeedUpUtils alloc] init];
}

- (void)formatTcpPingResultText:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.resultTextArray.count > 0) {
            NSString *text = self.resultTextArray[self.resultTextArray.count - 1];
            if (text && text.length > 0) {
                if ([text containsString:@"connect failed"] || [text containsString:@"DNS error"]) {
                    textView.text = @"测试失败，网络连接错误！";
                } else {
                    NSArray *pingTextArray = [text componentsSeparatedByString:@"TCP conn "];
                    if (pingTextArray && pingTextArray.count >= 2) {
                        NSArray *resultArray = [pingTextArray[1] componentsSeparatedByString:@",  min/avg/max = "];
                        if (resultArray && resultArray.count >= 2) {
                            NSString *loss = [resultArray[0] stringByReplacingOccurrencesOfString:@"loss=" withString:@""];
                            NSArray *countArray = [resultArray[1] componentsSeparatedByString:@"/"];
                            if (countArray && countArray.count >= 3) {
                                NSString *min = countArray[0];
                                NSString *avg = countArray[1];
                                NSString *max = [countArray[2] stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                                //最大值
                                double maxTime = [max doubleValue];

                                //最小值
                                double minTime = [min doubleValue];

                                NSString *text1 = [NSString stringWithFormat:@"发包数：%lu\n", (unsigned long)self.resultTextArray.count];
                                NSString *text2 = [NSString stringWithFormat:@"平均时延：%@ms\n", avg];
                                NSString *text3 = [NSString stringWithFormat:@"最高时延：%.3fms\n", maxTime];
                                NSString *text4 = [NSString stringWithFormat:@"最低时延：%.3fms\n", minTime];
                                NSString *text5 = [NSString stringWithFormat:@"丢包次数：%@\n", loss];
                                NSString *text6 = [NSString stringWithFormat:@"丢包率：%.f%%\n", ([loss doubleValue] / self.resultTextArray.count * 100)];

                                textView.text = [NSString stringWithFormat:@"%@%@%@%@%@%@", text1, text2, text3, text4, text5, text6];
                            }
                        }
                    }
                }
            }
        } else {
            textView.text = @"测试失败，网络连接错误！";
        }
        [self enabledAllButton];
    });
}

- (void)formatResultText:(UITextView *)textView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.resultTextArray && self.resultTextArray.count > 0) {
            NSMutableArray *lossPacketArray = [NSMutableArray arrayWithCapacity:0];
            NSMutableArray *timeArray = [NSMutableArray arrayWithCapacity:0];

            for (NSString *pingText in self.resultTextArray) {
                if ([pingText containsString:@"0 bytes form"]) {
                    [lossPacketArray addObject:pingText];
                } else if ([pingText containsString:@"packets transmitted"] == NO) {
                    NSArray *tempArray = [pingText componentsSeparatedByString:@"time="];
                    if (tempArray) {
                        NSString *tempTime = tempArray.lastObject;
                        if (tempTime) {
                            NSString *time = [tempTime stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                            if (time) {
                                [timeArray addObject:time];
                            }
                        }
                    }
                }
            }

            //最大值
            double maxTime = [[timeArray valueForKeyPath:@"@max.doubleValue"] doubleValue];

            //最小值
            double minTime = [[timeArray valueForKeyPath:@"@min.doubleValue"] doubleValue];

            NSString *finalPingText = self.resultTextArray.lastObject;
            if (finalPingText) {
                NSArray *finalPingTextArray = [finalPingText componentsSeparatedByString:@" , "];
                if (finalPingTextArray && finalPingTextArray.count == 4) {
                    NSString *packets = [finalPingTextArray[0] stringByReplacingOccurrencesOfString:@" packets transmitted" withString:@""];
                    NSString *delay = [finalPingTextArray[2] stringByReplacingOccurrencesOfString:@"delay:" withString:@""];
                    NSString *loss = [finalPingTextArray[1] stringByReplacingOccurrencesOfString:@"loss:" withString:@""];
                    NSString *text1 = [NSString stringWithFormat:@"发包数：%@\n", packets];
                    NSString *text2 = [NSString stringWithFormat:@"平均时延：%@\n", delay];
                    NSString *text3 = [NSString stringWithFormat:@"最高时延：%.3fms\n", maxTime];
                    NSString *text4 = [NSString stringWithFormat:@"最低时延：%.3fms\n", minTime];
                    NSString *text5 = [NSString stringWithFormat:@"丢包次数：%lu\n", (unsigned long)lossPacketArray.count];
                    NSString *text6 = [NSString stringWithFormat:@"丢包率：%@%%\n", loss];

                    textView.text = [NSString stringWithFormat:@"%@%@%@%@%@%@", text1, text2, text3, text4, text5, text6];
                }
            }
        }
        [self enabledAllButton];
    });
}

- (void)setChartData {
    dispatch_async(dispatch_get_main_queue(), ^{
        BarChartDataSet *set1 = nil;
        if (self.chartView.data.dataSetCount > 0) {
            set1 = (BarChartDataSet *)self.chartView.data.dataSets[0];
            set1.drawIconsEnabled = NO;
            set1.highlightEnabled = YES;
            [set1 replaceEntries:self.verticalSeparateArray];
            [self.chartView.data notifyDataChanged];
            [self.chartView notifyDataSetChanged];
        } else {
            set1 = [[BarChartDataSet alloc] initWithEntries:self.verticalSeparateArray label:@""];
//            [set1 setColors:ChartColorTemplates.pastel];
            set1.drawIconsEnabled = NO;
            set1.highlightEnabled = YES;

            NSMutableArray *dataSets = [[NSMutableArray alloc] init];
            [dataSets addObject:set1];

            BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
            [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];

            self.chartView.data = data;
        }
    });
}

- (void)buttonTitleChange {
    [_pingButton setTitle:_pingTesting ? @"stop" : @"ping" forState:UIControlStateNormal];
    [_httpButton setTitle:_httpTesting ? @"stop" : @"http" forState:UIControlStateNormal];
    [_udpButton setTitle:_udpTesting ? @"stop" : @"udp" forState:UIControlStateNormal];
    [_traceButton setTitle:_traceTesting ? @"stop" : @"trace" forState:UIControlStateNormal];
    [_ipTextField resignFirstResponder];
    [_portTextField resignFirstResponder];
    [_timeTextField resignFirstResponder];
}

- (void)buttonStateEnabled:(UIButton *)btn {
    [btn setEnabled:YES];
    [btn setBackgroundColor:self.enabledColor];
}

- (void)buttonStateDisabled:(UIButton *)btn {
    [btn setEnabled:NO];
    [btn setBackgroundColor:self.disabledColor];
    if (_ativityIndicatorView.isHidden) {
        [_ativityIndicatorView setHidden:NO];
        [_ativityIndicatorView startAnimating];
    }
}

- (void)enabledAllButton {
    [self buttonTitleChange];
    [self buttonStateEnabled:self.pingButton];
    [self buttonStateEnabled:self.httpButton];
    [self buttonStateEnabled:self.udpButton];
    [self buttonStateEnabled:self.traceButton];
    [_ativityIndicatorView setHidden:YES];
    [_ativityIndicatorView stopAnimating];
}

- (void)disabedAllButton {
    [self buttonTitleChange];
    [self buttonStateDisabled:self.pingButton];
    [self buttonStateDisabled:self.httpButton];
    [self buttonStateDisabled:self.udpButton];
    [self buttonStateDisabled:self.traceButton];
}

- (void)resetLineChartView {
    [_verticalSeparateArray removeAllObjects];
}

- (IBAction)pingAction:(id)sender {
    if (_pingTesting) {
        _pingTesting = NO;
        [_tcpPing stopTcpPing];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:NO];
        [_timer invalidate];
        [self formatTcpPingResultText:_resultTextView];
        [self enabledAllButton];
    } else if ([self ipCheck]) {
        _pingTesting = YES;
        [self buttonTitleChange];
        [self buttonStateDisabled:self.httpButton];
        [self buttonStateDisabled:self.udpButton];
        [self buttonStateDisabled:self.traceButton];
        [self resetLineChartView];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:NO];
        [_pingTestResultView setHidden:NO];
        _chartView.data = nil;
        [_traceTestResultView setHidden:YES];

        [self initTestStartText:_resultTextView];

        NSString *target = _ipTextField.text;
        NSInteger port = [_portTextField.text integerValue];
        NSString *time = _timeTextField.text;
        NSTimeInterval val = [time doubleValue];
        __block NSInteger countdown = val;

        _resultTextArray = [NSMutableArray arrayWithCapacity:0];

        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               countdown -= 1;
                               self->_countdownLabel.text = [NSString stringWithFormat:@"还剩%ld秒", (long)countdown];

                               if (countdown <= 0) {
                                   [self->_countdownLabel setHidden:YES];
                                   self->_pingTesting = NO;
                                   [self->_tcpPing stopTcpPing];
                                   [self->_timer invalidate];
                               }
                           });
        }];

        __block double index = 1.0;
        _tcpPing = [TestUtils tcpPing:target port:port count:1000 complete:^(NSMutableString *result) {
            NSLog(@"%@", result);
            if ([result containsString:@"TCP conn loss"]) {
                [self formatTcpPingResultText:self->_resultTextView];
            } else if ([result containsString:@"connect failed"] || [result containsString:@"DNS error"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                                   [self->_timer invalidate];
                                   [self->_countdownLabel setHidden:YES];
                                   self->_pingTesting = NO;
                                   [self formatTcpPingResultText:self->_resultTextView];
                               });
            } else {
                [self->_resultTextArray addObject:result];
                NSArray *pingTextArray = [result componentsSeparatedByString:@",  "];
                if (pingTextArray && pingTextArray.count >= 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                                       NSString *temp = [NSString stringWithFormat:@" ms \nconn to @%@:80", target];
                                       NSString *tempDelay = [pingTextArray[pingTextArray.count - 1] stringByReplacingOccurrencesOfString:temp withString:@""];
                                       NSString *delay = [tempDelay stringByReplacingOccurrencesOfString:@" ms \n" withString:@""];
                                       [self.verticalSeparateArray addObject:[[BarChartDataEntry alloc] initWithX:index y:[delay doubleValue]]];
                                       [self setChartData];
                                       index++;
                                   });
                }
            }
        }];
    }
}

- (IBAction)httpAction:(id)sender {
    if (_httpTesting) {
        _httpTesting = NO;
        [_downloadTask cancel];
        [self enabledAllButton];
    } else {
        _httpTesting = YES;
        [self buttonTitleChange];
        [self buttonStateDisabled:self.pingButton];
        [self buttonStateDisabled:self.udpButton];
        [self buttonStateDisabled:self.traceButton];
        [self resetLineChartView];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:YES];
        [_pingTestResultView setHidden:YES];
        _chartView.data = nil;
        [_traceTestResultView setHidden:NO];
        _traceResultTextView.text = @"";

        _downloadTask = [_speedUpUtils downloadFile:netSpeed progress:^(NSProgress *_Nonnull downloadProgress) {
//        NSLog(@"%lld\n", downloadProgress.totalUnitCount );
//        NSLog(@"%lld\n", downloadProgress.completedUnitCount );
            NSString *progessString = [NSString stringWithFormat:@"文件已下载：%.f%%\n", downloadProgress.fractionCompleted * 100];
            dispatch_async(dispatch_get_main_queue(), ^{
                               self->_traceResultTextView.text = progessString;
                           });
        } completionHandler:^(NSURLResponse *_Nonnull response, NSURL *_Nonnull filePath, NSError *_Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               NSMutableString *text = [self->_traceResultTextView.text mutableCopy];
                               if (error) {
                                   [text appendString:@"> 下载失败 <"];
                               } else {
                                   [text appendString:@"> 下载成功 <"];
                               }
                               self->_httpTesting = NO;
                               self->_traceResultTextView.text = [text copy];
                           });
            [self enabledAllButton];
        }];
    }
}

- (IBAction)udpAction:(id)sender {
    if (_udpTesting) {
        _udpTesting = NO;
        [TestUtils stopPing];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:NO];
        [_timer invalidate];
        [self formatResultText:_resultTextView];
        [self enabledAllButton];
    } else if ([self ipCheck]) {
        _udpTesting = YES;
        [self buttonTitleChange];
        [self buttonStateDisabled:self.pingButton];
        [self buttonStateDisabled:self.httpButton];
        [self buttonStateDisabled:self.traceButton];
        [self resetLineChartView];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:NO];
        [_pingTestResultView setHidden:NO];
        _chartView.data = nil;
        [_traceTestResultView setHidden:YES];

        [self initTestStartText:_resultTextView];

        NSString *target = _ipTextField.text;
        NSString *time = _timeTextField.text;
        NSTimeInterval val = [time doubleValue];
        __block NSInteger countdown = val;

        _resultTextArray = [NSMutableArray arrayWithCapacity:0];

        _timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *_Nonnull timer) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               countdown -= 1;
                               self->_countdownLabel.text = [NSString stringWithFormat:@"还剩%ld秒", (long)countdown];

                               if (countdown <= 0) {
                                   [self->_countdownLabel setHidden:YES];
                                   self->_udpTesting = NO;
                                   [TestUtils stopPing];
                                   [self->_timer invalidate];
                                   [self formatResultText:self->_resultTextView];
                               }
                           });
        }];

        __block double index = 1.0;
        [TestUtils ping:target packetCount:1000 pingResultHandler:^(NSString *_Nullable pingres, BOOL doingPing) {
            NSLog(@"%@", pingres);
            [self->_resultTextArray addObject:pingres];
            NSArray *pingTextArray = [pingres componentsSeparatedByString:@"time="];
            if (pingTextArray && pingTextArray.count == 2) {
                dispatch_async(dispatch_get_main_queue(), ^{
                                   NSString *delay = [pingTextArray[1] stringByReplacingOccurrencesOfString:@"ms" withString:@""];
                                   [self.verticalSeparateArray addObject:[[BarChartDataEntry alloc] initWithX:index y:[delay doubleValue]]];
                                   [self setChartData];
                                   index++;
                               });
            }
        }];
    }
}

- (IBAction)traceAction:(id)sender {
    if (_traceTesting) {
        _traceTesting = NO;
        _traceroute.maxTtl = 0;
        [self enabledAllButton];
    } else if ([self ipCheck]) {
        _traceTesting = YES;
        [self buttonTitleChange];
        [self buttonStateDisabled:self.pingButton];
        [self buttonStateDisabled:self.httpButton];
        [self buttonStateDisabled:self.udpButton];
        [self resetLineChartView];
        _countdownLabel.text = @"";
        [_countdownLabel setHidden:YES];
        [_pingTestResultView setHidden:YES];
        _chartView.data = nil;
        [_traceTestResultView setHidden:NO];
        _traceResultTextView.text = @"";

        NSString *target = _ipTextField.text;
        NSString *port = _portTextField.text;
        _traceroute = [Traceroute startTracerouteWithHost:target
                                                     port:port
                                                    queue:dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
                                             stepCallback:^(TracerouteRecord *record) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               NSString *text = [NSString stringWithFormat:@"%@%@\n", self->_traceResultTextView.text, record];
                               self->_traceResultTextView.text = text;
                           });
        } finish:^(NSArray<TracerouteRecord *> *results, BOOL succeed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                               NSMutableString *text = [self->_traceResultTextView.text mutableCopy];
                               if (succeed) {
                                   [text appendString:@"> Traceroute成功 <"];
                               } else {
                                   [text appendString:@"> Traceroute失败 <"];
                               }
                               self->_traceResultTextView.text = [text copy];
                               self->_traceTesting = NO;
                               [self enabledAllButton];
                           });
        }];
    }
}

- (IBAction)backAction:(id)sender {
    if (_pingTesting) {
        [_tcpPing stopTcpPing];
    }
    if (_httpTesting) {
        [_downloadTask cancel];
    }
    if (_udpTesting) {
        [_pnUdpTraceroute stopUdpTraceroute];
    }
    if (_traceTesting) {
        _traceroute.maxTtl = 0;
    }
    
    _tcpPing = nil;
    _downloadTask = nil;
    _pnUdpTraceroute = nil;
    _traceroute = nil;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark - ChartViewDelegate

- (void)chartValueSelected:(ChartViewBase *__nonnull)chartView entry:(ChartDataEntry *__nonnull)entry highlight:(ChartHighlight *__nonnull)highlight {
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase *__nonnull)chartView {
    NSLog(@"chartValueNothingSelected");
}

@end
