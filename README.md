
# ocservletsencrypt


Dockerfile for quick set up ocserv(***OpenConnect Server***) with ***Let's Encrypt*** Certificate

## How to Use it
1. Replace `DOMAIN_NAME`, `EMAIL_ADDRESS` in Dockerfile with your own domain name and email
2. Build docker image
  `docker build -t ocservletsencrypt .`
3. Start an instance
  this would create a user *test* with password *test*
  `docker run --name ocserv --privileged -p 80:80 -p 443:443 -p 443:443/udp -itd ocservletsencrypt`
## User operations 
#### Delete User
  *Please delete test user after you create the instance and create other account with complicated password !*
  `docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd -d test`
#### Add User
`docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd -g "Route,All" Bob`
