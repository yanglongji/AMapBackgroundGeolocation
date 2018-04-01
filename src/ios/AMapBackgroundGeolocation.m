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
// @property(nonatomic,strong)NSString *apikey;
@end

@implementation AMapBackgroundGeolocation

-(void)pluginInitialize
{
    // self.apikey = [[self.commandDelegate settings] objectForKey:@"APIKEY"];
    [AMapServices sharedServices].apiKey = (NSString *)[[self.commandDelegate settings] objectForKey:@"IOS_APIKEY"];
    
    NSLog(@"%@", [[self.commandDelegate settings] objectForKey:@"IOS_APIKEY"]);
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //开启带逆地理连续定位
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (void)start : (CDVInvokedUrlCommand *)command
{
    self.tempCommand = command;
    self.locationManager.distanceFilter = 100;
    [self.locationManager startUpdatingLocation];
}

- (void)stop : (CDVInvokedUrlCommand *)command
{
    self.tempCommand = command;
    [self.locationManager stopUpdatingLocation];
}


- (void)sendResp:(NSDictionary *)resultDic{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.tempCommand.callbackId];
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);

}

@end
