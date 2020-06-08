sudo apt-get update
sudo apt-get install apt-transport-https wget -y
sudo apt-get install software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable'
sudo apt update
sudo apt-get install docker-ce -y
sudo usermod -aG docker ${USER}
sudo apt-get install default-jdk -y
sudo apt-get install default-jre -y
wget https://pkg.jenkins.io/debian-stable/jenkins.io.key
sudo apt-key add jenkins.io.key
echo 'deb https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt-get update
sudo apt-get install jenkins -y
sudo gpasswd -a jenkins docker
sudo service jenkins restart