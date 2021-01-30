#!/usr/bin/env bash

if [ $EUID -ne 0 ]; then
		echo "Run as a root"
		exit 1
fi

echo "Setup nginx"
sudo apt install nginx node -y
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

cat >"$packagejson" <<EOF
{
  "name": "$dbdirname",
  "version": "1.0.0",
  "description": "",
  "main": "$indexjs",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "start": "json-server --watch db.json"
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
