#include <arpa/inet.h>
#include <netdb.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <unistd.h>

static int send_all(int fd, const char *buf, ssize_t len) {
    while (len > 0) {
        ssize_t n = send(fd, buf, (size_t)len, 0);
        if (n <= 0) return -1;
        buf += n; len -= n;
    }
    return 0;
}

int main(int argc, char **argv) {
    if (argc != 4) return 2;
    signal(SIGPIPE, SIG_IGN);

    struct addrinfo hints = {0}, *remote = NULL;
    hints.ai_family = AF_INET; hints.ai_socktype = SOCK_STREAM;
    if (getaddrinfo(argv[1], argv[2], &hints, &remote) != 0) return 3;

    int listener = socket(AF_INET, SOCK_STREAM, 0), one = 1;
    setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));
    struct sockaddr_in local = {0}; local.sin_family = AF_INET;
    local.sin_addr.s_addr = htonl(INADDR_LOOPBACK); local.sin_port = htons((uint16_t)atoi(argv[3]));
    if (bind(listener, (struct sockaddr *)&local, sizeof(local)) || listen(listener, 4)) return 4;

    char buf[65536];
    for (;;) {
        int client = accept(listener, NULL, NULL);
        if (client < 0) continue;
        int phone = socket(remote->ai_family, remote->ai_socktype, remote->ai_protocol);
        if (phone < 0 || connect(phone, remote->ai_addr, remote->ai_addrlen)) { close(client); if (phone >= 0) close(phone); continue; }
        for (;;) {
            fd_set reads; FD_ZERO(&reads); FD_SET(client, &reads); FD_SET(phone, &reads);
            int maxfd = client > phone ? client : phone;
            if (select(maxfd + 1, &reads, NULL, NULL, NULL) <= 0) break;
            int handled = 0;
            if (FD_ISSET(client, &reads)) {
                ssize_t n = recv(client, buf, sizeof(buf), 0); handled = 1;
                if (n <= 0 || send_all(phone, buf, n)) break;
            }
            if (FD_ISSET(phone, &reads)) {
                ssize_t n = recv(phone, buf, sizeof(buf), 0); handled = 1;
                if (n <= 0 || send_all(client, buf, n)) break;
            }
            if (!handled) break;
        }
        close(client); close(phone);
    }
    freeaddrinfo(remote); close(listener);
    return 0;
}
