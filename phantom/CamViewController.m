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
static const int RECT_OFFSET_ROW = 100;
static const int RECT_OFFSET_COL = 100;
static struct rgb_color rgbColor;

// not using this right now
struct hsv_color hsv;

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
    
    //
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
    
    // extract RGB values
//    CGFloat r = 0;
//    CGFloat g = 0;
//    CGFloat b = 0;
//    CGFloat r_temp = 0;
//    CGFloat g_temp = 0;
//    CGFloat b_temp = 0;
//    CGFloat r_min = 255;
//    CGFloat g_min = 255;
//    CGFloat b_min = 255;
//    CGFloat r_max = 0;
//    CGFloat g_max = 0;
//    CGFloat b_max = 0;
    struct hsv_color temp_hsv;
    temp_hsv.hue = 0;
    temp_hsv.sat = 0;
    temp_hsv.val = 0;
    hsv1.hue = 0;
    min_hsv1.hue = 359;
    max_hsv1.hue = 0;
    struct rgb_color rgb;
    
    


    CGImageRef cgImage = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rgbBuffer = malloc(4);
    for (int col = RECT_OFFSET_COL; col < RECT_OFFSET_COL + 20; col++)
    {
        CGRect sourceRect = CGRectMake(col, 0, 1.f, 1.f);
        CGImageRef cgImageInRect = CGImageCreateWithImageInRect(cgImage, sourceRect);
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), cgImageInRect);
        CGImageRelease(cgImageInRect);
        CGContextRelease(context);
        rgb.r = rgbBuffer[0];
        rgb.g = rgbBuffer[1];
        rgb.b = rgbBuffer[2];
        CGFloat rgb_min, rgb_max;
        rgb_min = MIN((int)rgb.r, (int)rgb.g);
        rgb_min = MIN(rgb_min, (int)rgb.b);
        rgb_max = MAX((int)rgb.r, (int)rgb.g);
        rgb_max = MAX(rgb_max, (int)rgb.b);
        
        if (rgb_max == rgb_min) {
            temp_hsv.hue = 0;
        } else if (rgb_max == rgb.r) {
            temp_hsv.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
            temp_hsv.hue = fmodf(hsv1.hue, 360.0f);
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

//        r += rgbBuffer[0];
//        g += rgbBuffer[1];
//        b += rgbBuffer[2];
        hsv1.hue += temp_hsv.hue;
    }
    free(rgbBuffer);
    
    hsv1.hue = 0.025 * hsv1.hue;
    min_hsv1.hue = 0.5 * min_hsv1.hue;
    max_hsv1.hue = 0.5 * max_hsv1.hue;

//    struct rgb_color rgb;
//    rgb.r = 0.05 * r;
//    rgb.g = 0.05 * g;
//    rgb.b = 0.05 * b;
//    rgbColor.r = 0.05 * r;
//    rgbColor.g = 0.05 * g;
//    rgbColor.b = 0.05 * b;

    // TODO
    // RGB to HSV
    //struct hsv_color hsv = HSVfromRGB(rgb);
    //[hsv HSVfromRGB:rgb];
    
    
    // Save image to photo album
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    
    [self initNetworkCommunication];
    
    [self sendString:@"Hello World!"];
    
    // NSLog(@"send string success");
}


- (struct hsv_color)HSVfromRGB:(struct rgb_color)rgb
{
    
    
    CGFloat rgb_min, rgb_max;
    rgb_min = MIN((int)rgb.r, (int)rgb.g);
    rgb_min = MIN(rgb_min, (int)rgb.b);
    rgb_max = MAX((int)rgb.r, (int)rgb.g);
    rgb_max = MAX(rgb_max, (int)rgb.b);
    
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



- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"172.24.1.1", 1027, &readStream, &writeStream);
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
            uint8_t buffer[64] = {0x41, 0x43, 0x50, 0x54, 0x01};
            buffer[5] = (int)roundf(hsv1.hue);
            buffer[6] = (int)floorf(min_hsv1.hue);
            buffer[7] = (int)ceilf(max_hsv1.hue);
            buffer[8] = (int)roundf(hsv2.hue);
            buffer[9] = (int)floorf(min_hsv2.hue);
            buffer[10] = (int)ceilf(max_hsv2.hue);
            
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
