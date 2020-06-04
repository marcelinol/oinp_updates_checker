How to use AWS RDS database with a pure ruby application.

- Create Database in aws RDS
- Edit the VPC Security Group created for the database to allow your own IP to access the database
- May need to use "postgres" instead of the database name when connecting to it
(2 items above came from the this troubleshooting: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html)

- Connect using sequel gem (pg gem required as well)


other useful links:
https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_ConnectToPostgreSQLInstance.html
 