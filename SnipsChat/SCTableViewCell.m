//
//  SCTableViewCell.m
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCTableViewCell.h"

@implementation SCTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.progress.hidesWhenStopped = YES;
    self.jsonView.scrollEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
