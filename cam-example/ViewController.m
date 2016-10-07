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

@end

@implementation ViewController {
    NSArray<NSString *> *_dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataArray = @[@"s--3gdhGiyC--/w_1160/6lt4XjIAOthNAK7Gs.jpeg",
                   @"s--oDPZ5d5H--/w_1160/6lsqqyX3khIxKeDls.jpeg",
                   @"s--6lg2yRHf--/w_1160/6uPZJx1f8lSv1KYt2s.jpeg",
                   @"s--1s3U3s5Y--/w_1160/6rxruttIrvspCO8Fs.jpeg",
                   @"s--d1k0Jr_H--/w_1160/6tszxo2CK9Ha1HUqus.jpeg",
                   @"s--drwdZxBa--/w_1160/6qOXHcz48F9uKeFUs.jpeg"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCell" forIndexPath:indexPath];
    
    cell.asyncImageView.emptyImage = [UIImage imageNamed:@"coarse-hairy-fibrous-brown-paper-texture-photoshop-textures"];
    cell.asyncImageView.assetName = _dataArray[indexPath.row];
    
    return cell;
}

@end
