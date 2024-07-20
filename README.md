# Installation Guide

Fork This REPO...

Create codespace from repository.

After container for codespace is built, run the following commands.

to add seed data for development:
 - medusa seed --seed-file=data/seed.json

 - edit dev:admin command in package.json, replace url with your codespace url for the backend, one that contains 9000

to start medusa for development:
 - medusa develop
 open second terminal window and run 
 - npm run dev:admin

set port 9000 to public to use in codespaces:
 - There is ports tab in VSCode same window where terminal is right click on visibilty Private i set it to Public for port 9000.

continue to this repo and follow readme to setup the frontend:
 - https://github.com/dmiric/12x3-FE

