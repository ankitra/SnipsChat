//
//  ViewController.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "ViewController.h"
#import "SCTableViewCell.h"
#import "SCChatMessageParser.h"
#import "SCJsonViewerViewController.h"
@interface ViewController ()
{
  dispatch_once_t onceToken;
}
@property (strong,atomic) NSMutableArray<SCChatMessage *> * chatMessages;
@end

@implementation ViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView cellForRowAtIndexPath:indexPath].selected = NO;
    NSString * text = ((SCTableViewCell *) [tableView cellForRowAtIndexPath:indexPath]).jsonView.text;
    
    SCJsonViewerViewController * jvc = [[SCJsonViewerViewController alloc] init];
    id i =jvc.view;
    jvc.jsonView.text = text;
    i = nil;
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:jvc animated:YES];
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
        self.chatMessages = [[NSMutableArray<SCChatMessage *> alloc] init];
    });
    
    self.jsonTable.rowHeight = 150;
    self.jsonTable.dataSource = self;
    self.jsonTable.delegate = self;
    self.chatMessageBox.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chatMessages.count;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if(!self.chatMessages[self.chatMessages.count -1 - indexPath.row].finished)
        [cell.progress startAnimating];
    
    cell.jsonView.text = self.chatMessages[self.chatMessages.count -1 - indexPath.row].jsonString;
    
    return cell;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
    //All of this works because this message is called on the main thread only
    
    NSUInteger index = self.chatMessages.count;
    
    SCChatMessage * msg = [[SCChatMessageParser sharedParser] parse:textField.text AndCallBlockWithLink:^(SCChatMessage * m,BOOL finished)
    {


        //        [self.jsonTable reloadData];
        NSIndexPath * path = [NSIndexPath indexPathForRow:self.chatMessages.count -1 -index inSection:0];
        SCTableViewCell *cell = (SCTableViewCell *)[self.jsonTable cellForRowAtIndexPath:path];
        
        if(finished)
           [cell.progress stopAnimating];
        
        cell.jsonView.text = m.jsonString;
    }];
    
    [self.chatMessages addObject:msg];
    [self.jsonTable reloadData];
    self.chatMessageBox.text = nil;
    [self.chatMessageBox endEditing:YES];
    return YES;
}

@end
