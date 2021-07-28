//
// Created by mizu bai on 2021/7/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (cvMat)

+ (cv::Mat)CVMatWithUIImage:(UIImage *)image;

+ (UIImage *)UIImageWithCVMat:(cv::Mat)cvMat;

@end