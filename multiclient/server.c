#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define MAXSIZE 100

void main()
{
	int sockfd, cfd, retval;
	struct sockaddr_in saddr, caddr;
	int r_b, s_b;
	int clinum = 0;
	pid_t pid;
	socklen_t clilen;

	char buff[MAXSIZE], uname[MAXSIZE], pass[MAXSIZE];

	//socket() : creating the socket
	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if(sockfd < 0) {
		printf("\nSocket creation error");
		exit(0);
	}
	
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(3388);
	saddr.sin_addr.s_addr = htons(INADDR_ANY);

	//bind() : binding port
	retval = bind(sockfd, (struct sockaddr*) &saddr, sizeof(saddr));

	if(retval < 0) {
		printf("Bind error");
		close(sockfd);
		exit(0);
	}

	//listen() : listen for connection
	retval = listen(sockfd, 3);
	
	if(retval < 0) {
		printf("Listen error");
		close(sockfd);
		exit(0);
	}

	//accept() : accept a connection

	while(1) {
		
		clilen = sizeof(caddr);
		cfd = accept(sockfd, (struct sockaddr*)&caddr, &clilen);
		
		if(cfd == -1) {
			printf("accept error %d", cfd);
			close(sockfd);
			exit(0);
		}
	
		clinum++;

		pid = fork();

		if(pid == 0) {

			printf("%d", clinum);

			if(clinum > 2) {
				strcpy(buff, "Terminate");
			} else {
				r_b = recv(cfd, buff, sizeof(buff), 0);
				if(r_b < 0) {
					printf("Recv error %d", r_b);
					close(cfd);
					close(sockfd);
				}
				printf("%s", buff);
				strcpy(buff, "hello client");
			}
			
			s_b = send(cfd, buff, sizeof(buff), 0);
			if(s_b < 0) {
				close(cfd);
				close(sockfd);
			}
		}
	}

	close(cfd);
	close(sockfd);
}
