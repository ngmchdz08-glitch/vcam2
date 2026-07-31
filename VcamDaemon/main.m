#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

void startOBSListener() {
    int server_fd, new_socket;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);
    
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
        NSLog(@"[VcamDaemon] Lỗi tạo socket");
        return;
    }
    
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(8080);
    
    if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) {
        NSLog(@"[VcamDaemon] Lỗi bind port 8080");
        return;
    }
    
    if (listen(server_fd, 3) < 0) {
        NSLog(@"[VcamDaemon] Lỗi listen");
        return;
    }
    
    NSLog(@"[VcamDaemon] Đang chờ OBS stream ở cổng 8080...");
    
    while(1) {
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) {
            continue;
        }
        NSLog(@"[VcamDaemon] Đã bắt được kết nối từ OBS!");
        char buffer[1024] = {0};
        read(new_socket, buffer, 1024);
        close(new_socket);
    }
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        NSLog(@"[VcamDaemon] Khởi động Vcam_Mch Daemon (RootHide)");
        startOBSListener();
    }
    return 0;
}
