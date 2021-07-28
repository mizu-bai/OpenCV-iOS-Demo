//
//  ViewController.m
//  OpenCV-iOS-Demo
//
//  Created by mizu bai on 2021/7/28.
//

#import "ViewController.h"
#import "UIImage+cvMat.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *imageOperationSegmentedContorol;
@property (strong, nonatomic) UIImage *image;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Load Lena
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Lena" ofType:@"jpg"];
    UIImage *lenaImage = [UIImage imageWithContentsOfFile:path];
    self.imageView.image = lenaImage;
    self.image = lenaImage;
    // Add Tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectImage)];
    [self.imageView setUserInteractionEnabled:YES];
    [self.imageView addGestureRecognizer:tap];
}

- (void)selectImage {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:^{
        self.image = image;
        self.imageView.image = image;
        self.imageOperationSegmentedContorol.selectedSegmentIndex = 0;
    }];
}

- (IBAction)imageOperationSegmentedControlDidChange:(UISegmentedControl *)sender {
    UIImage *image = self.image;
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
    self.imageView.image = image;
}

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
