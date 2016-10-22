//
//  ViewController.h
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, id> *> *allIngredients;
@property (nonatomic, strong) NSArray<NSString *> *allEffects;
@property (nonatomic, strong) NSDictionary<NSString *, NSDictionary<NSString *, id> *> *effectMap;
@property (nonatomic) NSUInteger level;

@end

