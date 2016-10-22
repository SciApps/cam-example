//
//  MyTableViewCell.m
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import "MyTableViewCell.h"

@interface MyTableViewCell ()

@property (weak, nonatomic) IBOutlet MyAssetImageView *asyncImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *effectLabels;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;

@end

@implementation MyTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _asyncImageView.emptyImage = [UIImage imageNamed:@"coarse-hairy-fibrous-brown-paper-texture-photoshop-textures"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setIngredient:(NSDictionary<NSString *,id> *)ingredient {
    _ingredient = ingredient;
    
    NSArray<NSString *> *effects = ingredient[@"effects"];
    NSString *image = ingredient[@"image"];
    NSNumber *value = ingredient[@"value"];
    NSString *name = ingredient[@"name"];
    NSNumber *weight = ingredient[@"weight"];
    
    
    _asyncImageView.assetName = image;
    _itemNameLabel.text = name;
    _valueLabel.text = value.stringValue;
    _weightLabel.text = weight.stringValue;
    
    for (NSUInteger i = 0; i < effects.count; i++) {
        _effectLabels[i].text = effects[i];
    }
}

@end
