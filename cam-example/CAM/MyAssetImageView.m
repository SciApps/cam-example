//
//  MyAssetImageView.m
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import "MyAssetImageView.h"
#import "MyAssetItemImage.h"

@implementation MyAssetImageView

+ (Class)parentCamItemClass {
    return MyAssetItemImage.class;
}

@end
