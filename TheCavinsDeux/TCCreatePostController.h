//
//  TCFirstViewController.h
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCCreatePostController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UIImageView* imageView;

@property (nonatomic, weak) IBOutlet UITextView* textView;
@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

- (IBAction)pushedImageButton:(id)sender;
- (IBAction)pushedPostButton:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;

@end
