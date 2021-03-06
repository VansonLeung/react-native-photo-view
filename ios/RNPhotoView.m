#import "RNPhotoView.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTImageSource.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
#import <React/RCTImageLoader.h>

@interface RNPhotoView()

#pragma mark - View

@property (nonatomic, strong) MWTapDetectingImageView *photoImageView;
@property (nonatomic, strong) MWTapDetectingView *tapView;
@property (nonatomic, strong) UIImageView *loadingImageView;

@property (nonatomic, readwrite) Boolean isInitialZoomIn;

#pragma mark - Data

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *loadingImage;

@end

@implementation RNPhotoView
{
    __weak RCTBridge *_bridge;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge
{
    if ((self = [super init])) {
        _bridge = bridge;
        [self initView];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self refreshPins];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self refreshPins];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}



-(void)recreatePins
{
    int i = 0;
    for (UIView * v in self.photoImageView.subviews)
    {
        [v removeFromSuperview];
    }

    for (NSDictionary * dict in _pins)
    {
        UIImageView * view = [[UIImageView alloc] init];
        view.tag = i + 30000;
        [self.photoImageView addSubview:view];
        
        UILabel * lbl2 = [[UILabel alloc] init];
        lbl2.textColor = [UIColor colorWithRed:206.0f/255.0f green:10.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
        lbl2.textAlignment = NSTextAlignmentCenter;
        lbl2.tag = i + 20000;
        [self.photoImageView addSubview:lbl2];

//        UIButton * btn = [[UIButton alloc] init];
//        btn.tag = i + 10000;
//        [btn addTarget:self action:@selector(onPinCheckBtnEd:) forControlEvents:UIControlEventTouchUpInside];
//        [self.photoImageView addSubview:btn];

        i += 1;
    }
}


-(void)onPinCheckBtnEd:(UIButton*)btn
{
    if (self.onPinClicked)
    {
        self.onPinClicked(@{
                            @"index": @(btn.tag - 10000),
                            @"target": self.reactTag
                            });
    }
}


-(void)refreshPins
{
    int width = 12 + 48 * self.zoomScale;
    int height = 15 + 60 * self.zoomScale;
    int height_lbl = 25 + 50 * self.zoomScale;
    int font_size = 13 + 6 / self.zoomScale;
    
    int i = 0;
    for (NSDictionary * dict in _pins)
    {
        UIImageView * view2 = [self.photoImageView viewWithTag:i + 30000];
        UILabel * lbl2 = [self.photoImageView viewWithTag:i + 20000];
//        UIButton * btn = [self.photoImageView viewWithTag:i + 10000];
        
        NSString * color_label = @"g_d";
        if ([dict[@"color"] isEqualToString:@"green"]) { color_label = @"g_g"; }
        else if ([dict[@"color"] isEqualToString:@"red"]) { color_label = @"g_r"; }
        else if ([dict[@"color"] isEqualToString:@"yellow"]) { color_label = @"g_y"; }
        else if ([dict[@"color"] isEqualToString:@"gray"]) { color_label = @"g_d"; }
        else if ([dict[@"color"] isEqualToString:@"green_sq"]) { color_label = @"s_g"; }
        else if ([dict[@"color"] isEqualToString:@"red_sq"]) { color_label = @"s_r"; }
        else if ([dict[@"color"] isEqualToString:@"yellow_sq"]) { color_label = @"s_y"; }
        else if ([dict[@"color"] isEqualToString:@"gray_sq"]) { color_label = @"s_d"; }

        CGPoint cp2 = CGPointMake([dict[@"x"] floatValue], [dict[@"y"] floatValue]);
        view2.frame = CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale);
        view2.image = [UIImage imageNamed: [NSString stringWithFormat:@"p_%@.png", color_label]];
        
        lbl2.frame = CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height_lbl / self.zoomScale);
        lbl2.font = [UIFont systemFontOfSize:font_size];
        lbl2.textColor = [UIColor colorWithRed:206.0f/255.0f green:10.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
        lbl2.textAlignment = NSTextAlignmentCenter;
        lbl2.text = dict[@"label"];
        
//        btn.frame = CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale);
        
        i += 1;
    }
    
//    self.pinView.transform = CGAffineTransformScale(CGAffineTransformIdentity, self.zoomScale, self.zoomScale);
    
//
//    CGPoint cp = CGPointMake(200, 200);
//    UIImageView * view = [[UIImageView alloc] initWithFrame: CGRectMake(cp.x - (width / self.zoomScale) / 2, cp.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale)];
//    view.image = [UIImage imageNamed:@"ic_map_annotation_green_o.png"];
//    [self.photoImageView addSubview:view];
//
//    CGPoint cp1 = CGPointMake(300, 500);
//    UIImageView * view1 = [[UIImageView alloc] initWithFrame: CGRectMake(cp1.x - (width / self.zoomScale) / 2, cp1.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale)];
//    view1.image = [UIImage imageNamed:@"ic_map_annotation_green_n.png"];
//    [self.photoImageView addSubview:view1];
//
//    CGPoint cp2 = CGPointMake(3000, 1200);
//    UIImageView * view2 = [[UIImageView alloc] initWithFrame: CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale)];
//    view2.image = [UIImage imageNamed:@"ic_map_annotation_red_o.png"];
//    [self.photoImageView addSubview:view2];
//
//    UILabel * lbl2 = [[UILabel alloc] initWithFrame: CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height_lbl / self.zoomScale)];
//    lbl2.font = [UIFont systemFontOfSize:font_size];
//    lbl2.textColor = [UIColor colorWithRed:206.0f/255.0f green:10.0f/255.0f blue:36.0f/255.0f alpha:1.0f];
//    lbl2.textAlignment = NSTextAlignmentCenter;
//    lbl2.text = @"00:30";
//    [self.photoImageView addSubview:lbl2];
//
//    NSLog(@"%lf %lf %lf %lf %lf",
//          [self convertPoint:view2.center toView:self.superview].x * self.zoomScale,
//          [self convertPoint:view2.center toView:self.superview].y * self.zoomScale,
//          [self convertRect:view2.frame toView:self.superview].size.width,
//          [self convertRect:view2.frame toView:self.superview].size.height,
//          self.zoomScale);
//


}




