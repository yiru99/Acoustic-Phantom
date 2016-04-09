//
//  ViewController.m
//  ImageCropView
//
//  Created by Ming Yang on 12/27/12.
//
//

#import "ViewController.h"
#import "CBAutoScrollLabel.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet CBAutoScrollLabel *autoScrollLabel;
@property (weak, nonatomic) IBOutlet CBAutoScrollLabel *navigationBarScrollLabel;

@end

@implementation ViewController

@synthesize imageCropView;
@synthesize outputLabel = _outputLabel;
@synthesize inputName = _inputName;
@synthesize welcomeField = _welcomeField;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    imageCropView.image = [UIImage imageNamed:@"pict.jpeg"];
    imageCropView.controlColor = [UIColor cyanColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) backgroundTouched:(id)sender{
    [_inputName resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField == _inputName){
        [_inputName resignFirstResponder];
        NSString* str = [NSString stringWithFormat:@"Hello, %@, welcome to Acoustic Phantom.",self.inputName.text];
        self.welcomeField.backgroundColor = [UIColor blueColor];
        self.welcomeField.text = str;
    }
    return NO;
}

- (IBAction)takeBarButtonClick:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
        [imagePicker setDelegate:self];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your device doesn't have a camera." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)openBarButtonClick:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    image = [info valueForKey:UIImagePickerControllerOriginalImage];
    imageView.image = image;
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cropBarButtonClick:(id)sender {
    if(image != nil){
        ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:image];
        controller.delegate = self;
        controller.blurredBackground = YES;
        // set the cropped area
        // controller.cropArea = CGRectMake(0, 0, 100, 200);
        [[self navigationController] pushViewController:controller animated:YES];
    }
}

- (void)ImageCropViewControllerSuccess:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    image = croppedImage;
    imageView.image = croppedImage;
    CGRect cropArea = controller.cropArea;
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    imageView.image = image;
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail!"
                                                        message:[NSString stringWithFormat:@"Saved with error %@", error.description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succes!"
                                                                message:@"Saved to camera roll"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];

    }
}

- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"10.0.0.10", 1027, &readStream, &writeStream);
    // NSInputStream *inputStream = ( NSInputStream *)readStream;
    NSOutputStream *outputStream = (NSOutputStream *)writeStream;
    // [inputStream setDelegate:(id<NSStreamDelegate>)self];
    [outputStream setDelegate:self];
    // [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    // [inputStream open];
    [outputStream open];
}


// TODO:
// fix this!
- (void)sendString:(NSString *)string {
    NSData *data = [[NSData alloc] initWithData:[string dataUsingEncoding:NSASCIIStringEncoding]];
    NSLog(@"%@", [string dataUsingEncoding:NSUTF8StringEncoding]);
    NSMutableData *_data = [[NSMutableData alloc] init];
    [_data appendData:data];
}


- (void)stream:(NSStream *)currentStream handleEvent:(NSStreamEvent)streamEvent {
    //NSLog(@"stream event %u", streamEvent);
    BOOL shouldClose = NO;
    NSString *io;
    NSString *event;
    switch(streamEvent) {
            
            // error case?
        case NSStreamEventEndEncountered:
            shouldClose = YES;
            NSLog(@"Closing stream...");
            if(![currentStream hasBytesAvailable]) break;
            // error case
        case NSStreamEventErrorOccurred:
            NSLog(@"Stream event ERROR");
            break;
            
            // When bytes are available to receive
            // Currently not useful
        case NSStreamEventHasBytesAvailable: {
            event = @"NSStreamEventHasBytesAvailable";
            // NSMutableData *_data = [[NSMutableData alloc] init];
            // uint8_t *readBytes = (uint8_t *)[_data mutableBytes];
            // wtf?
            // TODO
            // something with _data
            // readBytes += byteIndex; // instance variable byteIndex
            // and byteIndex??
            break;
        }
            
            // Allocate buffer for output stream
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            //const uint8_t *hexBytes = [hexData bytes];
            //uint8_t buffer[64] = {HexBytes[65], HexBytes[67], HexBytes[80], HexBytes[84], HexBytes[1]};
            uint8_t buffer[64] = {0x41, 0x43, 0x50, 0x54, 0x01};
            int len;
            len = [currentStream write:buffer maxLength:sizeof(buffer)];
            if (len > 0) {
                NSLog(@"YOOOOOO: sent");
                [currentStream close];
            }
            break;
            
        case NSStreamEventNone:
            NSLog(@"Stream event NONE");
            shouldClose = YES;
            break;
            
            // Open Stream
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream event OPEN COMPLETED");
            [self sendString:@"Hello World!"];
            shouldClose = YES;
            break;
            
        default:
            NSLog(@"Unknown event: %@ : %lu", currentStream, streamEvent);
            shouldClose = YES;
            
    }
    
    // TODO:
    // output fails on this line
    // if(shouldClose) [currentStream close];
}

- (IBAction)saveBarButtonClick:(id)sender {
    if (image != nil){
        UIImageWriteToSavedPhotosAlbum(image, self ,  @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    }
}
@end
