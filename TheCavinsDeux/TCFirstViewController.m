//
//  TCFirstViewController.m
//  TheCavinsDeux
//
//  Created by Robert Cavin on 1/12/13.
//  Copyright (c) 2013 Robert Cavin. All rights reserved.
//

#import "TCFirstViewController.h"
#import "RCConnectionHandler.h"

@interface TCFirstViewController () {
    UIImagePickerControllerSourceType _imageSource;
}

@end

@implementation TCFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    
    switch (buttonIndex) {
        case 1: _imageSource = UIImagePickerControllerSourceTypePhotoLibrary; break;
        case 2: _imageSource = UIImagePickerControllerSourceTypeCamera; break;
    }
    [self performSegueWithIdentifier:@"openPicker" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"openPicker"]) {
        UIImagePickerController* controller = (UIImagePickerController*) segue.destinationViewController;
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"%@",info);
    self.imageView.image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)pushedPostButton:(id)sender {
    NSData* imageData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    [RCConnectionHandler requestJSONWithEndpoint:@"stream/1/post"
                                      withMethod:@"POST"
                                        withArgs:@{@"text":self.textView.text}
                                       withFiles:@[@{@"name":@"image",@"data":imageData,@"filename":@"image.jpg",@"mime-type":@"image/jpeg"},]
                                       withOwner:self
                                        callback:^(NSHTTPURLResponse *response, id json) {
                                            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Post Successful"
                                                                                                message:nil
                                                                                               delegate:nil
                                                                                      cancelButtonTitle:@"OK"
                                                                                      otherButtonTitles:nil];
                                            [alertView show];
                                        }];
    
}


@end
