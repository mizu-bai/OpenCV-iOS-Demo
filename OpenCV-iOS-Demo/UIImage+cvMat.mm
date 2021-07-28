//
// Created by mizu bai on 2021/7/28.
//

#import "UIImage+cvMat.h"


@implementation UIImage (cvMat)

+ (cv::Mat)CVMatWithUIImage:(UIImage *)image {
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;

    cv::Mat cvMat(static_cast<int>(rows), static_cast<int>(cols), CV_8UC4);

    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                                             // data
                                                    static_cast<size_t>(cols),                              // width
                                                    static_cast<size_t>(rows),                              // height
                                                    8,                                                      // bitsPerComponent
                                                    cvMat.step[0],                                          // bytesPerRow
                                                    colorSpaceRef,                                          // space
                                                    kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault); // bitmapInfo

    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

+ (UIImage *)UIImageWithCVMat:(cv::Mat)cvMat {
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGColorSpaceRef colorSpaceRef = cvMat.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef providerRef = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    bool alpha = cvMat.channels() == 4;
    CGBitmapInfo bitMapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;

    CGImageRef imageRef = CGImageCreate(static_cast<size_t>(cvMat.cols), // width
                                        static_cast<size_t>(cvMat.rows), // height
                                        8,                               // bitsPerComponent
                                        8 * cvMat.elemSize(),            // bitsPerPixel
                                        cvMat.step[0],                   // bytesPerRow
                                        colorSpaceRef,                   // space
                                        bitMapInfo,                      // bitmapInfo
                                        providerRef,                     // provider
                                        NULL,                            // decode
                                        false,                           // shouldInterpolate
                                        kCGRenderingIntentDefault);      // intent

    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(providerRef);
    CGColorSpaceRelease(colorSpaceRef);
    return image;
}


@end