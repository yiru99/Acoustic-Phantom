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

typedef struct hsv_color
{
    CGFloat hue;
    CGFloat sat;
    CGFloat val;
};

typedef struct rgb_color
{
    CGFloat r;
    CGFloat g;
    CGFloat b;
};

//static CGFloat h = 0;
//static CGFloat s = 0;
//static CGFloat v = 0;

static struct hsv_color hsv1;
static struct hsv_color min_hsv1;
static struct hsv_color max_hsv1;
static struct hsv_color hsv2;
static struct hsv_color min_hsv2;
static struct hsv_color max_hsv2;
//this is x and y coordinates of the two points selected by the user
static const int RECT1_OFFSET_ROW = 10;
static const int RECT1_OFFSET_COL = 10;
static const int RECT2_OFFSET_ROW = -1;
static const int RECT2_OFFSET_COL = -1;
static struct rgb_color rgb;

// not using this right now
struct hsv_color hsv;


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
    
    struct hsv_color temp_hsv;
    temp_hsv.hue = 0;
    hsv1.hue = 0;
    min_hsv1.hue = 359;
    max_hsv1.hue = 0;
    
    CGImageRef cgImage = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rgbBuffer = malloc(4);
    //TODO: change the screen width and height to be
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    int midHeight = (int)(screenHeight * 0.5);
    for (int col = 10; col < 110; col++)
    {
        CGRect sourceRect = CGRectMake(col, midHeight, 1.f, 1.f);
        CGImageRef cgImageInRect = CGImageCreateWithImageInRect(cgImage, sourceRect);
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), cgImageInRect);
        CGImageRelease(cgImageInRect);
        CGContextRelease(context);
        
        rgb.r = rgbBuffer[0];
        rgb.g = rgbBuffer[1];
        rgb.b = rgbBuffer[2];
        temp_hsv.hue = 0;
        CGFloat rgb_min, rgb_max;
        rgb_min = MIN((int)roundf(rgb.r), (int)roundf(rgb.g));
        rgb_min = MIN(rgb_min, (int)roundf(rgb.b));
        rgb_max = MAX((int)roundf(rgb.r), (int)roundf(rgb.g));
        rgb_max = MAX(rgb_max, (int)roundf(rgb.b));
        
        if (rgb_max == rgb_min) {
            temp_hsv.hue = 0;
        } else if (rgb_max == rgb.r) {
            temp_hsv.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
            temp_hsv.hue = fmodf(temp_hsv.hue, 360.0f);
        } else if (rgb_max == rgb.g) {
            temp_hsv.hue = 60.0f * ((rgb.b - rgb.r) / (rgb_max - rgb_min)) + 120.0f;
        } else if (rgb_max == rgb.b) {
            temp_hsv.hue = 60.0f * ((rgb.r - rgb.g) / (rgb_max - rgb_min)) + 240.0f;
        }
        
        if (temp_hsv.hue > max_hsv1.hue) {
            max_hsv1.hue = temp_hsv.hue;
        }
        if (temp_hsv.hue < min_hsv1.hue) {
            min_hsv1.hue = temp_hsv.hue;
        }
        
        hsv1.hue += temp_hsv.hue;
    }
    
    
    
    for (int col = screenWidth-1; col > screenWidth-101; col--)
    {
        CGRect sourceRect = CGRectMake(col, midHeight, 1.f, 1.f);
        CGImageRef cgImageInRect = CGImageCreateWithImageInRect(cgImage, sourceRect);
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), cgImageInRect);
        CGImageRelease(cgImageInRect);
        CGContextRelease(context);
        rgb.r = rgbBuffer[0];
        rgb.g = rgbBuffer[1];
        rgb.b = rgbBuffer[2];
        temp_hsv.hue = 0;
        CGFloat rgb_min, rgb_max;
        rgb_min = MIN((int)rgb.r, (int)rgb.g);
        rgb_min = MIN(rgb_min, (int)rgb.b);
        rgb_max = MAX((int)rgb.r, (int)rgb.g);
        rgb_max = MAX(rgb_max, (int)rgb.b);
        
        if (rgb_max == rgb_min) {
            temp_hsv.hue = 0;
        } else if (rgb_max == rgb.r) {
            temp_hsv.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
            temp_hsv.hue = fmodf(hsv2.hue, 360.0f);
        } else if (rgb_max == rgb.g) {
            temp_hsv.hue = 60.0f * ((rgb.b - rgb.r) / (rgb_max - rgb_min)) + 120.0f;
        } else if (rgb_max == rgb.b) {
            temp_hsv.hue = 60.0f * ((rgb.r - rgb.g) / (rgb_max - rgb_min)) + 240.0f;
        }
        
        if (temp_hsv.hue > max_hsv2.hue) {
            max_hsv2.hue = temp_hsv.hue;
        }
        if (temp_hsv.hue < min_hsv2.hue) {
            min_hsv2.hue = temp_hsv.hue;
        }
        
        hsv2.hue += temp_hsv.hue;
    }
    
    free(rgbBuffer);
    
    hsv1.hue = 0.005 * hsv1.hue;
    min_hsv1.hue = 0.5 * min_hsv1.hue;
    max_hsv1.hue = 0.5 * max_hsv1.hue;
    
    hsv2.hue = 0.005 * hsv2.hue;
    min_hsv2.hue = 0.5 * min_hsv2.hue;
    max_hsv2.hue = 0.5 * max_hsv2.hue;
    
    NSLog(@"the hsv1 is %f, %f",min_hsv1.hue, max_hsv1.hue);
    NSLog(@"the hsv2 is %f, %f",min_hsv2.hue, max_hsv2.hue);
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
    //[self initNetworkCommunication];
    
    //[self sendString:@"Hello World!"];
}
/*
- (struct hsv_color)HSVfromRGB:(struct rgb_color)rgb
{
    
    
    CGFloat rgb_min, rgb_max;
    rgb_min = MIN((int)roundf(rgb.r), (int)roundf(rgb.g));
    rgb_min = MIN(rgb_min, (int)roundf(rgb.b));
    rgb_max = MAX((int)roundf(rgb.r), (int)roundf(rgb.g));
    rgb_max = MAX(rgb_max, (int)roundf(rgb.b));
    
    if (rgb_max == rgb_min) {
        hsv.hue = 0;
    } else if (rgb_max == rgb.r) {
        hsv.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
        hsv.hue = fmodf(hsv.hue, 360.0f);
    } else if (rgb_max == rgb.g) {
        hsv.hue = 60.0f * ((rgb.b - rgb.r) / (rgb_max - rgb_min)) + 120.0f;
    } else if (rgb_max == rgb.b) {
        hsv.hue = 60.0f * ((rgb.r - rgb.g) / (rgb_max - rgb_min)) + 240.0f;
    }
    hsv.val = rgb_max;
    if (rgb_max == 0) {
        hsv.sat = 0;
    } else {
        hsv.sat = 1.0 - (rgb_min / rgb_max);
    }
    
    return hsv;
}
*/


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
    CGRect cropArea1 = controller.cropArea1;
    CGRect cropArea2 = controller.cropArea2;
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
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"172.24.1.1", 1027, &readStream, &writeStream);
    // NSInputStream *inputStream = ( NSInputStream *)readStream;
    //TODO check this here
    NSOutputStream *outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
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
            uint8_t buffer[64] = {0x41, 0x43, 0x50, 0x54, 0x01};
            /**buffer[5] = (int)roundf(hsv1.hue);
            buffer[6] = (int)floorf(min_hsv1.hue);
            buffer[7] = (int)ceilf(max_hsv1.hue);
            buffer[8] = (int)roundf(hsv2.hue);
            buffer[9] = (int)floorf(min_hsv2.hue);
            buffer[10] = (int)ceilf(max_hsv2.hue);
            **/
            //TD: I need to change here
            int len=1;
            //len = [currentStream write:buffer maxLength:sizeof(buffer)];
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
