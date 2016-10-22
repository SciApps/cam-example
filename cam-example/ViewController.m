//
//  ViewController.m
//  cam-example
//
//  Created by Robert Balint on 06/10/16.
//  Copyright © 2016 SciApps. All rights reserved.
//

#import "ViewController.h"
#import "MyTableViewCell.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if (!_allIngredients) {
        [self _fetchItemList];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray<NSDictionary<NSString *, id> *> *)_getPairsForIngredient:(NSDictionary<NSString *, id> *)ingredient {
    NSPredicate *targetPredicate;
    
    switch (_level) {
        case 0: {
            targetPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@ AND SELF != %@", @"effects", ingredient[@"effects"], ingredient];
            break;
        }
            
        default: {
            NSMutableSet<NSString *> *subEffectsSet = [NSMutableSet new];
            
            for (NSDictionary<NSString *, id> *subIngredient in _allIngredients) {
                [subEffectsSet addObjectsFromArray:subIngredient[@"effects"]];
            }
            
            [subEffectsSet minusSet:[NSSet setWithArray:_allIngredients.firstObject[@"effects"]]];
            
            targetPredicate = [NSPredicate predicateWithFormat:@"ANY %K IN %@ AND SELF != %@", @"effects", subEffectsSet, ingredient];
            break;
        }
    }
    
    NSArray<NSDictionary<NSString *, id> *> *pairs = [_allIngredients filteredArrayUsingPredicate:targetPredicate];
    
    return pairs;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(MyTableViewCell *)sender {
    if ([segue.destinationViewController isKindOfClass:self.class] &&
        [sender isKindOfClass:MyTableViewCell.class]) {
        
        ViewController *destVC = segue.destinationViewController;
        NSArray<NSDictionary<NSString *, id> *> *pairs = [self _getPairsForIngredient:sender.ingredient];
        destVC.allIngredients = [@[sender.ingredient] arrayByAddingObjectsFromArray:pairs];
        destVC.allEffects = _allEffects;
        destVC.level = _level + 1;
    }
    
}

- (void)_presentError:(NSError *)error {
    UIAlertController *alertController =
    [UIAlertController
     alertControllerWithTitle:@"An error has occurred"
     message:error.localizedDescription
     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction =
    [UIAlertAction
     actionWithTitle:@"OK"
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * _Nonnull action) {
         [alertController dismissViewControllerAnimated:YES completion:nil];
     }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 {
 "effects": [
 "Weakness to Frost",
 "Fortify Sneak",
 "Weakness to Poison",
 "Fortify Restoration"
 ],
 "image": "http://www.uesp.net/w/images/thumb/7/7a/SR-icon-ingredient-Abecean_Longfin.png/48px-SR-icon-ingredient-Abecean_Longfin.png",
 "value": 15,
 "name": "Abecean Longfin",
 "weight": 0.5
 }
 */

- (void)_processItemList:(NSDictionary<NSString *, NSArray<NSDictionary<NSString *, id> *> *> *)collection {
    NSMutableSet<NSString *> *allEffectsSet = [NSMutableSet new];
    NSArray<NSDictionary<NSString *, id> *> *ingredients = collection[@"ingredients"];
    NSMutableArray<NSDictionary<NSString *, id> *> *ingredientsValidated = [NSMutableArray new];
    
    if (![ingredients isKindOfClass:NSArray.class]) {
        return;
    }
    
    for (NSDictionary<NSString *, id> *ingredient in ingredients) {
        NSArray<NSString *> *effects = ingredient[@"effects"];
        NSString *image = ingredient[@"image"];
        NSNumber *value = ingredient[@"value"];
        NSString *name = ingredient[@"name"];
        NSNumber *weight = ingredient[@"weight"];
        
        if (![effects isKindOfClass:NSArray.class] ||
            effects.count != 4 ||
            ![image isKindOfClass:NSString.class] ||
            ![value isKindOfClass:NSNumber.class] ||
            ![name isKindOfClass:NSString.class] ||
            ![weight isKindOfClass:NSNumber.class]) {
            
            continue;
        }
        
        [allEffectsSet addObjectsFromArray:effects];
        [ingredientsValidated addObject:ingredient];
    }
    
    _allEffects = [allEffectsSet sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(lowercaseString)) ascending:YES]]];
    
    _allIngredients = [ingredientsValidated sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)_fetchItemList {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://raw.githubusercontent.com/zsiciarz/skyrim-alchemy-toolbox/master/data/ingredients.json"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask =
    [session dataTaskWithURL:components.URL
           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
               NSError *jsonError;
               NSDictionary *collection = error ? nil : [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
               
               dispatch_async(dispatch_get_main_queue(), ^{
                   if (error) {
                       [self _presentError:error];
                   }
                   else if (jsonError) {
                       [self _presentError:jsonError];
                   }
                   else {
                       [self _processItemList:collection];
                   }
               });
           }
     ];
    
    [dataTask resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allIngredients.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell" forIndexPath:indexPath];
    
    cell.ingredient = _allIngredients[indexPath.row];
    NSArray<NSDictionary<NSString *, id> *> *pairs = [self _getPairsForIngredient:cell.ingredient];
    cell.pairLabel.text = @(pairs.count).stringValue;
    
    return cell;
}

@end
