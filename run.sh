#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR/workingdir
if [[ ! -d OpenSlides ]]; then
    echo "OpenSlides not cloned, cloning to workingdir..."
else
    echo "Deleting old master checkout"
    rm -rf OpenSlides
fi;

git clone https://github.com/OpenSlides/OpenSlides.git

cd OpenSlides

echo "Creating Virtualenv..."
python3.7 -m venv .virtualenv


source ".virtualenv/bin/activate"

echo "installing python requirements"
pip install --upgrade setuptools pip
pip install -r requirements.txt

rm -rf personal_data/var/static
rm -rf personal_data/var/collected-static
echo "configuring server"
python manage.py createsettings
python manage.py migrate

cd client
rm -rf node_modules
echo "Installing node modules"
npm install --quiet --loglevel=error
echo "building client"
ng build --prod
echo "removing old client"
rm -rf /usr/share/nginx/html/*
echo "copying new client data"
cp -r ../openslides/static/* /usr/share/nginx/html/
echo "fixing permissions"
chown -R openslides:www-data /usr/share/nginx/html/*
chmod 770 /usr/share/nginx/html/*
cd ..

echo "Starting server"
python manage.py runserver


