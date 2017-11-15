//
//  ViewController.m
//  ios-demo-special-image
//
//  Created by WangDongya on 2017/11/15.
//  Copyright © 2017年 example. All rights reserved.
//

#import "ViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imgView1;
@property (nonatomic, strong) UIImageView *imgView2;
@property (nonatomic, strong) UIImageView *imgView3;
@property (nonatomic, strong) UIImageView *imgView4;
@property (nonatomic, strong) UIImageView *imgView5;
@property (nonatomic, strong) UIImageView *imgView6;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViews];
    [self testConvertMethod];
    [self testImageGrayMethod];
    [self testImageReverseColorMethod1];
    [self testImageReverseColorMethod2];
    [self testImageLightMethod];
}

- (void)initViews
{
    [self.view addSubview:self.imgView1];
    [self.view addSubview:self.imgView2];
    [self.view addSubview:self.imgView3];
    [self.view addSubview:self.imgView4];
    [self.view addSubview:self.imgView5];
    [self.view addSubview:self.imgView6];
    
    // 第一张为原始图片
    [self.imgView1 setImage:[UIImage imageNamed:@"img.jpeg"]];
    
    int width = [UIScreen mainScreen].bounds.size.width;
    
    // 添加约束
    [self.imgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.left.equalTo(self.view).offset(30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    [self.imgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(30);
        make.right.equalTo(self.view).offset(-30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    [self.imgView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView1.mas_bottomMargin).offset(30);
        make.left.equalTo(self.view).offset(30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    [self.imgView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView2.mas_bottomMargin).offset(30);
        make.right.equalTo(self.view).offset(-30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    [self.imgView5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView3.mas_bottomMargin).offset(30);
        make.left.equalTo(self.view).offset(30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    [self.imgView6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView4.mas_bottomMargin).offset(30);
        make.right.equalTo(self.view).offset(-30);
        
        make.width.mas_equalTo((width-90)/2);
        make.height.mas_equalTo((width-90)/2);
    }];
    
}

// 测试美白算法
- (void)testImageLightMethod
{
    UIImage *img = [UIImage imageNamed:@"img.jpeg"];
    unsigned char * data = [self convertUIImage2data:img];
    unsigned char * lightData = [self imageLightWithData:data width:img.size.width height:img.size.height];
    UIImage *lightImg = [self convertData2UIImage:lightData image:img];
    [self.imgView6 setImage:lightImg];
}

// 美白算法：
// 1、最小二乘法曲线拟合
// 2、公式推导
// 3、工具分析：Matlab
// 4、深度学习
// 5、映射表（实现如下：）
- (unsigned char *)imageLightWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height
{
    // 1、分配内存空间 w*h*4
    unsigned char * resultData = malloc(width * height * sizeof(unsigned char) * 4);
    // 为分配的空间初始化，每个都为0
    memset(resultData, 0, width * height * sizeof(unsigned char) * 4);
    NSArray *colorArrayBase = @[@"55", @"110", @"155", @"185", @"220", @"240", @"250", @"255"];
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    int beforeNum = 0;
    for (int i=0; i<8; i++) {
        NSString *numStr = [colorArrayBase objectAtIndex:i];
        int num = numStr.intValue;
        float step = 0;
        if (i==0) {
            step = num / 32.0;
            beforeNum = num;
        } else {
            step = (num - beforeNum) / 32.0;
        }
        for (int j=0; j<32; j++) {
            int newNum = 0;
            if (i==0) {
                newNum = (int)(j*step);
            } else {
                newNum = (int)(beforeNum + j * step);
            }
            NSString *newNumStr = [NSString stringWithFormat:@"%d", newNum];
            [colorArray addObject:newNumStr];
        }
        beforeNum = num;
    }
    for (int h=0; h<height; h++) {
        for (int w=0; w<width; w++) {
            unsigned int imageIndex = h * width + w;
            // 像素RGBA == 4B
            unsigned char bitMapRed = *(imageData + imageIndex * 4);
            unsigned char bitMapGreen = *(imageData + imageIndex * 4 + 1);
            unsigned char bitMapBlue = *(imageData + imageIndex * 4 + 2);
            
            NSString *redStr = [colorArray objectAtIndex:bitMapRed];
            NSString *greenStr = [colorArray objectAtIndex:bitMapGreen];
            NSString *blueStr = [colorArray objectAtIndex:bitMapBlue];
            
            unsigned char newBitMapRed = redStr.intValue;
            unsigned char newBitMapGreen = greenStr.intValue;
            unsigned char newBitMapBlue = blueStr.intValue;
            
            memset(resultData + imageIndex * 4, newBitMapRed, 1);
            memset(resultData + imageIndex * 4 + 1, newBitMapGreen, 1);
            memset(resultData + imageIndex * 4 + 2, newBitMapBlue, 1);
        }
    }
    
    return resultData;
}



- (void)testImageReverseColorMethod2
{
    UIImage *img = [UIImage imageNamed:@"img.jpeg"];
    unsigned char * data = [self convertUIImage2data:img];
    unsigned char * grayData = [self imageGrayWithData:data width:img.size.width height:img.size.height];
    unsigned char * reverseData = [self imageReverseColorWithData:grayData width:img.size.width height:img.size.height];
    UIImage *reverseImg = [self convertData2UIImage:reverseData image:img];
    [self.imgView5 setImage:reverseImg];
}

// 测试彩色底版图像算法
- (void)testImageReverseColorMethod1
{
    UIImage *img = [UIImage imageNamed:@"img.jpeg"];
    unsigned char * data = [self convertUIImage2data:img];
    unsigned char * reverseData = [self imageReverseColorWithData:data width:img.size.width height:img.size.height];
    UIImage *reverseImg = [self convertData2UIImage:reverseData image:img];
    [self.imgView4 setImage:reverseImg];
}

// 彩色底版图像算法(颜色反转：newValue = 255 - oldValue)
- (unsigned char *)imageReverseColorWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height
{
    // 1、分配内存空间 w*h*4
    unsigned char * resultData = malloc(width * height * sizeof(unsigned char) * 4);
    // 为分配的空间初始化，每个都为0
    memset(resultData, 0, width * height * sizeof(unsigned char) * 4);
    for (int h=0; h<height; h++) {
        for (int w=0; w<width; w++) {
            unsigned int imageIndex = h * width + w;
            // 像素RGBA == 4B
            unsigned char bitMapRed = *(imageData + imageIndex * 4);
            unsigned char bitMapGreen = *(imageData + imageIndex * 4 + 1);
            unsigned char bitMapBlue = *(imageData + imageIndex * 4 + 2);
            
            unsigned char newBitMapRed = 255 - bitMapRed;
            unsigned char newBitMapGreen = 255 - bitMapGreen;
            unsigned char newBitMapBlue = 255 - bitMapBlue;
            
            memset(resultData + imageIndex * 4, newBitMapRed, 1);
            memset(resultData + imageIndex * 4 + 1, newBitMapGreen, 1);
            memset(resultData + imageIndex * 4 + 2, newBitMapBlue, 1);
        }
    }
    return resultData;
}

// 测试灰度算法
- (void)testImageGrayMethod
{
    UIImage *img = [UIImage imageNamed:@"img.jpeg"];
    unsigned char * data = [self convertUIImage2data:img];
    unsigned char * grayData = [self imageGrayWithData:data width:img.size.width height:img.size.height];
    UIImage *grayImg = [self convertData2UIImage:grayData image:img];
    [self.imgView3 setImage:grayImg];
}

// 灰度算法：Gray = 0.299 * red + 0.587 * green + 0.114 * blue
// int gray = red * 77 / 255 + green * 151 / 255 + blue * 88 / 255;
- (unsigned char *)imageGrayWithData:(unsigned char * )imageData width:(CGFloat)width height:(CGFloat)height
{
    // 1、分配内存空间 w*h*4
    unsigned char * resultData = malloc(width * height * sizeof(unsigned char) * 4);
    // 为分配的空间初始化，每个都为0
    memset(resultData, 0, width * height * sizeof(unsigned char) * 4);
    for (int h=0; h<height; h++) {
        for (int w=0; w<width; w++) {
            unsigned int imageIndex = h * width + w;
            // 像素RGBA == 4B
            
            unsigned char bitMapRed = *(imageData + imageIndex * 4);
            unsigned char bitMapGreen = *(imageData + imageIndex * 4 + 1);
            unsigned char bitMapBlue = *(imageData + imageIndex * 4 + 2);
            
            // 官方算法
            int bitMap = bitMapRed * 77 / 255 + bitMapGreen * 151 / 255 + bitMapBlue * 88 / 255;
//            int bitMap = (bitMapRed + bitMapGreen + bitMapBlue)/3;
            unsigned char newBitMap = (bitMap > 255) ? 255 : bitMap;
            
            memset(resultData + imageIndex * 4, newBitMap, 1);
            memset(resultData + imageIndex * 4 + 1, newBitMap, 1);
            memset(resultData + imageIndex * 4 + 2, newBitMap, 1);
        }
    }
    
    return resultData;
}


// 测试两个转换函数是否正确
- (void) testConvertMethod
{
    UIImage *img = [UIImage imageNamed:@"img.jpeg"];
    unsigned char * data = [self convertUIImage2data:img];
    UIImage *newImg = [self convertData2UIImage:data image:img];
    [self.imgView2 setImage:newImg];
}

// unsigned char * CoreGraphics
// 1 UIImage -> CGImage
// 2 CGColorSpace
// 3 分配bit级空间
// 4 CGBitmap
// 5 渲染
- (unsigned char *)convertUIImage2data:(UIImage *)image
{
    CGImageRef imageRef = [image CGImage];
    CGSize imageSize = image.size;
    
    // 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 每个像素点 4个Byte R G B A        像素点个数 = 宽*高
    // malloc : 内存分配
    void *data = malloc(imageSize.width * imageSize.height * 4);
    // 1 :
    CGContextRef context = CGBitmapContextCreate(data, imageSize.width, imageSize.height, 8, 4*imageSize.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    //
    CGContextDrawImage(context, CGRectMake(0, 0, imageSize.width, imageSize.height), imageRef);
    // UIImage -> Data
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    return (unsigned char *)data;
}

- (UIImage *)convertData2UIImage:(unsigned char *)data image:(UIImage *)imageSource
{
    CGFloat width = imageSource.size.width;
    CGFloat height = imageSource.size.height;
    NSInteger dataLength = width * height * 4;
    // info
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4*width;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderIntent = kCGRenderingIntentDefault;
    
    // 1 width
    // 2 height
    // 3 每个元素 RGBA
    // 4 每个像素位数bit
    // 5 每行的字节数
    // 6 颜色空间(RGB)
    // 7 描述信息 bitinfo
    // 8 dataProvider (提供的元素数据)
    // 9
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, provider, NULL, NO, renderIntent);
    
    // 创建UIImage
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    
    // 返回newImage
    return newImage;
}

-(UIImageView *)imgView1
{
    if (!_imgView1) {
        _imgView1 = [[UIImageView alloc] init];
        _imgView1.layer.borderColor = [UIColor redColor].CGColor;
        _imgView1.layer.borderWidth = 1;
        _imgView1.layer.cornerRadius = 5;
        _imgView1.clipsToBounds = YES;
    }
    return _imgView1;
}

-(UIImageView *)imgView2
{
    if (!_imgView2) {
        _imgView2 = [[UIImageView alloc] init];
        _imgView2.layer.borderColor = [UIColor redColor].CGColor;
        _imgView2.layer.borderWidth = 1;
        _imgView2.layer.cornerRadius = 5;
        _imgView2.clipsToBounds = YES;
    }
    return _imgView2;
}

-(UIImageView *)imgView3
{
    if (!_imgView3) {
        _imgView3 = [[UIImageView alloc] init];
        _imgView3.layer.borderColor = [UIColor redColor].CGColor;
        _imgView3.layer.borderWidth = 1;
        _imgView3.layer.cornerRadius = 5;
        _imgView3.clipsToBounds = YES;
    }
    return _imgView3;
}

-(UIImageView *)imgView4
{
    if (!_imgView4) {
        _imgView4 = [[UIImageView alloc] init];
        _imgView4.layer.borderColor = [UIColor redColor].CGColor;
        _imgView4.layer.borderWidth = 1;
        _imgView4.layer.cornerRadius = 5;
        _imgView4.clipsToBounds = YES;
    }
    return _imgView4;
}

-(UIImageView *)imgView5
{
    if (!_imgView5) {
        _imgView5 = [[UIImageView alloc] init];
        _imgView5.layer.borderColor = [UIColor redColor].CGColor;
        _imgView5.layer.borderWidth = 1;
        _imgView5.layer.cornerRadius = 5;
        _imgView5.clipsToBounds = YES;
    }
    return _imgView5;
}

-(UIImageView *)imgView6
{
    if (!_imgView6) {
        _imgView6 = [[UIImageView alloc] init];
        _imgView6.layer.borderColor = [UIColor redColor].CGColor;
        _imgView6.layer.borderWidth = 1;
        _imgView6.layer.cornerRadius = 5;
        _imgView6.clipsToBounds = YES;
    }
    return _imgView6;
}

@end
