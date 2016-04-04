//
//  CamViewController.m
//  phantom
//
//  Created by Sheryl Zhang on 3/27/16.
//  Copyright (c) 2016 Sheryl Zhang. All rights reserved.
//


// Project -> Build Phases -> Compile Sources
// Ignore all warnings
// Add '-w' to compiler flags

#import "CamViewController.h"

@interface CamViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) IBOutlet UITextField *nameField;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIToolbar *toolbar;

@end

@implementation CamViewController


- (IBAction)takePicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // if device has a camera, take picture with camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    // pick from photo library
    else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }

    imagePicker.delegate = self;
    
    // place image picker on the screen
    [self presentViewController:imagePicker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Get picked image from info dictionary
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // Put that image onto the screen in our image view
    self.imageView.image = image;
    
    // Save image to photo album
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    [self initNetworkCommunication];
    
    [self sendString:@"Hello World!"];
    
    // NSLog(@"send string success");
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
    [data release];
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



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Welcome";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
