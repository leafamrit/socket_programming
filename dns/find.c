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

void main(int argc, char *argv[]) {
	int sockfd, err_code;
	int sbytes, rbytes;
	struct sockaddr_in saddr;
	char buff[100];

	if( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ) {
		printf("Socket creation error");
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

	// sending what to find
	strcpy(buff, argv[1]);
	if( (sbytes = send(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Send error");
		close(sockfd);
		exit(0);
	}

	// receive response from server
	if( (rbytes = recv(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Receive error");
		close(sockfd);
		exit(0);
	}

	puts(buff);

	// sending input ip / dn
	strcpy(buff, argv[2]);
	if( (sbytes = send(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Send error");
		close(sockfd);
		exit(0);
	}

	// receiving response
	if( (rbytes = recv(sockfd, buff, sizeof(buff), 0)) == -1 ) {
		printf("Receive error");
		close(sockfd);
		exit(0);
	}

	puts(buff);

	close(sockfd);
}
