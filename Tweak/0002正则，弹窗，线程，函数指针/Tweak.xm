#import <Foundation/Foundation.h>
#import <substrate.h>
#import <BADataEntity.h>
#import <pthread.h>


// 评论间隔，秒
unsigned long g_comment_sleep_second = 5;
// 评论文章总数
unsigned long g_CommentCount = 12;

unsigned long g_ThreadRunCount = 0;
unsigned long g_postCommentWithArticleId_self = 0;
unsigned long g_postCommentWithArticleId_SEL = 0;
void (*g_fn_postCommentWithArticleId)(unsigned long self, unsigned long SEL, NSString* articleId, NSString* content, id ReplyId, id IndexPath, id ParentIndexPath, id TableView) = NULL; 	


// hook 这里，获取类的实例，后面调用这个类的函数时会用到
//CNPageDetailWebViewController.h:133:- (void)postCommentWithArticleId:(id)arg1 Content:(id)arg2 ReplyId:(id)arg3 IndexPath:(id)arg4 ParentIndexPath:(id)arg5 TableView:(id)arg6;
%hook CNPageDetailWebViewController
- (void)postCommentWithArticleId:(id)arg1 Content:(id)arg2 ReplyId:(id)arg3 IndexPath:(id)arg4 ParentIndexPath:(id)arg5 TableView:(id)arg6
{
    unsigned long reg_x0 = 0;
    unsigned long reg_x1 = 0;
    unsigned long reg_x2 = 0;
    unsigned long reg_x3 = 0;
    __asm__ volatile(
            "mov %[RegX0], x0 \t\n"
            "mov %[RegX1], x1 \t\n"
            "mov %[RegX2], x2 \t\n"
            "mov %[RegX3], x3 \t\n"
            :[RegX0]"=r"(reg_x0), [RegX1]"=r"(reg_x1), [RegX2]"=r"(reg_x2), [RegX3]"=r"(reg_x3)
            );
    NSLog(@"luzy: %s, x0 = %lx, x1 = %lx, x2 = %lx, x3 = %lx", "postCommentWithArticleId", reg_x0, reg_x1, reg_x2, reg_x3);

    g_postCommentWithArticleId_self = reg_x0;
    g_postCommentWithArticleId_SEL = reg_x1;

    NSLog(@"luzy : %s, %@, %@, %@, %@, %@, %@", "getBlogPostCommentWithArticleId", arg1, arg2, arg3, arg4, arg5, arg6);
    return %orig(arg1, arg2, arg3, arg4, arg5, arg6);
}
%end


// 正则，获取匹配部分字符串
NSArray* matchStringtoRegexString(NSString *string, NSString *regexStr)
{

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:nil];

    NSArray * matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];

    //match: 所有匹配到的字符,根据() 包含级

    NSMutableArray *array = [NSMutableArray array];

    for (NSTextCheckingResult *match in matches) {

        for (int i = 0; i < [match numberOfRanges]; i++) {
            //以正则中的(),划分成不同的匹配部分
            NSString *component = [string substringWithRange:[match rangeAtIndex:i]];

            [array addObject:component];

        }

    }

    return array;
}


// 文章的前三条评论，没有我们的，走增加逻辑
void addCommentInTop3(unsigned long index, NSString* articleUrl, NSString* articleId, NSString* comment)
{
    sleep(g_comment_sleep_second);

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:articleUrl]
        completionHandler:^(NSData *data,
                NSURLResponse *response,
                NSError *error) {

            NSString* dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"luzy");
            NSLog(@"luzy");
            //NSLog(@"luzy handle articleUrl = %@, len = %ld, data = %@", articleUrl, [dataStr length], dataStr);     //就这么简单，到这里就完成了，str就是网页内容
            NSLog(@"luzy handle articleUrl = %@", articleUrl);     //就这么简单，到这里就完成了，str就是网页内容
            NSString* pattern = [NSString stringWithFormat:@"%@%@%@", @"<li>[\\s\\S]*?<a class=\"title text-truncate\" target=\"_blank\" href=\".+?", articleId, @".+?\">.+?</a>[\\s\\S]*?<p class=\"comment ellipsis\">[\\s\\S]*?<a href=\".+?\" class=\"user-name\" target=\"_blank\">.+?：</a>(.+?)</p>[\\s\\S]*?</li>"];
            NSArray *array =  matchStringtoRegexString(dataStr, pattern);
            //NSLog(@"luzy array = %@", array);
            NSLog(@"luzy array.count = %ld", array.count);
            if (array) {
                bool isFindYunduo = false;
                int count = array.count > 6 ? 6 : array.count;
                for (int i = 1; i<count; i=i+2) {
                    NSLog(@"luzy comment[%d] = %@", i, array[i]);
                    NSRange range = [array[i] rangeOfString:@"https://www.cnblogs.com/yunduokeji/p/10794209.html"];
                    if (range.location != NSNotFound)
                    {
                        isFindYunduo = true;
                        NSLog(@"luzy find yunduokeji");
                    }
                }
                NSLog(@"luzy isFindYunduo = %d", isFindYunduo);
                NSString *articleInfo = [NSString stringWithFormat:@"ThreadRunCount:%lu, %lu/%lu, articleId:%@, isFindYunduo%d", g_ThreadRunCount, index, g_CommentCount, articleId, isFindYunduo];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"addComment" message:articleInfo preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                if(isFindYunduo == false)
                {
                    g_fn_postCommentWithArticleId(g_postCommentWithArticleId_self, g_postCommentWithArticleId_SEL, articleId, comment, 0, 0, 0, 0);
                }
            }
        }] resume];
}


