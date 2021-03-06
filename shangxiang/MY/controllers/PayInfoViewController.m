//
//  PayInfoViewController.m
//  shangxiang
//
//  Created by 倾慕 on 15/1/31.
//  Copyright (c) 2015年 倾慕. All rights reserved.
//

#import "PayInfoViewController.h"
#import "DiscoverManager.h"
#import "OrderInfoObject.h"
#import "ShareViewController.h"
#import "GradeInfoObject.h"
#import "ListTempleManager.h"

#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "DataVerifier.h"

@interface PayInfoViewController ()

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) OrderInfoObject* infoObject;
@property (nonatomic, strong) UILabel* wishGradeLabel;

@end

@implementation PayInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"支付";
    self.view.backgroundColor = UIColorFromRGB(COLOR_BG_NORMAL);
    [self setupForDismissKeyboard];
    
    [self loadData];
}

- (void)setup
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    [_scrollView setScrollEnabled:YES];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [_scrollView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_scrollView];
    
    UILabel* orderNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, self.view.width - 40, 20)];
    [orderNumberLabel setNumberOfLines:1];
    [orderNumberLabel setBackgroundColor:[UIColor clearColor]];
    [orderNumberLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [orderNumberLabel setFont:[UIFont systemFontOfSize:14]];
    [orderNumberLabel setTextColor:UIColorFromRGB(0xbababa)];
    [orderNumberLabel setText:[NSString stringWithFormat:@"订单号 : %@",self.infoObject.orderId]];
    [_scrollView addSubview:orderNumberLabel];
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, orderNumberLabel.bottom + 5, self.view.width - 40, 20)];
    [nameLabel setNumberOfLines:1];
    [nameLabel setBackgroundColor:[UIColor clearColor]];
    [nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [nameLabel setFont:[UIFont systemFontOfSize:16]];
    [nameLabel setTextColor:UIColorFromRGB(0x767676)];
    [nameLabel setText:[NSString stringWithFormat:@"%@   %@%@",self.infoObject.wishName,self.infoObject.alsoWish,self.infoObject.wishType]];
    [_scrollView addSubview:nameLabel];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, nameLabel.bottom + 5, self.view.width, 0.5)];
    [lineView setBackgroundColor:UIColorFromRGB(COLOR_LINE_NORMAL)];
    [_scrollView addSubview:lineView];
    
    UILabel* templeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, lineView.bottom + 10, (self.view.width - 40) / 2, 20)];
    [templeNameLabel setNumberOfLines:1];
    [templeNameLabel setBackgroundColor:[UIColor clearColor]];
    [templeNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [templeNameLabel setFont:[UIFont systemFontOfSize:14]];
    NSMutableAttributedString* templeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"寺庙: %@",self.infoObject.templeName]];
    [templeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 4)];
    [templeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 4)];
    [templeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(4, self.infoObject.templeName.length)];
    [templeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(4, self.infoObject.templeName.length)];
    [templeNameLabel setAttributedText:templeString];
    [_scrollView addSubview:templeNameLabel];
    
    
    UILabel* attchNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 120, lineView.bottom + 10, 100, 20)];
    [attchNameLabel setNumberOfLines:1];
    [attchNameLabel setBackgroundColor:[UIColor clearColor]];
    [attchNameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [attchNameLabel setFont:[UIFont systemFontOfSize:14]];
    
    NSMutableAttributedString* attchString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"法师: %@",self.infoObject.builddhistName]];
    [attchString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 4)];
    [attchString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 4)];
    [attchString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(4, self.infoObject.builddhistName.length)];
    [attchString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(4, self.infoObject.builddhistName.length)];
    
    [attchNameLabel setAttributedText:attchString];
    [_scrollView addSubview:attchNameLabel];
    
    
    
    _wishGradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, templeNameLabel.bottom + 5, (self.view.width - 40) / 2, 20)];
    [_wishGradeLabel setNumberOfLines:1];
    [_wishGradeLabel setBackgroundColor:[UIColor clearColor]];
    [_wishGradeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [_wishGradeLabel setFont:[UIFont systemFontOfSize:14]];
    NSMutableAttributedString* wishGradeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"香烛: %@",self.infoObject.wishGrade]];
    [wishGradeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 4)];
    [wishGradeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 4)];
    [wishGradeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(4, self.infoObject.wishGrade.length)];
    [wishGradeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(4, self.infoObject.wishGrade.length)];
    [_wishGradeLabel setAttributedText:wishGradeString];
    [_scrollView addSubview:_wishGradeLabel];
    
    
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.width - 120, templeNameLabel.bottom + 5, 100, 20)];
    [dateLabel setNumberOfLines:1];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [dateLabel setFont:[UIFont systemFontOfSize:14]];
    
    NSMutableAttributedString* dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"时间: %@",self.infoObject.wishDate]];
    [dateString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 4)];
    [dateString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 4)];
    [dateString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(4, self.infoObject.wishDate.length)];
    [dateString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(4, self.infoObject.wishDate.length)];
    
    [dateLabel setAttributedText:dateString];
    [_scrollView addSubview:dateLabel];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dateLabel.bottom + 10, self.view.width, 0.5)];
    [lineView setBackgroundColor:UIColorFromRGB(COLOR_LINE_NORMAL)];
    [_scrollView addSubview:lineView];
    
    
    UIView* contentLabelView = [[UIView alloc] initWithFrame:CGRectMake(15, lineView.bottom, self.view.width - 40, 75)];
    [contentLabelView setBackgroundColor:[UIColor clearColor]];
    [_scrollView addSubview:contentLabelView];
    
    UITextView* textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, contentLabelView.width, contentLabelView.height)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setFont:[UIFont systemFontOfSize:15]];
    
    if(self.infoObject.wishText && self.infoObject.wishText.length > 0)
    {
        NSMutableAttributedString* contentString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"祈求内容: %@",self.infoObject.wishText]];
        
        [contentString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 6)];
        [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 6)];
        [contentString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(6, self.infoObject.wishText.length)];
        [contentString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(6, self.infoObject.wishText.length)];
        
        
        [textView setAttributedText:contentString];
    }
    [contentLabelView addSubview:textView];
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, contentLabelView.bottom + 10, self.view.width, 0.5)];
    [lineView setBackgroundColor:UIColorFromRGB(COLOR_LINE_NORMAL)];
    [_scrollView addSubview:lineView];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(25, lineView.bottom + 20, 100, 40)];
    [imageView setImage:[UIImage imageForKey:@"alipay"]];
    [_scrollView addSubview:imageView];
    
    UIButton* buttonSubmitCreateOrder = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 125, lineView.bottom + 20, 100, 40)];
    [buttonSubmitCreateOrder setTitle:@"支付" forState:UIControlStateNormal];
    [buttonSubmitCreateOrder setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [buttonSubmitCreateOrder setBackgroundColor:UIColorFromRGB(COLOR_FORM_BG_BUTTON_NORMAL)];
    [buttonSubmitCreateOrder setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(COLOR_FORM_BG_BUTTON_HIGHLIGHT)] forState:UIControlStateHighlighted];
    [buttonSubmitCreateOrder addTarget:self action:@selector(submitCreateOrder) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:buttonSubmitCreateOrder];
        
}

