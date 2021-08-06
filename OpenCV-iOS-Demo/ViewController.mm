//
//  ViewController.m
//  OpenCV-iOS-Demo
//
//  Created by mizu bai on 2021/7/28.
//

#import "ViewController.h"
#import "UIImage+cvMat.h"

#import <Photos/Photos.h>

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(weak, nonatomic) IBOutlet UIImageView *imageView;
@property(weak, nonatomic) IBOutlet UISegmentedControl *imageOperationSegmentedControl;
@property(strong, nonatomic) UIImage *currentImage;
@property(strong, nonatomic) UIImage *sourceImage;

@end

@implementation ViewController

- (void)setSourceImage:(UIImage *)sourceImage {
    _sourceImage = sourceImage;
    _imageView.image = sourceImage;
}

- (void)setCurrentImage:(UIImage *)currentImage {
    _currentImage = currentImage;
    _imageView.image = currentImage;
}

#pragma mark - View did Load

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load Lena
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Lena" ofType:@"jpeg"];
    UIImage *lenaImage = [UIImage imageWithContentsOfFile:path];
    self.sourceImage = lenaImage;
    self.currentImage = lenaImage;
    // Add Tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:tap];
    // Long Press
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveImage)];
    [self.imageView addGestureRecognizer:longPress];
}

#pragma mark - Gesture Recognizer Action

- (void)selectImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)saveImage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Save Image" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {

    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:self.currentImage];
        } completionHandler:^(BOOL success, NSError *error) {

        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:saveAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Image Picker Controller Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.sourceImage = image;
        self.imageOperationSegmentedControl.selectedSegmentIndex = 0;
    }];
}

#pragma mark - Operation Segmented Control

- (IBAction)imageOperationSegmentedControlDidChange:(UISegmentedControl *)sender {
    UIImage *image = self.sourceImage;
    switch (sender.selectedSegmentIndex) {
        case 0: // Source Image
            break;
        case 1: // Gray Image
            image = [self grayImageWith:image];
            break;
        case 2: // Binary Image
            image = [self binaryImageWith:image];
            break;
        case 3: // Blur Image
            image = [self blurImageWith:image];
        default:
            break;
    }
    self.currentImage = image;
}

#pragma mark - Operation

- (UIImage *)grayImageWith:(UIImage *)image {
    cv::Mat srcMat = [UIImage CVMatWithUIImage:image];
    cv::Mat grayMat;
    cv::cvtColor(srcMat,             // src
            grayMat,            // dst
            cv::COLOR_BGR2GRAY, // code
            0);                 // dstCn
    return [UIImage UIImageWithCVMat:grayMat];
}

- (UIImage *)binaryImageWith:(UIImage *)image {
    cv::Mat srcMat = [UIImage CVMatWithUIImage:image];
    cv::Mat grayMat;
    cv::cvtColor(srcMat, grayMat, cv::COLOR_BGR2GRAY, 0);
    cv::Mat binaryMat;
    cv::threshold(grayMat,                              // src
            binaryMat,                            // dst
            127,                                  // thresh
            255,                                  // maxval
            cv::THRESH_BINARY | cv::THRESH_OTSU); // type
    return [UIImage UIImageWithCVMat:binaryMat];
}

- (UIImage *)blurImageWith:(UIImage *)image {
    cv::Mat srcMat = [UIImage CVMatWithUIImage:image];
    cv::Mat blurMat;
    cv::blur(srcMat,          // src
            blurMat,         // dst
            cv::Size(5, 5)); // ksize
    return [UIImage UIImageWithCVMat:blurMat];
}

@end