// 开一个线程函数，刷评论
void *CommentThread(void *)
{
    while(1)
    {
        sleep(10);
        g_ThreadRunCount = g_ThreadRunCount + 1;
        NSLog(@"luzy : %s, %lx, %lx", "CommentThread", g_postCommentWithArticleId_self, g_postCommentWithArticleId_SEL);

        if(g_fn_postCommentWithArticleId != 0 && g_postCommentWithArticleId_self != 0 && g_postCommentWithArticleId_SEL != 0)
        {

            // 拉黑
            //addCommentInTop3(0, @"https://blog.csdn.net/guohelin/article/details/88384711", @"88384711", @"不管用啊，发了10来条，积分还是0，感觉没我的靠谱，复制下面链接打开 https://www.cnblogs.com/yunduokeji/p/10794209.html");


            // 周末
            addCommentInTop3(1, @"https://blog.csdn.net/hellorichen/article/details/74927951", @"74927951", @"评论了10多条，积分还是0，不管用啊，感觉没我的靠谱，复制下面链接打开 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(2, @"https://blog.csdn.net/qq_19002157/article/details/80937026", @"80937026", @"竟然这么高阅读量。没看懂文章中提供的方法，感觉没我的靠谱。复制下面链接打开 https://www.cnblogs.com/yunduokeji/p/10794209.html");


            // 日常
            addCommentInTop3(3, @"https://blog.csdn.net/forzsh/article/details/80831921", @"80831921", @"没有用，链接失效了，竟然这么高阅读量，感觉没我的靠谱。打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(4, @"https://blog.csdn.net/qq_41136994/article/details/80872981", @"80872981", @"博客积分还限制要求注册时间必须大于90天，阅读量竟然这么高，感觉没我的靠谱，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(5, @"https://blog.csdn.net/nut__/article/details/79826201", @"79826201", @"群已经失效了，推荐一个亲测可用的，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(6, @"https://blog.csdn.net/weixin_42929342/article/details/86180300", @"8618030", @"没看懂，推荐一个亲测可用的，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(7, @"https://blog.csdn.net/ID_Rin/article/details/70186773", @"70186773", @"博主好久没更新了，推荐一个亲测可用的，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(8, @"https://blog.csdn.net/vividmebio/article/details/79330660", @"79330660", @"评论是没有积分的，推荐一个亲测可用的 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(9, @"https://blog.csdn.net/cc_wake/article/details/80530043", @"80530043", @"现在评论已经不赠送积分了,阅读量竟然这么高，感觉没我的靠谱，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(10, @"https://blog.csdn.net/weixin_44386305/article/details/86609021", @"86609021", @"我也找了半天，推荐一个亲测可用的，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(11, @"https://blog.csdn.net/qq_37164003/article/details/72705701", @"72705701", @"竟然这么高阅读量，感觉没我的靠谱。打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            addCommentInTop3(12, @"https://blog.csdn.net/Inisit_L/article/details/78068854", @"78068854", @"积分真的好难呀，推荐一个亲测可用的，复制打开下面链接 https://www.cnblogs.com/yunduokeji/p/10794209.html");
            
        }
    }

    return NULL;
}


static void __attribute__((constructor)) constructor() 
{
    // 注意：同一个应用程序，在不同设备上的路径不同
    MSImageRef module_base = MSGetImageByName("/var/containers/Bundle/Application/F04F5946-8648-49D3-B6B1-D955D9C89703/CsdnPlus.app/CsdnPlus");
    unsigned long Func_addr = (unsigned long)module_base - 0x100000000 + 0x00000001001C5804;
    g_fn_postCommentWithArticleId = (void (*)(unsigned long self, unsigned long SEL, NSString* articleId, NSString* content, id ReplyId, id IndexPath, id ParentIndexPath, id TableView))(Func_addr);

    pthread_t tHookThread;
	pthread_create(&tHookThread, NULL, CommentThread, NULL);
}







