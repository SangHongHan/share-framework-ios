//
//  SNSShare.h
//  DSShareContents
//
//  Created by HanSanghong on 2016. 6. 27..
//  Copyright © 2016년 directionsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSShare : NSObject

@property (nonatomic, strong) NSString *sButtonCaption;

- (BOOL)shareWithKakaoTalk:(NSDictionary *)dict;
- (BOOL)shareWithFacebook:(NSDictionary *)dict;
- (BOOL)shareWithKaKaoStory:(NSDictionary *)dict;
- (BOOL)shareWithBlog:(NSDictionary *)dict;
- (BOOL)shareWithLINE:(NSDictionary *)dict;

@end
