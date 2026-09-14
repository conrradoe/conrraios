//
//  MyTextField.h
//  Taxi
//
//  Created by nitin on 6/6/13.
//  Copyright (c) 2013 nitin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldPadding : UITextField

-(CGRect)textRectForBounds:(CGRect)bounds;
-(CGRect)editingRectForBounds:(CGRect)bounds;
@end
