//
//  CFActionSheet.m
//  CheckFood
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

#import "CFActionSheet.h"
#import "CFAppDelegate.h"
#import "CFCaptureProductViewController.h"

@implementation CFActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)tapOut:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self];
    
    if (p.y < 0) { // They tapped outside
        [self dismissWithClickedButtonIndex:0 animated:YES];
        
        UINavigationController *mainNavVC = (UINavigationController *)[(CFAppDelegate *)[[UIApplication sharedApplication] delegate] mainNavigationController];
        CFCaptureProductViewController *prefVC = [[mainNavVC viewControllers] lastObject];
        if ([prefVC isKindOfClass:[CFCaptureProductViewController class]]) {
            [prefVC dismissPickerShowPopUp];
        }

    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // return
    return true;
}

-(void) showInView:(UIView *)view {
	[super showInView:view];
	
	// Capture taps outside the bounds of this alert view
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOut:)];
	tap.cancelsTouchesInView = NO; // So that legit taps on the table bubble up to the tableview
    tap.delegate = self;
	[self.window addGestureRecognizer:tap];
}

/*-(void)showInView:(UIView *)view
{
    [super showInView:view];
    // Capture taps outside the bounds of this alert view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOut:)];
    tap.cancelsTouchesInView = NO; // So that legit taps on the table bubble up to the tableview
    [self.window addGestureRecognizer:tap];

}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
