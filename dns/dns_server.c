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
	int find_ip, flag;

	const char *ip[8];
	ip[0] = "1.186.108.190";
	ip[1] =	"1.186.106.201";
	ip[2] =	"1.173.105.231";
	ip[3] =	"1.123.198.193";
	ip[4] = "1.245.193.102";
	ip[5] = "1.108.154.201";
	ip[6] = "1.173.123.103";
	ip[7] = "1.145.105.234";

	const char *dn[8];
	dn[0] = "dnof1.com";
	dn[1] = "dnof2.com";
	dn[2] = "dnof3.com";
	dn[3] = "dnof4.com";
	dn[4] = "dnof5.com";
	dn[5] = "dnof6.com";
	dn[6] = "dnof7.com";
	dn[7] = "dnof8.com";

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
	
	for(int i = 0; i < 8; i++) {
		printf("%s\t%s\n", ip[i], dn[i]);
	}

	if( (err_code = listen(sockfd, 1)) == -1 ) {
		printf("Listen error");
		close(sockfd);
		exit(0);
	}

	while(1) {
		if( (clisockfd = accept(sockfd, (struct sockaddr*) &caddr, &clilen)) == -1 ) {
			printf("Accept error");
			close(sockfd);
			exit(0);
		}
	
		printf("Client connected.\n");
	
		if( (rbytes = recv(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Receive error");
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
		if( strcmp(buff, "ip") == 0 ) {
			find_ip = 1;
			strcpy(buff, "Server finding IP\n");
		} else if( strcmp(buff, "domain") == 0 ) {
			find_ip = 0;
			strcpy(buff, "Server finding Domain Name\n");
		} else {
			printf("Invalid first parameter. Restart client.\nType \"ip\" or \"domain\"\n");
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
		if( (sbytes = send(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Send error");
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
		if( (rbytes = recv(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Receive error");
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	
		flag = 0;
		printf("%s\t", buff);

		if( find_ip == 1 ) {
			for(int i = 0; i < 8; i++) {
				if( strcmp(buff, dn[i]) == 0 ) {
					strcpy(buff, ip[i]);
					flag = 1;
					break;
				}
			}
			if( flag == 0 ) {
				strcpy(buff, "Could not find the given IP");
			}
		} else if( find_ip == 0 ) {
			for(int i = 0; i < 8; i++) {
				if( strcmp(buff, ip[i]) == 0 ) {
					strcpy(buff, dn[i]);
					flag = 1;
					break;
				}
			}
			if( flag == 0 ) {
				strcpy(buff, "Could not find the given domain");
			}
		}
	
		printf("%s\n", buff);
		if( (sbytes = send(clisockfd, buff, sizeof(buff), 0)) == -1 ) {
			printf("Send error");
			close(clisockfd);
			close(sockfd);
			exit(0);
		}
	}

	close(clisockfd);
	close(sockfd);

	
}

