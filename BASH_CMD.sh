# 1. Create the local CLI plugins directory
mkdir -p ~/.docker/cli-plugins/

# 2. Download the latest Docker Compose V2 (currently v2.26.1 or similar)
curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose

# 3. Apply executable permissions
chmod +x ~/.docker/cli-plugins/docker-compose

# 4. Create a symbolic link so you can just type 'docker compose' (no hyphen)
sudo ln -s ~/.docker/cli-plugins/docker-compose /usr/local/bin/docker-compose