- (void)submitCreateOrder
{
    if(self.price == 0)
    {
        ShareViewController* shareViewController = [[ShareViewController alloc] init];
        shareViewController.orderId = self.orderId;
        [self.navigationController pushViewController:shareViewController animated:YES];
    }
    else
    {
        [self pay];
    }
}

- (void)pay
{
    /*
     *商户的唯一的parnter和seller。
     *签约后，支付宝会为每个商户分配一个唯一的 parnter 和 seller。
     */
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *partner = @"2088811642353234";
    NSString *seller = @"nanjingshangxiang@qq.com";
    NSString *privateKey = @"MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMt8tZKMTk9zpxox6/SYVPWExWSdOZIhj2B5MEqkSM5WcoqQvgJkp9X3acNYD7W/65o4iS1P5AcFyzb/7dV9AQCUxs2xZNVUVoenleessDNTtUO6Ngah4xit/zRaslHRa0KMFLxDBerJeVNDR05YSXMYSRhBH3CZh6ZDYwdmUOwjAgMBAAECgYEAhaEqJEkbjDWpARzTlVcMRAejEYXmrr53R6WOPxZP8aD3q2OOREgRqAPIYs5L0tFsSWTjQOx8FNiLMV00tMRYiPnxTlb4xKqDr+NJPxW58kNOrA361VXN5ctKCmUxaeHik3FdS6aRIuOeWL2HBH8EdOeywqEc16q2sjl/JcdxcjECQQD72M/23jaPZE90Bmi65f0SJv7mxKgV1sbwBV7GEs8Ynjyge+I/vEU4qFbjCqKn9HmI6CypSfXcopEfrIOrCWgPAkEAzte+OUCWfl/Or5YYoQ3qLsD2poEvDXZg8E+S8O3LfB1Bwoat/yq1D/JOQpGTWTJSJvEIN3zShkap51SKI+bGrQJBANNf1KQRO1+8REdQPcRn1bDPk+9hrOWvfwbiqvm5vaGe5amYcHsn7D0yZMJoIb6vnPXAUAPB9J26v+0CoPwDiBcCQAYt/+rp+RURe7VXQKkfJ036SeQzm9pFHSRQ3E0Cbb/ph9tt9qjW983gKWJnwwU5MackMGCoBAoq9kyJBA+Kh4kCQAyT8A0icweqKwKCgd8K0xQjr1BLb1Vkah06qMkhW7GFkk9FmHdusu5KKgjpxF+GSH6fCa2NXPoTS6QpMmmcc28=";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
    order.tradeNO = self.orderId; //订单ID（由商家自行制定）
    order.productName = @"上香"; //商品标题
    order.productDescription = @"上香"; //商品描述
    order.amount = [NSString stringWithFormat:@"%.2f",self.price]; //商品价格
    order.notifyURL =  @"http://demo123.shangxiang.com/api/app_alipay/notify_url.php"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"shangxiangAirplay";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        __weak typeof(self) weakSelf = self;
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSInteger statusCode = [[resultDic objectForKey:@"resultStatus"] integerValue];
            if(statusCode == 9000)
            {
                ShareViewController* shareViewController = [[ShareViewController alloc] init];
                shareViewController.orderId = weakSelf.orderId;
                [weakSelf.navigationController pushViewController:shareViewController animated:YES];
            }
            else if (statusCode == 4000)
            {
                [weakSelf showTimedHUD:YES message:@"订单已支付"];
                //订单已支付
            }else if (statusCode == 6001)
            {
                //取消支付
                [weakSelf showTimedHUD:YES message:@"取消支付"];
            }
            else
            {
                [weakSelf showTimedHUD:YES message:@"交易失败"];
            }
        }];
        
    }
}


