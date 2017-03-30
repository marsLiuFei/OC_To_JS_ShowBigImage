//
//  LFShowWebViewPicViewController.m
//  OC_VS_JS
//
//  Created by apple on 2017/3/30.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "LFShowWebViewPicViewController.h"
#import "UIImageView+WebCache.h"

@interface LFShowWebViewPicViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>
@property (strong,nonatomic) UIWebView *webView;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (strong,nonatomic) UIView *bgView;

@property (strong,nonatomic) NSMutableArray *mUrlArray;
@property (strong,nonatomic) NSString *imageUrl;
@end


#define WIDTH  self.view.frame.size.width
#define HEIGHT self.view.frame.size.height




@implementation LFShowWebViewPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setWebView];
}

- (void) setWebView{
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self.view addSubview:self.webView];
    self.webView.delegate =self;
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.webView setScalesPageToFit:YES];
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    [self.webView sizeToFit];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //这里是js，主要目的实现对url的获取
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    imgScr = imgScr + objs[i].src + '+';\
    \
    objs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    };\
    return imgScr;\
    };";
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    NSString *urlResurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];
    _mUrlArray = [NSMutableArray arrayWithArray:[urlResurlt componentsSeparatedByString:@"+"]];
 //    NSLog(@"%@",_mUrlArray);
    //urlResurlt 就是获取到得所有图片的url的拼接；mUrlArray就是所有Url的数组
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    //将url转换为string
    NSString *requestString = [[request URL] absoluteString];
    //hasPrefix 判断创建的字符串内容是否以pic:字符开始
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        _imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        //获取当前图片的url在整个链接地址中位置
        NSInteger index = [_mUrlArray indexOfObject:_imageUrl];
        
        if (self.bgView) {
            //设置不隐藏，还原放大缩小，显示图片
            self.bgView.hidden = NO;
            self.bgView.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
            self.scrollView.contentOffset = CGPointMake(WIDTH*index, 0);
        } else{
            [self showBigImage:_mUrlArray atIndex:index];//创建视图并显示图片
        }
        return NO;
    }
    return YES;
}
#pragma mark 显示大图片
- (void)showBigImage:(NSArray *)imageUrls atIndex:(NSInteger )index{
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self.bgView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [[UIApplication sharedApplication].keyWindow addSubview:self.bgView];
    //创建灰色透明背景，使其背后内容不可操作
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self.scrollView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    self.scrollView.delegate = self;
    // 是否分页
    self.scrollView.pagingEnabled = YES;
    //禁止垂直滚动
  //  self.scrollView.showsVerticalScrollIndicator = YES;
    //设置分页
    self.scrollView.pagingEnabled = YES;
    // 设置内容大小
    self.scrollView.contentSize = CGSizeMake(WIDTH*imageUrls.count,HEIGHT);
    [self.bgView addSubview:self.scrollView];
    //创建关闭按钮
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(removeBigImage) forControlEvents:UIControlEventTouchUpInside];
    [closeBtn setFrame:CGRectMake(WIDTH-50, 25, 25, 25)];
    [self.bgView addSubview:closeBtn];
    for (int i= 0; i<imageUrls.count; i++) {
        UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        
        UIScrollView *s = [[UIScrollView alloc]initWithFrame:CGRectMake(WIDTH*i,0,WIDTH, HEIGHT)];
        s.bounces = NO;
        s.backgroundColor = [UIColor clearColor];
        s.contentSize =CGSizeMake(WIDTH,HEIGHT);
        s.delegate =self;
        s.minimumZoomScale =1.0;
        s.maximumZoomScale =3.0;
        //        s.tag = i+1;
        [s setZoomScale:1.0];
        UIImageView *imageview = [[UIImageView alloc]initWithFrame:CGRectMake(0,0,WIDTH, HEIGHT)];
        //加载图片的时候  最好设置一个网络错误的预设图片
        [imageview sd_setImageWithURL:imageUrls[i]];
        imageview.contentMode = UIViewContentModeScaleAspectFit;
        imageview.userInteractionEnabled =YES;
        imageview.tag = i+1;
        [imageview addGestureRecognizer:doubleTap];
        [s addSubview:imageview];
        [self.scrollView addSubview:s];
    }
    self.scrollView.contentOffset = CGPointMake(WIDTH*index, 0);
    
}


#pragma mark - ScrollView delegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (UIView *v in scrollView.subviews){
        return v;
    }
    return nil;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView ==self.scrollView){
//        CGFloat x = scrollView.contentOffset.x;
        for (UIScrollView *s in scrollView.subviews){
            if ([s isKindOfClass:[UIScrollView class]]){
                [s setZoomScale:1.0]; //scrollView每滑动一次将要出现的图片较正常时候图片的倍数（将要出现的图片显示的倍数）
            }
        }
    }
}

#pragma mark - 双击图片放大的逻辑
-(void)handleDoubleTap:(UIGestureRecognizer *)gesture{
    float newScale = [(UIScrollView*)gesture.view.superview zoomScale] * 1.5;//每次双击放大倍数
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [(UIScrollView*)gesture.view.superview zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =self.view.frame.size.height / scale;
    zoomRect.size.width  =self.view.frame.size.width  / scale;
    //双击图片的时候 以整个屏幕中心为基点 调整放大后的图片的原点位置
    zoomRect.origin.x = self.scrollView.center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = self.scrollView.center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}
- (void)removeBigImage
{
    self.bgView.hidden = YES;
}



/*
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
 {
 if(interfaceOrientation ==UIInterfaceOrientationPortrait||interfaceOrientation ==UIInterfaceOrientationPortraitUpsideDown)
 {
 return YES;
 }
 return NO;
 }
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
