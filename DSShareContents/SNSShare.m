//
//  SNSShare.m
//  DSShareContents
//
//  Created by HanSanghong on 2016. 6. 27..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import "SNSShare.h"

#import <KakaoOpenSDK/KakaoOpenSDK.h>
#import <FacebookSDK/FacebookSDK.h>
#import "StoryLinkHelper.h"

#define AppBundle               [NSBundle mainBundle]
#define KAKAO_URL               @"https://itunes.apple.com/app/id362057947?mt=8"

@implementation SNSShare

@synthesize sButtonCaption = _sButtonCaption;

#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _sButtonCaption = @"앱으로 연결";
    }
    
    return self;
}

#pragma mark - Public Method

//
//
//
- (BOOL)shareWithKakaoTalk:(NSDictionary *)dict
{
    
    NSString *sUrl = dict[@"clickUrl"];
    NSString *sTitle = dict[@"title"];
    NSString *sDesc = dict[@"desc"];
    NSString *sImageUrl = dict[@"imgUrl"];
    NSString *sMessage = [NSString stringWithFormat:@"%@\n%@\n%@", sTitle, sDesc, sUrl];
    
    NSArray *arrKakaoAppLink;
    
    sUrl = [sUrl stringByReplacingOccurrencesOfString:@"http" withString:@"DSShareContents"];
    
    NSString *AndroidLink = [sUrl stringByReplacingOccurrencesOfString:@"&" withString:@"@"];
    
    if ([AndroidLink respondsToSelector:@selector(stringByAddingPercentEscapesUsingEncoding:)]) {
        AndroidLink = [AndroidLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        AndroidLink = [AndroidLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    NSString *iOSLink = [sUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([iOSLink respondsToSelector:@selector(stringByAddingPercentEscapesUsingEncoding:)]) {
        iOSLink = [iOSLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    else {
        iOSLink = [iOSLink stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    
    
    KakaoTalkLinkAction *androidAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                                                   devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                    execparam:@{@"executeurl":AndroidLink}];
    
    KakaoTalkLinkAction *iphoneAction = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                                                  devicetype:KakaoTalkLinkActionDeviceTypePhone
                                                                   execparam:@{@"executeurl":iOSLink}];
    
    
    KakaoTalkLinkObject *label = [KakaoTalkLinkObject createLabel:sMessage];
    KakaoTalkLinkObject *button = [KakaoTalkLinkObject createAppButton:_sButtonCaption actions:@[iphoneAction, androidAction]];
    
    if (sImageUrl && ([sImageUrl isEqualToString:@""] == NO)) {
        KakaoTalkLinkObject *image = [KakaoTalkLinkObject createImage:sImageUrl width:500 height:500];
        arrKakaoAppLink = [NSArray arrayWithObjects:label, image, button, nil];
    }
    else {
        arrKakaoAppLink = [NSArray arrayWithObjects:label, button, nil];
    }
    
    if([KOAppCall canOpenKakaoTalkAppLink]) {
        [KOAppCall openKakaoTalkAppLink:arrKakaoAppLink];
        return true;
    }
    else {
        return false;
    }
}

//
//
//
- (BOOL)shareWithFacebook:(NSDictionary *)dict
{
    NSString *sUrl = dict[@"clickUrl"];
    NSString *sTitle = dict[@"title"];
    NSString *sDesc = dict[@"desc"];
    NSString *sImageUrl = dict[@"imgUrl"];

    BOOL bResult = YES;
    
    FBShareDialogParams *params = [[FBShareDialogParams alloc] init];
    [params setLink:[NSURL URLWithString:sUrl]];
    [params setName:[NSString stringWithFormat:@"%@",sTitle]];
    [params setCaption:nil];
    if (sImageUrl) {
        [params setPicture:[NSURL URLWithString:sImageUrl]];
    }
    
    [params setDescription:sDesc];
    
    FBAppCall *appCall = [FBDialogs presentShareDialogWithLink:params.link
                                                          name:params.name
                                                       caption:params.caption
                                                   description:params.description
                                                       picture:params.picture
                                                   clientState:nil
                                                       handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                           
                                                       }];
    
    if(!appCall) {
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:[NSString stringWithFormat:@"%@",sTitle] forKey:@"name"];
        [param setObject:sUrl forKey:@"link"];
        if (sImageUrl) {
            [param setObject:sImageUrl forKey:@"picture"];
        }
        [param setObject:@"" forKey:@"caption"];
        [param setObject:@"" forKey:@"description"];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:param
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  }];
    }
    
    return bResult;
}

- (BOOL)shareWithKaKaoStory:(NSDictionary *)dict
{
    NSString *sUrl = dict[@"clickUrl"];
    NSString *sImageUrl = dict[@"imgUrl"];
    
    if ([StoryLinkHelper canOpenStoryLink]) {
        
        NSString *sPosting = @"";
        
        ScrapInfo *scrapInfo = [[ScrapInfo alloc] init];
        
        if (sImageUrl && ([sImageUrl isEqualToString:@""] == NO)) {
            
            sPosting = sUrl;
            
            scrapInfo.title = dict[@"title"];
            scrapInfo.desc = dict[@"desc"];
            scrapInfo.type = ScrapTypeArticle;
            scrapInfo.imageURLs = @[sImageUrl];
        }
        else {
            sPosting = [NSString stringWithFormat:@"%@ %@ %@", dict[@"title"], dict[@"desc"], sUrl];
        }
        
        NSString *sStorySchemeUrl = [StoryLinkHelper makeStoryLinkWithPostingText:sPosting
                                                                      appBundleID:[AppBundle bundleIdentifier]
                                                                       appVersion:[AppBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                                                          appName:[AppBundle objectForInfoDictionaryKey:@"CFBundleName"]
                                                                        scrapInfo:scrapInfo];
        
        if ([StoryLinkHelper openStoryLinkWithURLString:sStorySchemeUrl]) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

//
//
//
- (BOOL)shareWithBlog:(NSDictionary *)dict
{
    NSString *sUrl = dict[@"clickUrl"];
    NSString *sImageUrl = dict[@"imgUrl"];
    
    NSString *blogUrlString = [[NSString stringWithFormat:@"naverblog://write?version=1&title=%@&content=%@\n%@&imageUrls=[\"%@\"]",dict[@"title"], dict[@"desc"], sUrl, sImageUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    BOOL r =[[UIApplication sharedApplication] openURL:[NSURL URLWithString:blogUrlString]];
    if (!r) {
        return NO;
    }
    else {
        return YES;
    }
}

//
//
//
- (BOOL)shareWithLINE:(NSDictionary *)dict
{
    NSString *sUrl = dict[@"clickUrl"];
    NSString *sImageUrl = dict[@"imgUrl"];
    NSString *sDesc = dict[@"desc"];
    
    NSString *_resultString = [[NSString stringWithFormat:@"%@\n%@\n%@",sDesc,sUrl,sImageUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *LineUrlString = [NSString stringWithFormat:@"line://msg/text/%@",_resultString];
    BOOL r =[[UIApplication sharedApplication] openURL:[NSURL URLWithString:LineUrlString]];
    if (!r) {
        return NO;
    }
    else {
        return YES;
    }
}

@end
