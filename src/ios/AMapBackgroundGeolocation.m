//
// Lyxpay.m
// PluginTest
//
// Created by 冬追夏赶 on 9 / 15 / 16.
//
//

#import "AMapBackgroundGeolocation.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


@interface AMapBackgroundGeolocation () <AMapLocationManagerDelegate>
@property (nonatomic, strong) CDVInvokedUrlCommand *tempCommand;
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) NSDate *timestamp;
@end

@implementation AMapBackgroundGeolocation

-(void)pluginInitialize
{
    // self.apikey = [[self.commandDelegate settings] objectForKey:@"APIKEY"];
    [AMapServices sharedServices].apiKey = (NSString *)[[self.commandDelegate settings] objectForKey:@"ios_apikey"];
    
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
//    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
//    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //开启带逆地理连续定位
    [self.locationManager setLocatingWithReGeocode:YES];
    
//    timestamp =
}

- (void)start : (CDVInvokedUrlCommand *)command
{
    self.tempCommand = command;
    self.locationManager.distanceFilter = 1;
    [self.locationManager startUpdatingLocation];
}

- (void)stop : (CDVInvokedUrlCommand *)command
{
    self.tempCommand = command;
    [self.locationManager stopUpdatingLocation];
}


- (void)sendResp:(NSDictionary *)resultDic status:(CDVCommandStatus)status{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:status];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.tempCommand.callbackId];
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //    NSLog(@"%@", error);
    NSDictionary *dic = @{@"errorCode":[NSString stringWithFormat:@"%ld",[error code]]};
//    NSLog(@"%@", dic);
    [self sendResp:dic status:CDVCommandStatus_ERROR];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    // reGeocode  =  AMapLocationReGeocode:{formattedAddress:浙江省杭州市西湖区金蓬街758舞蹈艺术中心(金地自在城教学点); country:中国;province:浙江省; city:杭州市; district:西湖区; citycode:0571; adcode:330106; street:金蓬街; number:293号; POIName:758舞蹈艺术中心(金地自在城教学点); AOIName:(null);}
    if([self timestamp] == nil || [[self timestamp] timeIntervalSince1970] - [location.timestamp timeIntervalSince1970] > 600){ //10分钟回调1次
        self.timestamp = location.timestamp;
        NSDictionary *dic = @{@"lng":[NSString stringWithFormat:@"%f",location.coordinate.longitude],@"lat":[NSString stringWithFormat:@"%f",location.coordinate.latitude],@"address":[NSString stringWithFormat:@"%@",reGeocode.formattedAddress]};
//        NSLog(@"%@", dic);
        [self sendResp:dic status:CDVCommandStatus_OK];
    }
}

@end
