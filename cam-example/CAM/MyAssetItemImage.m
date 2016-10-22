//
//  MyAssetItemImage.m
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import "MyAssetItemImage.h"
#import "MyAssetManager.h"

@implementation MyAssetItemImage

+ (Class)parentCamClass {
    return MyAssetManager.class;
}

+ (NSUInteger)workerThreads {
    return 4;
}

+ (NSString *)base64EncodePath:(NSString *)path {
    NSData *identifierData = [path dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Identifier = [identifierData base64EncodedStringWithOptions:0];
    
    return [base64Identifier stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
}

+ (NSString *)base64DecodePath:(NSString *)base64EncodedPath {
    NSString *base64EncodedStr = [base64EncodedPath stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSData *identifierData = [[NSData alloc] initWithBase64EncodedString:base64EncodedStr options:0];
    
    return [[NSString alloc] initWithData:identifierData encoding:NSUTF8StringEncoding];
}

- (NSString *)fileSystemPath {
    NSString *fsPath = [[CoreAssetItemNormal assetStorageDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", [self.class base64EncodePath:super.assetName]]];
    return [fsPath stringByAppendingString:@""];
}

- (NSURLRequest *)createURLRequest {
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    
    NSURL *baseUrl = [NSURL URLWithString:super.assetName];
    
    [request setURL: baseUrl];
    [request setHTTPMethod:@"GET"];
    
    return request;
}

@end
