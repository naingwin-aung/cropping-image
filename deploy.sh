echo "Switching to branch main"
git checkout main

echo "Building app.."
npm run build

echo "Deploy files to server..."
scp -r dist/* root@165.22.255.25:/var/www/165.22.255.25/

echo "Done!"