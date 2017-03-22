#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <errno.h>

void main() {
	int sockfd, clisockfd, err_code;
	socklen_t clilen;
	int rbytes, sbytes;
	char buff[100];
	struct sockaddr_in saddr, caddr;
	clilen = sizeof(caddr);

	if( (sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1 ) {
		printf("Socket creation error");
		exit(0);
	}

	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(3388);
	saddr.sin_addr.s_addr = htons(INADDR_ANY);

	if( (err_code = bind(sockfd, (struct sockaddr*) &saddr, sizeof(saddr))) == -1 ) {
		printf("Bind error %d", errno);
		close(sockfd);
		exit(0);
	}
	
	if( (err_code = listen(sockfd, 1)) == -1 ) {
		printf("Listen error %d", errno);
		close(sockfd);
		exit(0);
	}

	if( (clisockfd = accept(sockfd, (struct sockaddr*) &caddr, &clilen)) == -1 ) {
		printf("Accept error %d", errno);
		close(sockfd);
		exit(0);
	}

	printf("Client Connected.\n");
	
	while(1) {
		if( (rbytes = recv(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Receive error %d", errno);
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
		if( (sbytes = send(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Send error %d", errno);
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
	}

	close(clisockfd);
	close(sockfd);

	
}

