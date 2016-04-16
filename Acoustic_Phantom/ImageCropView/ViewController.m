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
//static const int RECT1_OFFSET_ROW = 10;
//static const int RECT1_OFFSET_COL = 10;
//static const int RECT2_OFFSET_ROW = -1;
//static const int RECT2_OFFSET_COL = -1;
static struct rgb_color rgb;
static struct rgb_color debug_rgb;
static int width;
static int height;

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
    struct hsv_color temp_hsv2;
    temp_hsv2.hue = 0;
    //    temp_hsv.sat = 0;
    //    temp_hsv.val = 0;
    hsv1.hue = 0;
    min_hsv1.hue = 359;
    max_hsv1.hue = 0;
    hsv2.hue = 0;
    min_hsv2.hue = 359;
    max_hsv2.hue = 0;
    //struct rgb_color rgb;
    
    
    image = [image fixOrientation];
    
    CGImageRef cgImage = [image CGImage];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rgbBuffer = malloc(4);
    unsigned char *debug_rgbBuffer = malloc(4);
    unsigned char *rgbBuffer1 = malloc(4);
    unsigned char *debug_rgbBuffer1 = malloc(4);
    unsigned char *rgbBuffer2 = malloc(4);
    unsigned char *debug_rgbBuffer2 = malloc(4);
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    size_t imageWidth = CGImageGetWidth(cgImage);
    size_t imageHeight = CGImageGetHeight(cgImage);
    int midHeight = (int)(screenHeight * 0.5);
    for (int col = 0; col < 10; col++)
    {
        //        NSLog(@"width = %d",imageWidth);
        //        NSLog(@"height = %d",imageHeight);
        CGRect sourceRect = CGRectMake(col,0 * imageHeight, 1.f, 1.f);
        //        CGRect debug_sourceRect = CGRectMake(col, midHeight, 1.f, 1.f);
        CGImageRef cgImageInRect = CGImageCreateWithImageInRect(cgImage, sourceRect);
        //        CGImageRef debug_cgImageInRect = CGImageCreateWithImageInRect(cgImage, debug_sourceRect);
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        //        CGContextRef debug_context = CGBitmapContextCreate(debug_rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), cgImageInRect);
        //        CGContextDrawImage(debug_context, CGRectMake(0.f, 0.f, 1.f, 1.f), debug_cgImageInRect);
        
        rgb.r = rgbBuffer[0];
        rgb.g = rgbBuffer[1];
        rgb.b = rgbBuffer[2];
        //        debug_rgb.r = debug_rgbBuffer[0];
        //        debug_rgb.g = debug_rgbBuffer[1];
        //        debug_rgb.b = debug_rgbBuffer[2];
        
        NSLog(@"upperleft  r: %f, g: %f, b: %f",rgb.r,rgb.g,rgb.b);
        //        NSLog(@"lowerleft  r: %f, g: %f, b: %f",debug_rgb.r, debug_rgb.g, debug_rgb.b);
        
        
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
    
    //    free(rgbBuffer);
    
    for (int col = 0; col < 10; col++)
    {
        CGRect sourceRect = CGRectMake(imageWidth-10, 0*imageHeight, 1.f, 1.f);
        CGImageRef cgImageInRect = CGImageCreateWithImageInRect(cgImage, sourceRect);
        CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
        CGContextRef context = CGBitmapContextCreate(rgbBuffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
        CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), cgImageInRect);
        //        CGImageRelease(cgImageInRect);
        //        CGContextRelease(context);
        
        rgb.r = rgbBuffer[0];
        rgb.g = rgbBuffer[1];
        rgb.b = rgbBuffer[2];
        NSLog(@" r: %f, g: %f, b: %f",rgb.r,rgb.g,rgb.b);
        temp_hsv2.hue = 0;
        CGFloat rgb_min, rgb_max;
        rgb_min = MIN((int)roundf(rgb.r), (int)roundf(rgb.g));
        rgb_min = MIN(rgb_min, (int)roundf(rgb.b));
        rgb_max = MAX((int)roundf(rgb.r), (int)roundf(rgb.g));
        rgb_max = MAX(rgb_max, (int)roundf(rgb.b));
        
        if (rgb_max == rgb_min) {
            temp_hsv2.hue = 0;
        } else if (rgb_max == rgb.r) {
            temp_hsv2.hue = 60.0f * ((rgb.g - rgb.b) / (rgb_max - rgb_min));
            temp_hsv2.hue = fmodf(temp_hsv2.hue, 360.0f);
        } else if (rgb_max == rgb.g) {
            temp_hsv2.hue = 60.0f * ((rgb.b - rgb.r) / (rgb_max - rgb_min)) + 120.0f;
        } else if (rgb_max == rgb.b) {
            temp_hsv2.hue = 60.0f * ((rgb.r - rgb.g) / (rgb_max - rgb_min)) + 240.0f;
        }
        
        if (temp_hsv2.hue > max_hsv2.hue) {
            max_hsv2.hue = temp_hsv2.hue;
        }
        if (temp_hsv2.hue < min_hsv2.hue) {
            min_hsv2.hue = temp_hsv2.hue;
        }
        
        hsv2.hue += temp_hsv2.hue;
    }
    
    
    
    hsv1.hue = MAX(0.05 * hsv1.hue, 0);
    min_hsv1.hue = MAX(0, hsv1.hue-5);
    max_hsv1.hue = MIN(hsv1.hue+5, 179);
    //    min_hsv1.hue = 0.5 * min_hsv1.hue;
    //    max_hsv1.hue = 0.5 * max_hsv1.hue;
    
    hsv2.hue = 0.05 * hsv2.hue;
    //    min_hsv2.hue = 0.5 * min_hsv2.hue;
    //    max_hsv2.hue = 0.5 * max_hsv2.hue;
    min_hsv2.hue = MAX(0, hsv2.hue-5);
    max_hsv2.hue = MIN(hsv2.hue+5, 179);
    
    NSLog(@"hue = %f", hsv1.hue);
    NSLog(@"hue = %f", hsv2.hue);
    
    
    // Save image to photo album
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // Take image picker off the screen -
    // you must call this dismiss method
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    [self initNetworkCommunication];
    
    [self sendString:@"Hello World!"];
    
    // NSLog(@"send string success");
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
            buffer[5] = (int)roundf(hsv1.hue);
            buffer[6] = (int)floorf(min_hsv1.hue);
            buffer[7] = (int)ceilf(max_hsv1.hue);
            buffer[8] = (int)roundf(hsv2.hue);
            buffer[9] = (int)floorf(min_hsv2.hue);
            buffer[10] = (int)ceilf(max_hsv2.hue);

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

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
@end
