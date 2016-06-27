#docker run --name jenkins-memcached -d memcached
#docker run --name jenkins-mysql -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE=yf_for_unit_tests -d mysql:5.6
#docker run --privileged --name jenkins-mysql -d theasci/docker-mysql-tmpfs
#docker rm jenkins-master
docker run \
    -d \
    -p 8080:8080 -p 50000:50000 \
    --link jenkins-memcache:localhost \
    --link jenkins-mysql:mysql \
    --name jenkins-master \
    -v /boxes/docker-jenkins:/var/jenkins_home \
    yfix/jenkins-master

#docker exec -it jenkins-master bash
