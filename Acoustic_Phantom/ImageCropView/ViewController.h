//
//  ViewController.h
//  ImageCropView
//
//  Created by Ming Yang on 12/27/12.
//
//

#import <UIKit/UIKit.h>
#import "ImageCropView.h"


@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate,ImageCropViewControllerDelegate> {
    ImageCropView* imageCropView;
    UIImage* image;
    IBOutlet UIImageView *imageView;
}
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UITextField *inputName;
@property (weak, nonatomic) IBOutlet UILabel *welcomeField;

- (IBAction)takeBarButtonClick:(id)sender;
- (IBAction)openBarButtonClick:(id)sender;
- (IBAction)cropBarButtonClick:(id)sender;
- (IBAction)saveBarButtonClick:(id)sender;
@property (nonatomic, strong) IBOutlet ImageCropView* imageCropView;

@end
