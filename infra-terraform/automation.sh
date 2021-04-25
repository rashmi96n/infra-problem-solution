#!/bin/bash
# Install necessary packages
sudo apt install git -y
sudo apt install default-jre -y
sudo apt install default-jdk -y
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
sudo mkdir -p /usr/local/bin/
sudo mv lein* /usr/local/bin/lein
sudo chmod a+x /usr/local/bin/lein
export PATH=$PATH:/usr/local/bin

sudo apt install make -y
cd $HOME
git clone https://github.com/ThoughtWorksInc/infra-problem 
cd infra-problem
# Compile
make libs
make clean all

#Test the output
make test

# Install Docker
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
apt-cache policy docker-ce
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo apt install -y docker.io
# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
cd $HOME
#Clone the solution repository
git clone https://github.com/rashmi96n/infra-problem-solution.git

#Move compiled files into Docker Build Context
cp $HOME/infra-problem/build/front-end.jar $HOME/infra-problem-solution/frontend/front-end.jar
cp $HOME/infra-problem/build/newsfeed.jar $HOME/infra-problem-solution/newsfeed/newsfeed.jar
cp $HOME/infra-problem/build/quotes.jar $HOME/infra-problem-solution/quotes/quotes.jar
cp -r $HOME/infra-problem/front-end/public $HOME/infra-problem-solution/static/public

cd $HOME/infra-problem-solution/
# Build Containers
sudo -E docker-compose build
sudo -E docker-compose up -d
