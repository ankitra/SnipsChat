//
//  ViewController.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "ViewController.h"
#import "SCTableViewCell.h"


@interface ViewController ()
{
    NSMutableArray * chatMessageArray;
    dispatch_once_t onceToken;
}
@end

@implementation ViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    NSString * text = ((SCTableViewCell *) [tableView cellForRowAtIndexPath:indexPath]).jsonView.text;
    
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    dispatch_once(&onceToken, ^{
        chatMessageArray = [[NSMutableArray alloc]init];
    });
    
    
    self.jsonTable.rowHeight = 150;
    self.jsonTable.dataSource = self;
    self.jsonTable.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
   // return chatMessageArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *scTableIdentifier = @"SCTableViewCell";
    SCTableViewCell *cell = (SCTableViewCell *)[tableView dequeueReusableCellWithIdentifier:scTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SCTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [cell.progress startAnimating];
    cell.jsonView.text = @"AAAA";
    
    return cell;

}

@end