- (void)loadData
{
    [self showChrysanthemumHUD:YES];
    __weak typeof(self) weakSelf = self;
    
    [DiscoverManager getOrderInfo:self.orderId successBlock:^(id obj) {
        [weakSelf removeAllHUDViews:YES];
        weakSelf.infoObject = obj;
        [weakSelf setup];
        [weakSelf getGradInfo];
    } failed:^(id error) {
        [weakSelf removeAllHUDViews:YES];
        [weakSelf dealWithError:error];
    }];
}

- (void)getGradInfo
{
    __weak typeof(self) weakSelf = self;
    [ListTempleManager getGradeInfo:^(id obj) {
        NSMutableArray* gradeArray = (NSMutableArray*)obj;
        for(GradeInfoObject* info in gradeArray)
        {
            if([info.gradeName isEqualToString:weakSelf.infoObject.wishGrade])
            {
                NSString* text = [NSString stringWithFormat:@"香烛: %@  ￥%zd",weakSelf.infoObject.wishGrade,info.gradePrice];
                NSMutableAttributedString* wishGradeString = [[NSMutableAttributedString alloc] initWithString:text];
                [wishGradeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xbababa) range:NSRangeMake(0, 4)];
                [wishGradeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSRangeMake(0, 4)];
                [wishGradeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x808080) range:NSRangeMake(4, self.infoObject.wishGrade.length)];
                [wishGradeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSRangeMake(4, self.infoObject.wishGrade.length)];
                [wishGradeString addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(COLOR_FORM_BG_BUTTON_HIGHLIGHT) range:[text rangeOfString:[NSString stringWithFormat:@"￥%zd",info.gradePrice]]];
                [weakSelf.wishGradeLabel setAttributedText:wishGradeString];
            }
        }
    } failed:^(id error) {
        
    }];
}

- (void)goBack
{
    [APPNAVGATOR turnToOrderRecordPage];
}

@end
