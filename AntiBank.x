#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <sys/stat.h>
#include <sys/types.h>

// Mù mắt các app ngân hàng check file của jailbreak
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"/var/jb"] || [path containsString:@"Cydia"] || [path containsString:@"Sileo"] || [path containsString:@"Vcam_Mch"]) {
        return NO;
    }
    return %orig;
}
%end

// Hook C API stat
#include <sys/stat.h>
%hookf(int, stat, const char *path, struct stat *buf) {
    if (path != NULL) {
        NSString *strPath = [NSString stringWithUTF8String:path];
        if ([strPath containsString:@"/var/jb"] || [strPath containsString:@"Vcam_Mch"]) {
            return -1; // Giả vờ file ko tồn tại
        }
    }
    return %orig(path, buf);
}

// Khai báo thủ công ptrace vì SDK iOS giấu hàm này
extern int ptrace(int request, pid_t pid, caddr_t addr, int data);

// Hook C API ptrace để chống debug chặn
%hookf(int, ptrace, int request, pid_t pid, caddr_t addr, int data) {
    if (request == 31) { // PT_DENY_ATTACH
        return 0; // Bypass ptrace
    }
    return %orig(request, pid, addr, data);
}
