#import "ViewController.h"
#import "ane_probe.h"

@interface ViewController ()
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) UIButton *runButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.035 green:0.045 blue:0.085 alpha:1.0];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"ANE Probe";
    title.font = [UIFont systemFontOfSize:30 weight:UIFontWeightBold];
    title.textColor = UIColor.whiteColor;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:title];

    UILabel *subtitle = [[UILabel alloc] init];
    subtitle.text = @"Service reachability · read-only probe";
    subtitle.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    subtitle.textColor = [UIColor colorWithWhite:0.72 alpha:1.0];
    subtitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subtitle];

    self.runButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.runButton setTitle:@"Run ANE Service Probe" forState:UIControlStateNormal];
    self.runButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.runButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    self.runButton.backgroundColor = [UIColor colorWithRed:0.36 green:0.25 blue:0.78 alpha:1.0];
    self.runButton.layer.cornerRadius = 13;
    self.runButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.runButton addTarget:self action:@selector(runProbe) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.runButton];

    self.output = [[UITextView alloc] init];
    self.output.editable = NO;
    self.output.selectable = YES;
    self.output.backgroundColor = [UIColor colorWithWhite:0.06 alpha:1.0];
    self.output.textColor = [UIColor colorWithRed:0.65 green:0.95 blue:0.78 alpha:1.0];
    self.output.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    self.output.layer.cornerRadius = 12;
    self.output.text = @"Ready. Tap the button to inspect ANE service visibility and user-client open results.\n";
    self.output.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.output];

    UILabel *warning = [[UILabel alloc] init];
    warning.text = @"An opened service does not prove a vulnerability. This build contains no overflow trigger or exploit code.";
    warning.font = [UIFont systemFontOfSize:11];
    warning.textColor = [UIColor colorWithWhite:0.68 alpha:1.0];
    warning.numberOfLines = 0;
    warning.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:warning];

    [NSLayoutConstraint activateConstraints:@[
        [title.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:24],
        [title.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:22],
        [subtitle.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:5],
        [subtitle.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [self.runButton.topAnchor constraintEqualToAnchor:subtitle.bottomAnchor constant:22],
        [self.runButton.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [self.runButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-22],
        [self.runButton.heightAnchor constraintEqualToConstant:52],
        [self.output.topAnchor constraintEqualToAnchor:self.runButton.bottomAnchor constant:18],
        [self.output.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [self.output.trailingAnchor constraintEqualToAnchor:self.runButton.trailingAnchor],
        [self.output.bottomAnchor constraintEqualToAnchor:warning.topAnchor constant:-12],
        [warning.leadingAnchor constraintEqualToAnchor:title.leadingAnchor],
        [warning.trailingAnchor constraintEqualToAnchor:self.runButton.trailingAnchor],
        [warning.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-12]
    ]];
}

static void ProbeLog(const char *message) {
    NSString *line = [[NSString alloc] initWithUTF8String:message ?: ""];
    dispatch_async(dispatch_get_main_queue(), ^{
        ViewController *vc = (ViewController *)UIApplication.sharedApplication.keyWindow.rootViewController;
        if (![vc isKindOfClass:ViewController.class]) return;
        vc.output.text = [vc.output.text stringByAppendingFormat:@"%@\n", line];
        NSRange range = NSMakeRange(vc.output.text.length - 1, 1);
        [vc.output scrollRangeToVisible:range];
    });
}

- (void)runProbe {
    self.runButton.enabled = NO;
    [self.runButton setTitle:@"Probing…" forState:UIControlStateNormal];
    self.output.text = @"Starting service reachability probe…\n";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        int mask = ane_probe_services(ProbeLog);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.output.text = [self.output.text stringByAppendingFormat:@"\nFinished. Opened-service mask: 0x%x\n", mask];
            [self.runButton setTitle:@"Run ANE Service Probe" forState:UIControlStateNormal];
            self.runButton.enabled = YES;
        });
    });
}
@end
