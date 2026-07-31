#import "VcamRootViewController.h"

@interface VcamRootViewController ()
@property (nonatomic, strong) UISegmentedControl *modeControl;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSString *prefsPath;
@property (nonatomic, strong) NSMutableDictionary *prefs;
@end

@implementation VcamRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0]; 
    
    self.prefsPath = @"/var/mobile/Library/Preferences/com.mch.vcam.plist";
    self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:self.prefsPath] ?: [NSMutableDictionary dictionary];

    // Tiêu đề
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, 50)];
    title.text = @"VCAM MCH ROOT";
    title.textColor = [UIColor systemRedColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:32];
    [self.view addSubview:title];

    // Công tắc Master
    UILabel *switchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, self.view.bounds.size.width, 20)];
    switchLabel.text = @"Bật/Tắt Tráo Camera";
    switchLabel.textColor = [UIColor whiteColor];
    switchLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:switchLabel];

    UISwitch *enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2 - 25, 160, 50, 30)];
    enableSwitch.on = [self.prefs[@"isEnabled"] boolValue];
    [enableSwitch addTarget:self action:@selector(toggleMaster:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:enableSwitch];

    // Trạng thái file/IP
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, self.view.bounds.size.width - 40, 40)];
    self.statusLabel.text = self.prefs[@"mediaPath"] ? [NSString stringWithFormat:@"Đang trỏ tới: %@", [self.prefs[@"mediaPath"] lastPathComponent]] : @"Chưa chọn file / OBS mode";
    self.statusLabel.textColor = [UIColor greenColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.numberOfLines = 2;
    [self.view addSubview:self.statusLabel];

    // Bộ chọn Chế độ (OBS / Ảnh / Video)
    NSArray *modes = @[@"OBS Stream", @"Ảnh (Photo)", @"Video (MP4)"];
    self.modeControl = [[UISegmentedControl alloc] initWithItems:modes];
    self.modeControl.frame = CGRectMake(20, 280, self.view.bounds.size.width - 40, 40);
    self.modeControl.selectedSegmentIndex = [self.prefs[@"workMode"] intValue];
    [self.modeControl addTarget:self action:@selector(modeChanged:) forControlEvents:UIControlEventValueChanged];
    // Custom màu
    self.modeControl.backgroundColor = [UIColor darkGrayColor];
    self.modeControl.selectedSegmentTintColor = [UIColor systemBlueColor];
    [self.modeControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [self.view addSubview:self.modeControl];

    // Nút chọn File (Mở Thư Viện)
    UIButton *pickBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    pickBtn.frame = CGRectMake(50, 350, self.view.bounds.size.width - 100, 50);
    pickBtn.backgroundColor = [UIColor systemOrangeColor];
    pickBtn.layer.cornerRadius = 10;
    [pickBtn setTitle:@"CHỌN ẢNH / VIDEO TỪ MÁY" forState:UIControlStateNormal];
    [pickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    pickBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [pickBtn addTarget:self action:@selector(pickMedia) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pickBtn];
    
    // Nút cấu hình IP OBS
    UIButton *obsBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    obsBtn.frame = CGRectMake(50, 420, self.view.bounds.size.width - 100, 50);
    obsBtn.backgroundColor = [UIColor systemRedColor];
    obsBtn.layer.cornerRadius = 10;
    [obsBtn setTitle:@"ĐẶT IP MÁY TÍNH (OBS)" forState:UIControlStateNormal];
    [obsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    obsBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [obsBtn addTarget:self action:@selector(setObsIP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:obsBtn];
}

- (void)savePrefs {
    [self.prefs writeToFile:self.prefsPath atomically:YES];
}

- (void)toggleMaster:(UISwitch *)sender {
    self.prefs[@"isEnabled"] = @(sender.isOn);
    [self savePrefs];
}

- (void)modeChanged:(UISegmentedControl *)sender {
    self.prefs[@"workMode"] = @(sender.selectedSegmentIndex); // 0: OBS, 1: Photo, 2: Video
    [self savePrefs];
}

- (void)pickMedia {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    if (self.modeControl.selectedSegmentIndex == 2) {
        picker.mediaTypes = @[(NSString *)@"public.movie"]; // kUTTypeMovie
    } else if (self.modeControl.selectedSegmentIndex == 1) {
        picker.mediaTypes = @[(NSString *)@"public.image"]; // kUTTypeImage
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Lỗi" message:@"Mày đang ở chế độ OBS. Chuyển sang Ảnh hoặc Video đi thằng ngu." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    NSURL *mediaURL = info[UIImagePickerControllerMediaURL];
    if (!mediaURL) {
        mediaURL = info[UIImagePickerControllerImageURL];
    }
    
    if (mediaURL) {
        NSString *path = [mediaURL path];
        self.prefs[@"mediaPath"] = path;
        [self savePrefs];
        self.statusLabel.text = [NSString stringWithFormat:@"Đã nạp file:\n%@", [path lastPathComponent]];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)setObsIP {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cấu hình OBS" message:@"Nhập IP máy tính (VD: 192.168.1.5)" preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"192.168.x.x";
        textField.text = self.prefs[@"obsIP"] ?: @"";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Lưu" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *ipField = alert.textFields.firstObject;
        if (ipField.text.length > 0) {
            self.prefs[@"obsIP"] = ipField.text;
            [self savePrefs];
            self.statusLabel.text = [NSString stringWithFormat:@"Đang bắt OBS tại: %@", ipField.text];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
