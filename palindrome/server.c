#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#define MAXSIZE 90

main()
{
	int sockfd, newsockfd, retval, j;
	socklen_t actuallen;
	int recedbytes, sentbytes;
	struct sockaddr_in serveraddr, clientaddr;

	char buff[MAXSIZE];
	int a = 0;

	//socket() : creating the socket
	sockfd = socket(AF_INET, SOCK_STREAM, 0);

	if(sockfd == -1) {
		printf("\nSocket creation error");
	}

	serveraddr.sin_family = AF_INET;
	serveraddr.sin_port = htons(3388);
	serveraddr.sin_addr.s_addr = htons(INADDR_ANY);

	//bind() : binding port
	retval = bind(sockfd, (struct sockaddr*) &serveraddr, sizeof(serveraddr));

	if(retval == -1) {
		printf("Binding error");
		close(sockfd);
	}

	//listen() : listen for connection
	retval = listen(sockfd, 1);
	if(retval == -1) {
		close(sockfd);
	}

	//accept() : accept a connection
	actuallen = sizeof(clientaddr);
	newsockfd = accept(sockfd, (struct sockaddr*)&clientaddr, &actuallen);

	if(newsockfd == -1) {
		close(sockfd);
	}


	//recv() : recv bytes
	recedbytes = recv(newsockfd, buff, sizeof(buff), 0);

	if(recedbytes == -1) {
		close(sockfd);
		close(newsockfd);
	}

	puts(buff);

	if(buff == "stop") {
		close(sockfd);
		close(newsockfd);
	}

	printf("\n");
	//scanf("%s",buff);

	int flag = 0;
	for(j = 0; j < strlen(buff); j++) {
		if(buff[j] != buff[strlen(buff) - j - 1]) {
			flag = 1;
			break;
		}
	}

	if(flag == 1) {
		strcpy(buff, "not a palindrome");
	} else {
		strcpy(buff, "palindrome");
	}

	//send() : send response
	sentbytes = send(newsockfd, buff, sizeof(buff), 0);

	if(sentbytes == -1) {
		close(sockfd);
		close(newsockfd);
	}

	close(sockfd);
	close(newsockfd);
}

