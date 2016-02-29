//
//  SCTableViewCell.h
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *jsonView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progress;

@end
