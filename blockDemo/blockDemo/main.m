//
//  main.m
//  blockDemo
//
//  Created by Sailer Guo on 2021/3/23.
//

#import <Foundation/Foundation.h>


@interface Person : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, copy) void (^block)(void);

- (void)testReferenceSelf;

@end

@implementation Person
/**
 xcrun clang -rewrite-objc -fobjc-arc -stdlib=libc++ -mmacosx-version-min=10.7 -fobjc-runtime=macosx-10.7 -Wno-deprecated-declarations main.m
 */
- (void)testReferenceSelf {
    __weak typeof(self) weakself = self;
    __block int a = 10;
//    __unsafe_unretained NSMutableArray *arr = @[].mutableCopy;
//    __block NSString *name = ;
    __block NSString *name = [[NSString alloc] initWithString:@"afjasdlfajdfkasdjfakd"];
    
    
    int b = 10;
    void(^tempBlock)(void) = ^ {
        __strong typeof(self) strongself = weakself;
        a++;
//        name = @"aflasjdflkd";
        name = @"aflasjdflkdafdfa";
//        [arr addObject:@"add obj in block"];
        NSLog(@"in block: self.name = %s b, a: %d\n", strongself.name.UTF8String,a);
    };
    
    self.block = tempBlock;
    
    NSLog(@"a: %d \n b: %d\n",a,b);
    self.block();

}

// xcrun -sdk iphonesimulator clang -rewrite-objc main.m
- (void)dealloc {
    self.block();
    NSLog(@"-------dealloc-------");
}

@end


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        Person *person = [[Person alloc] init];
        person.name = @"roy";
        [person testReferenceSelf];
    }
    return 0;
}
