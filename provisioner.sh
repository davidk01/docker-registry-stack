# Set the path by checking if /vagrant exists
path=""
if [[ -e /vagrant ]]; then
  path="/vagrant/"
else
  path = "./"
fi

# Need docker, curl, vim, etc.
yum install -y docker curl vim java wget git strace htop lsof bind-utils \
  patch libyaml-devel glibc-headers autoconf gcc-c++ glibc-devel patch \
  readline-devel zlib-devel libffi-devel openssl-devel automake libtool \
  bison sqlite-devel
systemctl start docker

# Need RVM for various Ruby related things
if [[ ! -e /usr/local/rvm ]]; then
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  \curl -sSL https://get.rvm.io | bash -s stable
  source /etc/profile.d/rvm.sh
  if [[ ! $(rvm list | grep ruby) ]]; then
    rvm install ruby
  fi
fi

# Need Jenkins for setting up the job to build and push images to locally hosted docker registry
if [[ ! -e /etc/init.d/jenkins ]]; then
  wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
  rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
  # Install Jenkins and make the directories
  yum install -y jenkins
  mkdir -p /var/lib/jenkins/jobs
  mkdir -p /var/lib/jenkins/plugins
  # Copy any premade jobs
  find ${path}jenkins/jobs -maxdepth 1 -mindepth 1 -type d | xargs -I% cp -r "%" /var/lib/jenkins/jobs
  # Make sure we have the git plugin
  pushd /var/lib/jenkins/plugins
    wget http://updates.jenkins-ci.org/latest/git.hpi
    wget http://updates.jenkins-ci.org/latest/scm-api.hpi
    wget http://updates.jenkins-ci.org/latest/credentials.hpi
    wget http://updates.jenkins-ci.org/latest/git-client.hpi
    wget http://updates.jenkins-ci.org/latest/ssh-credentials.hpi
  popd
  # Shell configuration for running bash
  cp ${path}jenkins/*.xml /var/lib/jenkins
  chown -R jenkins:jenkins /var/lib/jenkins
  systemctl start jenkins
fi
# Give jenkins sudo
if [[ ! $(cat /etc/sudoers | grep jenkins) ]]; then
  echo "jenkins ALL= NOPASSWD: ALL" >> /etc/sudoers
fi 

# Registry stuff. Make the container and start it.
if [[ ! -e distribution ]]; then
  git clone https://github.com/docker/distribution.git
fi
pushd distribution
  rm -f cmd/registry/config.yml
  cp -f ../config.yml cmd/registry/config.yml
  rm -r Dockerfile
  cp -f ../registry-dockerfile Dockerfile
  docker build -t registry .
  docker run -d -p 5000:5000 registry:latest
popd
