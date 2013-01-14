//
//  TCFirstViewController.h
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCFirstViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic,weak) IBOutlet UIImageView* imageView;

@property (nonatomic,weak) IBOutlet UITextView* textView;

- (IBAction)pushedImageButton:(id)sender;
- (IBAction)pushedPostButton:(id)sender;

@end
