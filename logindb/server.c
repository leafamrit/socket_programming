#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define MAXSIZE 100

struct user {
	char username[MAXSIZE];
	char password[MAXSIZE];
};

void main()
{
	int sockfd, cfd, retval;
	struct sockaddr_in saddr, caddr;
	int r_b, s_b;
	struct user u[10];
	int i = 0, j;
	socklen_t clilen;

	char buff[MAXSIZE], uname[MAXSIZE], pass[MAXSIZE];

	//socket() : creating the socket
	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if(sockfd < 0) {
		printf("\nSocket creation error");
		close(sockfd);
	}
	
	saddr.sin_family = AF_INET;
	saddr.sin_port = htons(3388);
	saddr.sin_addr.s_addr = htons(INADDR_ANY);

	//bind() : binding port
	retval = bind(sockfd, (struct sockaddr*) &saddr, sizeof(saddr));

	if(retval < 0) {
		printf("Bind error");
		close(sockfd);
	}

	//listen() : listen for connection
	retval = listen(sockfd, 1);
	
	if(retval < 0) {
		printf("Listen error");
		close(sockfd);
	}

	//accept() : accept a connection
	clilen = sizeof(caddr);
	cfd = accept(sockfd, (struct sockaddr*)&caddr, &clilen);

	if(cfd == -1) {
		printf("accept error %d", cfd);
		close(sockfd);
	}

	while(1) {
		//recv() : recv bytes
		r_b = recv(cfd, buff, sizeof(buff), 0);

		if(r_b < 0) {
			printf("Recv error %d", r_b);
			close(cfd);
			close(sockfd);
		}

		if(buff[0] == 'a') {
			r_b = recv(cfd, uname, sizeof(uname), 0);
			r_b = recv(cfd, pass, sizeof(pass), 0);
			
			strcpy(u[i].username, uname);
			strcpy(u[i].password, pass);
			i++;

			strcpy(buff, "Added successfully");

			s_b = send(cfd, buff, sizeof(buff), 0);
		} else if(buff[0] == 'b') {
			r_b = recv(cfd, uname, sizeof(uname), 0);
			r_b = recv(cfd, pass, sizeof(pass), 0);

			strcpy(buff, "Username not found");

			for(int j = 0; j < i; j++) {
				if(strcmp(uname, u[j].username) == 0) {
					if(strcmp(u[j].password, pass) == 0) {
						strcpy(buff, "Logged in");
					} else {
						strcpy(buff, "Incorrect Password");
					}
					break;
				}
			}

			s_b = send(cfd, buff, sizeof(buff), 0);
		} else {
			close(cfd);
			close(sockfd);
			break;
		}


		//send() : send response
		if(s_b < 0) {
			close(cfd);
			close(sockfd);
		}
	}

	close(cfd);
	close(sockfd);
}

