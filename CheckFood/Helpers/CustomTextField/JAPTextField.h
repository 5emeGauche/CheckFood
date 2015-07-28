//
//  JAPTextField.h
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

#import <UIKit/UIKit.h>

/**
 This class represents a cutom UITextField that conforms to graphic specifications of the application
 */
@interface JAPTextField : UITextField
{
    BOOL _isHighlighted;
}

/**
 Attribute that indicates if the field is highlighted or not.
 */
@property (nonatomic, readonly) BOOL isHighlighted;

/**
 Method used to set the field's font size
 @param fontSize The desired font size
 */
- (void)setFontSize:(CGFloat)fontSize;
/**
 Method used to highlight/unhighlight the text field
 @param highlight YES to highlight the text field, NO otherwise
 */
- (void)highlight:(BOOL)highlight;
/**
 Method used to enable/disable the text field
 @param enabled YES to enable the text field, NO otherwise
 */
//- (void)enabled:(BOOL)enabled;

@end
