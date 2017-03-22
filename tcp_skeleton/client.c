#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <fcntl.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <errno.h>

void main() {
	int sockfd, err_code;
	int sbytes, rbytes;
	struct sockaddr_in saddr;
	char buff[100];

	if( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ) {
		printf("Socket Creation Error %d", errno);
		exit(0);
	}

	saddr.sin_port = htons(3388);
	saddr.sin_family = AF_INET;
	saddr.sin_addr.s_addr = inet_addr("127.0.0.1");

	if( (err_code = connect(sockfd, (struct sockaddr*) &saddr, sizeof(saddr))) == -1 ) {
		printf("Connect error %d", errno);
		close(sockfd);
		exit(0);
	}

	if( (sbytes = send(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Send Error %d", errno);
		close(sockfd);
		exit(0);
	}

	if( (rbytes = recv(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Receive Error %d", errno);
		close(sockfd);
		exit(0);
	}

	puts(buff);

	close(sockfd);
}
