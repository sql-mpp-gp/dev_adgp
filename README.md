Build for arenadata db sandbox

Create docker image:
docker build -t gpdb .

Run docker image:
docker run -v ./gpdemo:/tmp/gpdb/gpdemo  -d -p2222:22 gpdb

Connect to docker image:
ssh gpadmin@localhost -p 2222
(input yes and password gpadmin)

Create cluster:
make cluster

Stop cluster
gpstop

connect from localhost psql (password gpadmin)
psql -p6000 -hlocalhost -Ugpadmin -dpostgres
