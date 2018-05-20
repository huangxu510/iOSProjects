//
//  BKQuestionTableViewCell.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/19.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKQuestionTableViewCell.h"

@implementation BKQuestionTableViewCellModel

@end

@interface BKQuestionTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation BKQuestionTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    BKCornerRadius(_containerView, 5);
}

- (void)setData:(BKQuestionTableViewCellModel *)data {
    _data = data;
    self.frame = CGRectMake(0, 0, kScreenWidth, 100);
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle  setLineSpacing:5];
    NSMutableAttributedString  *question = [[NSMutableAttributedString alloc] initWithString:data.question];
    [question  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [question length])];
    _questionLabel.attributedText = question;

    NSMutableAttributedString  *answer = [[NSMutableAttributedString alloc] initWithString:data.answer];
    [answer  addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [answer length])];
    _answerLabel.attributedText = answer;
//    _questionLabel.text = data.question;
//    _answerLabel.text = data.answer;
    
    [self layoutIfNeeded];
    self.height = CGRectGetMaxY(_answerLabel.frame) + 25;
}
@end
