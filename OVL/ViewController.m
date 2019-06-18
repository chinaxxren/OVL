
#import "ViewController.h"

#import "OVLViewController.h"
#import "OVLFilter.h"
#import "OVLScript.h"
#import "OVLShaderManager.h"
#import "FileReader.h"

@interface ViewController ()

@property(nonatomic,strong) OVLViewController *ovc;
@property(nonatomic,strong) NSMutableArray<NSString *> *scriptNames;
@property(nonatomic,strong) NSMutableArray<OVLScript *> *scripts;
@property(nonatomic,assign) BOOL fFrontCamera;
@property(nonatomic,assign) NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.fFrontCamera = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Change"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(changeFilter)];
    [self addChildViewController:self.ovc];
    
    self.ovc.view.frame = self.view.bounds;
    [self.ovc didMoveToParentViewController:self];
    [self.view addSubview:self.ovc.glkView];
    
    self.scriptNames = [NSMutableArray<NSString *> new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Filter" ofType:@"txt"];
    FileReader *reader = [[FileReader alloc] initWithFilePath:path];
    NSString * line = nil;
    while ((line = [reader readTrimmedLine])) {
        NSLog(@"read line: %@", line);
        if(line) {
            [self.scriptNames addObject:line];
        }
    }
    
    self.scripts = [NSMutableArray<OVLScript *> new];
    for (NSString *name in self.scriptNames) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"vsscript"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        [self.scripts addObject:[[OVLScript alloc] initWithDictionary:jsonDict]];
    }
    
    // Load the script after associated view controllers are fully initialized
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.ovc loadScript:self.scripts[0]];
    });
}

- (void)changeFilter {
    self.index++;
    if(self.index == [self.scripts count]) {
        self.index = 0;
    }
    [self changeScript:self.index];
}

- (void)changeScript:(NSInteger)index {
    [self.ovc switchScript:self.scripts[index]];
}

- (void)record {
    [self.ovc record];
}

- (void)flip {
    self.fFrontCamera = !self.fFrontCamera;
    [OVLFilter setFrontCameraMode:self.fFrontCamera];
}

- (OVLViewController *)ovc {
    if(!_ovc){
        _ovc = [OVLViewController new];
        [OVLFilter setFrontCameraMode:true];
        _ovc.fHD = YES;
        _ovc.fps = 30;
        _ovc.fFrontCamera = YES;
        _ovc.fPhotoRatio = NO;
    }
    
    return _ovc;
}

@end