#pragma mark - Tap Detection

- (void)handleDoubleTap:(CGPoint)touchPoint {
    // Zoom
    if (self.zoomScale != self.minimumZoomScale && self.zoomScale != [self initialZoomScaleWithMinScale]) {
        // Zoom out
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        // Zoom in to twice the size
        CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}




- (void) zoomToRect:(CGRect)rect animated:(BOOL)animated
{
    if (!self.isInitialZoomIn)
    {
        self.isInitialZoomIn = true;
        NSLog(@"%lf", self.photoImageView.frame.origin.y);
        rect.origin.y -= self.photoImageView.frame.origin.y * 2;
        rect.origin.y -= [UIApplication sharedApplication].statusBarFrame.size.height * 2;
        [super zoomToRect:rect animated:animated];
    }
    else
    {
        [super zoomToRect:rect animated:animated];
    }
}





#pragma mark - MWTapDetectingImageViewDelegate

// Image View
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:imageView].x;
    CGFloat touchY = [touch locationInView:imageView].y;
    CGFloat originalTouchX = touchX;
    CGFloat originalTouchY = touchY;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    
    int activePinId = -1;
    int i = 0;
    for (NSDictionary * dict in _pins)
    {
        UIImageView * view2 = [self.photoImageView viewWithTag:i + 30000];
        UILabel * lbl2 = [self.photoImageView viewWithTag:i + 20000];
        
        NSLog(@"%lf %lf %lf, %lf", view2.frame.origin.x, view2.frame.origin.y, view2.frame.size.width, view2.frame.size.height);
        
        if (originalTouchX > view2.frame.origin.x
            && originalTouchX < view2.frame.origin.x + view2.frame.size.width
            && originalTouchY > view2.frame.origin.y
            && originalTouchY < view2.frame.origin.y + view2.frame.size.height)
        {
            activePinId = i;
        }
        //        UIButton * btn = [self.photoImageView viewWithTag:i + 10000];
        //        btn.frame = CGRectMake(cp2.x - (width / self.zoomScale) / 2, cp2.y - height / self.zoomScale, width / self.zoomScale, height / self.zoomScale);
        
        i += 1;
    }

    
    if (_onPhotoViewerTap) {
        if (activePinId != -1)
        {
            _onPhotoViewerTap(@{
                                @"point": @{
                                        @"x": @(touchX),
                                        @"y": @(touchY),
                                        },
                                @"target": self.reactTag,
                                @"activePinId": @(activePinId)
                                });
        }
        else
        {
            _onPhotoViewerTap(@{
                                @"point": @{
                                        @"x": @(touchX),
                                        @"y": @(touchY),
                                        },
                                @"target": self.reactTag
                                });
        }
    }
    
    NSLog(@"%lf %lf", touchX, touchY);
}

- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

#pragma mark - MWTapDetectingViewDelegate

// Background View
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    
    if (_onPhotoViewerViewTap) {
        _onPhotoViewerViewTap(@{
                                @"point": @{
                                        @"x": @(touchX),
                                        @"y": @(touchY),
                                        },
                                @"target": self.reactTag,
                                });
    }
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

#pragma mark - Setup

- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
        CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
        // Zooms standard portrait images on a 3.5in screen but not on a 4in screen.
        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = MAX(xScale, yScale);
            // Ensure we don't zoom in or out too far, just in case
            zoomScale = MIN(MAX(self.minimumZoomScale, zoomScale), self.maximumZoomScale);
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail if no image
    if (_photoImageView.image == nil) return;
    
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.image.size;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    
    /**
     [attention]
     original maximumZoomScale and minimumZoomScale is scaled to image,
     but we need scaled to scrollView,
     so has the next convert
     */
    CGFloat maxScale = minScale * _maxZoomScale;
    minScale = minScale * _minZoomScale;
    
    // Set min/max zoom
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
    // Initial zoom
    self.zoomScale = [self initialZoomScaleWithMinScale];
    
    // If we're zooming to fill then centralise
    if (self.zoomScale != minScale) {
        
        // Centralise
        self.contentOffset = CGPointMake((imageSize.width * self.zoomScale - boundsSize.width) / 2.0,
                                         (imageSize.height * self.zoomScale - boundsSize.height) / 2.0);
        
    }
    
    // Disable scrolling initially until the first pinch to fix issues with swiping on an initally zoomed in photo
    self.scrollEnabled = NO;
    
    // Layout
    [self setNeedsLayout];
    
    [self setZoomScale:self.minimumZoomScale animated:YES];
}

#pragma mark - Layout

- (void)layoutSubviews {
    
    // Update tap view frame
    _tapView.frame = self.bounds;
    
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    if (_onPhotoViewerScale) {
        _onPhotoViewerScale(@{
                              @"scale": @(self.zoomScale),
                              @"target": self.reactTag
                              });
    }
}

#pragma mark - Image

// Get and display image
- (void)displayWithImage:(UIImage*)image {
    if (image && !_photoImageView.image) {
        
        // Reset
//        self.maximumZoomScale = 1;
//        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        // Set image
        _photoImageView.image = image;
        _photoImageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = image.size;
        _photoImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        [self setNeedsLayout];
    }
}

#pragma mark - Setter

- (void)setPins:(NSArray *)pins {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([_pins isEqualToArray:pins]) {
            return;
        }

        _pins = pins;
        
        [self recreatePins];
        [self refreshPins];
    });
}



- (void)setActivePin:(NSInteger)index
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _activePin = index - 1;
        if (_activePin >= 0)
        {
            if (_pins.count > _activePin)
            {
                CGFloat newZoomScale = ((self.maximumZoomScale + self.minimumZoomScale) / 2);
                CGFloat xsize = self.bounds.size.width / newZoomScale;
                CGFloat ysize = self.bounds.size.height / newZoomScale;
                NSDictionary * pin = _pins[_activePin];
                [self zoomToRect:
                 CGRectMake(
                            [pin[@"x"] floatValue] - xsize/2,
                            [pin[@"y"] floatValue] - ysize/2,
                            xsize,
                            ysize
                            ) animated:YES];
            }
        }
        
        if (_onPhotoViewerTap) {
            if (_activePin != -1)
            {
                _onPhotoViewerTap(@{
                                    @"target": self.reactTag,
                                    @"activePinId": @(_activePin)
                                    });
            }
        }
        
    });
}



