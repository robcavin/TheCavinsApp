//
//  TCFirstViewController.m
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import "TCCreatePostController.h"
#import "RCConnectionHandler.h"
#import <QuartzCore/QuartzCore.h>

@interface TCCreatePostController () {
    UIImagePickerControllerSourceType _imageSource;
    BOOL _postEdited;
    BOOL _imageAdded;
}

@end

@implementation TCCreatePostController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.addImageView.layer.borderWidth = 1;
    self.addImageView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.textView.layer.borderWidth = 1;
    self.textView.layer.cornerRadius = 10;
    self.textView.textColor = [UIColor grayColor];
    
    self.postButton.enabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)pushedImageButton:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Source"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Existing",@"Camera", nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    switch (buttonIndex) {
        case 0: _imageSource = UIImagePickerControllerSourceTypePhotoLibrary; break;
        case 1: _imageSource = UIImagePickerControllerSourceTypeCamera; break;
    }
    [self performSegueWithIdentifier:@"openPicker" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openPicker"]) {
        UIImagePickerController* controller = (UIImagePickerController*) segue.destinationViewController;
        controller.delegate = self;
        controller.sourceType = _imageSource;
        controller.allowsEditing = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@",info);
    self.imageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    _imageAdded = YES;
    self.postButton.enabled = ([self.textView.text length] || _imageAdded);
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.textView.text = @"";
    self.textView.textColor = [UIColor darkTextColor];    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!_postEdited) {
        _postEdited = YES;
        self.textView.text = @"";
        self.textView.textColor = [UIColor darkTextColor];
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        self.postButton.enabled = ([textView.text length] || _imageAdded);
        return NO;
    }
    
    return YES;
}

- (IBAction)pushedPostButton:(id)sender {

    NSDictionary* args = @{};
    NSArray* fileInfo = @[];
    
    if (_postEdited && [self.textView.text length] > 0)
        args = @{@"text":self.textView.text};
    
    if (_imageAdded) {
        NSData* imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
        fileInfo = @[@{ @"name":@"image", @"data":imageData,@"filename":@"image.jpg",@"mime-type":@"image/jpeg"},];
    }
    
    [RCConnectionHandler requestJSONWithEndpoint:@"stream/1/post"
                                      withMethod:@"POST"
                                        withArgs:args
                                       withFiles:fileInfo
                                       withOwner:self
                            withProgressCallback:^(float completionPercentage) {
                                self.postButton.hidden = YES;
                                self.progressView.hidden = NO;
                                self.progressView.progress = completionPercentage;
                            }
                          withCompletionCallback:^(NSHTTPURLResponse *response, id json) {
                              UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Post Successful"
                                                                                  message:nil
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
                              [alertView show];
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];
    
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
