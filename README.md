# Installation Guide
Create codespace from repository.

After container for codespace is built, run the following commands.

to add seed data for development:
 - medusa seed --seed-file=data/seed.json

run commands for development:
 - medusa develop in one terminal
 - npm run dev:admin to start admin UI

Need to set both 7007 and 9000 ports to public to use in codespaces.

medusa start (for development on codespace or production)

# check background
You can check if backend is installed correclty by doing this command in your terminal. 

curl localhost:9000/store/products

And the result will be displayed as a Json formats.
