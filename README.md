## Installing dependencies
Before installation, you need to prepare the server.

```bash
# Updating ubuntu sever repos
sudo apt update
sudo apt upgrade

# Instaling the dependencies
sudo apt install -y git curl wget mc build-essential python3-dev python3-venv nginx supervisor \
    make cmake g++ libboost-dev libboost-system-dev \
    libboost-filesystem-dev libexpat1-dev zlib1g-dev \
    libbz2-dev libpq-dev libproj-dev lua5.3 liblua5.3-dev pandoc libluajit-5.1-dev
```
### If Ubuntu 20.04 LTS
Osm2pgsql requires PostgreSQL client libraries. 
It also requires access to a database server running PostgreSQL 9.5+ and PostGIS 2.2+. 
After installing the dependencies, execute:

```bash
git clone https://github.com/openstreetmap/osm2pgsql
cd osm2pgsql
mkdir build && cd build
cmake -D WITH_LUAJIT=ON ..
make && sudo make install
# Go have some coffee ...
cd ../../ && rm -rf osm2pgsql
```

### If Ubuntu 22.04 LTS
`sudo apt install osm2pgsql`

## Installation
```bash
cd  "/chum-shlah-server"
python3 -m venv venv
source venv/bin/activate
python3 -m pip install --upgrade pip
pip install -r requirements.txt
```
Add Environment variables. Create a file at the root of the project and add the database connection string.
`DSN="postgresql://..."`


## Deployment
Run the migrations with the command:
Currently, for tests, migration includes downloading demo data. This will be removed after release.
`export $(grep -v '^#' .env | xargs) && yoyo apply --database ${DSN}`

Supervisor setup

```bash
sudo mkdir /var/log/chum-sh-server
sudo cp chum-sh-server.conf /etc/supervisor/conf.d/chum-sh-server.conf
sudo systemctl restart supervisor
```


## Interactive API docs
Go to http://127.0.0.1:8000/docs.
You will see the automatic interactive API documentation (provided by Swagger UI).

