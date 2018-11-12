#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $DIR/workingdir
if [[ ! -d OpenSlides ]]; then
    echo "OpenSlides not cloned, cloning to workingdir..."
    git clone https://github.com/OpenSlides/OpenSlides.git
else
    cd OpenSlides
    echo "Updating the openslides clone"
    git pull origin master
    cd ..
fi;

cd OpenSlides

rm -rf .virtualenv
echo "Creating Virtualenv..."
python3.7 -m venv .virtualenv


source ".virtualenv/bin/activate"

echo "installing python requirements"
pip install --quiet --upgrade setuptools pip
pip install --quiet -r requirements.txt

rm -rf personal_data/var/static
rm -rf personal_data/var/collected-static
echo "configuring server"
python manage.py createsettings
python manage.py migrate

echo "removing node modules"
cd client
rm -rf node_modules
echo "Installing node modules"
npm install --quiet --loglevel=error
ng build --prod
rm -rf /usr/share/nginx/html/*
cp -r ../openslides/static/* /usr/share/nginx/html/
chown -R $(users):www-data /usr/share/nginx/html/*
chmod 770 /usr/share/nginx/html/*
cd ..

echo "Starting server"
python manage.py runserver