- (void)setSource:(NSDictionary *)source {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([_source isEqualToDictionary:source]) {
            return;
        }
        NSString *uri = source[@"uri"];
        if (!uri) {
            return;
        }
        _source = source;
        NSURL *imageURL = [NSURL URLWithString:uri];
        UIImage *image = RCTImageFromLocalAssetURL(imageURL);
        if (image) { // if local image
            [self setImage:image];
            return;
        }

        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:imageURL];

        __weak RNPhotoView *weakSelf = self;
        if (_onPhotoViewerLoadStart) {
            _onPhotoViewerLoadStart(nil);
        }

        // use default values from [imageLoader loadImageWithURLRequest:request callback:callback] method
        [_bridge.imageLoader loadImageWithURLRequest:request
                                        size:CGSizeZero
                                       scale:1
                                     clipped:YES
                                  resizeMode:RCTResizeModeStretch
                               progressBlock:^(int64_t progress, int64_t total) {
                                   if (_onPhotoViewerProgress) {
                                       _onPhotoViewerProgress(@{
                                           @"loaded": @((double)progress),
                                           @"total": @((double)total),
                                       });
                                   }
                               }
                            partialLoadBlock:nil
                             completionBlock:^(NSError *error, UIImage *image) {
                                                if (image) {
                                                    dispatch_sync(dispatch_get_main_queue(), ^{
                                                        [weakSelf setImage:image];
                                                    });
                                                    if (_onPhotoViewerLoad) {
                                                        _onPhotoViewerLoad(nil);
                                                    }
                                                }
                                                if (_onPhotoViewerLoadEnd) {
                                                    _onPhotoViewerLoadEnd(nil);
                                                }
                                            }];
    });
}

- (void)setLoadingIndicatorSrc:(NSString *)loadingIndicatorSrc {
    if (!loadingIndicatorSrc) {
        return;
    }
    if ([_loadingIndicatorSrc isEqualToString:loadingIndicatorSrc]) {
        return;
    }
    _loadingIndicatorSrc = loadingIndicatorSrc;
    NSURL *imageURL = [NSURL URLWithString:_loadingIndicatorSrc];
    UIImage *image = RCTImageFromLocalAssetURL(imageURL);
    if (image) {
        [self setLoadingImage:image];
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self displayWithImage:_image];
}

- (void)setLoadingImage:(UIImage *)loadingImage {
    _loadingImage = loadingImage;
    if (_loadingImageView) {
        [_loadingImageView setImage:_loadingImage];
    } else {
        _loadingImageView = [[UIImageView alloc] initWithImage:_loadingImage];
        _loadingImageView.center = self.center;
        _loadingImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _loadingImageView.backgroundColor = [UIColor clearColor];
        [_tapView addSubview:_loadingImageView];
    }
}

- (void)setScale:(NSInteger)scale {
    _scale = scale;
    [self setZoomScale:_scale];
}

#pragma mark - Private

- (void)initView {
    _minZoomScale = 1.0;
    _maxZoomScale = 3.0;
    
    // Setup
    self.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    self.delegate = self;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = YES;
    
    // Tap view for background
    _tapView = [[MWTapDetectingView alloc] initWithFrame:self.bounds];
    _tapView.tapDelegate = self;
    _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tapView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    [self addSubview:_tapView];
    
    // Image view
    _photoImageView = [[MWTapDetectingImageView alloc] initWithFrame:self.bounds];
    _photoImageView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    _photoImageView.contentMode = UIViewContentModeCenter;
    _photoImageView.tapDelegate = self;
    [self addSubview:_photoImageView];
}

@end
