#!/usr/bin/env bash

if [ $EUID -ne 0 ]; then
		echo "Run as a root"
		exit 1
fi

curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
echo "Setup nginx"
sudo apt install nginx nodejs -y
sudo cp -r * /var/www/html/

basedir=$(cd "$(dirname $0)" > /dev/null 2>&1 && pwd)

dbdirname="insta-database"
dbdir="$basedir/../$dbdirname"
packagejson="$dbdir/package.json"
indexjs="index.js"
dbjson="$dbdir/db.json"
sudo rm -rfv "$dbdir"
mkdir "$dbdir"
cd "$dbdir"

if [ $# -eq 0 ]; then
	ipaddr=$(ip a s eth0 | grep -w inet| tr -s " " | cut -d " " -f 3 | cut -d "/" -f 1)
else
	ipaddr=$(ip a s $1 | grep -w inet| tr -s " " | cut -d " " -f 3 | cut -d "/" -f 1)
fi
find /var/www/html/ -type f -exec sed -i "s/localhost/$ipaddr/g" {} \;
find $dbdir -type f -exec sed -i "s/localhost/$ipaddr/g" {} \;
cat >"$packagejson" <<EOF
{
  "name": "$dbdirname",
  "version": "1.0.0",
  "description": "",
  "main": "$indexjs",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "json-server --host $ipaddr db.json"
  },
  "author": "",
  "license": "ISC"
}
EOF

sudo npm install -g json-server
npm install express
npm install
touch "$dbjson"

cat >"$dbjson" <<EOF
{
    "login": [
        {
            "username" : "admin",
            "password" : "admin",
            "id" : 1
        }
    ]
}
EOF
sudo systemctl restart nginx
npm run start &
echo -e "\nDatabase at: http://localhost:3000/login"
