//
//  MyTableViewCell.h
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAssetImageView.h"

@interface MyTableViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary<NSString *, id> *ingredient;
@property (weak, nonatomic) IBOutlet UILabel *pairLabel;

@end
