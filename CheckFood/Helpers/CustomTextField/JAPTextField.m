//
//  JAPTextField.m
//  Checkfood
//
//  Copyright 2014 5emeGauche
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "JAPTextField.h"

#define kTextMargins 10.0

@interface JAPTextField ()
- (void)_init;
@end

@implementation JAPTextField

@synthesize isHighlighted = _isHighlighted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _init];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    [self _init];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    CGFloat leftViewWidth = (self.leftView == nil) ? 0. : [self leftViewRectForBounds:bounds].size.width;
    
    return CGRectMake(leftViewWidth + kTextMargins, 0., bounds.size.width - leftViewWidth - 2*kTextMargins, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGFloat leftViewWidth = (self.leftView == nil) ? 0. : [self leftViewRectForBounds:bounds].size.width;
    
    return CGRectMake(leftViewWidth + kTextMargins, 0., bounds.size.width - leftViewWidth - 2*kTextMargins, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGFloat leftViewWidth = (self.leftView == nil) ? 0. : [self leftViewRectForBounds:bounds].size.width;
    
    return CGRectMake(leftViewWidth + kTextMargins, 0., bounds.size.width - leftViewWidth - 2*kTextMargins, bounds.size.height);
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    return CGRectMake(self.leftView.frame.origin.x, 0., bounds.size.height, bounds.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Public methods
- (void)setFontSize:(CGFloat)fontSize
{
    [super setFont:[UIFont fontWithName:self.font.fontName size:fontSize]];
}

- (void)highlight:(BOOL)highlight
{
    _isHighlighted = highlight;
    
    // change background image
    UIImage *backgroundImage = highlight ? [[UIImage imageNamed:@"text_field_red-1.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8., 8., 8., 8.)] : [[UIImage imageNamed:@"text_field.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8., 8., 8., 8.)];
    [self setBackground:backgroundImage];
}


#pragma mark - Private methods
- (void)_init
{
    // border style
    [self setBorderStyle:UITextBorderStyleNone];
    // background image
    [self setBackground:[[UIImage imageNamed:@"rectangle_nom_produit.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8., 8., 8., 8.)]];
    // text color
    NSString *stringColor = @"#777777";
    NSUInteger red, green, blue;
    sscanf([stringColor UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    [self setTextColor:[UIColor colorWithRed:71/255.0 green:80/255.0 blue:85/255.0 alpha:1]];
    //placeholder  text color
    [self setValue:[UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1] forKeyPath:@"_placeholderLabel.textColor"];
    // default font
    [self setFont:[UIFont fontWithName:@"Roboto-Regular" size:13.0]];
    // left view mode
    [self setLeftViewMode:UITextFieldViewModeAlways];
}

@end
