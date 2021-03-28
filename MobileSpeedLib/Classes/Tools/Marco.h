//
//  Marco.h
//  MobileSpeed
//
//  Created by 邹程 on 2020/4/26.
//  Copyright © 2020 邹程. All rights reserved.
//

#ifndef Marco_h
#define Marco_h

#define WeakSelf __weak typeof(self) weakSelf = self;

#define tracertReportUrl @"http://npm.kgogogo.com/tracertReport"

#define qosReportUrl @"http://npm.kgogogo.com/qosReport"

#define getTokenUrl @"http://42.99.34.130:80/getTokenTest?appid=bcmTest"

#define getCmGuandongTokenUrl @"http://120.196.166.156/bdproxy/jsonp.php?appid=shengyuan"

//#define getAreaInfoUrl @"https://4gqos.h2comm.com.cn/areaInfo"
#define getAreaInfoUrl @"http://4gqos.h2comm.com.cn:8090/hybAreaInfo"

#define applyUrl @"http://4gqos.h2comm.com.cn:8090/ivsp/services/AACAPIV1/applyTecentGamesQoS"

#define cancelUrl  @"http://4gqos.h2comm.com.cn:8090/ivsp/services/AACAPIV1/getRemoveTecentGamesQoS"

#define netSpeed @"http://120.52.72.43:8081/test.mp4"

#define defaultIp @"120.52.72.43"

#define defaultPort @"80"

/// 加速状态
#define SP_KEY_CORRELATION_ID @"SP_KEY_CORRELATION_ID"

#define kVPNDecrypt_KEY @"testshengyuan2021key"

#define testAppId @"111"
#define testUserId @"111"
#define testBusinessId @"13488857472"

#endif /* Marco_h */
