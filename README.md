# Local Testing
Run `vagrant up` and you will get a Vagrant box with all the
required components to test your Dockerfile. Once the VM is up and running you
can go to `localhost:8080` in your browser and kick off the docker container
publishing task to see the results in the local registry. This is exactly the
same process that is used on the production registry to publish images if you use
the provisioning script to set things up.

Initial `vagrant up` takes a while so grab a coffee while you wait for things
to compile and install.

If you know what you're doing then you can run the provisioning script as root
but this is not a supported workflow so you've been warned.

# Workflow 
This is assuming you've already run `vagrant up` and `vagrant ssh`
and are working within the supplied virtual machines. All commands assume
you're root and are inside `/vagrant` directory. If you ran the provisioning
script directly then you need to be at the base of the git repo but as above
this is not a supported workflow.

To create a template directory for your new Dockerfile run `rake
add[${directory name}]`. This will generate a directory under `Dockerfiles`
with the given name and populate it with `name`, `version`, and `Dockerfile`
files. The default name inside `name` is whatever you passed to `rake add` so
feel free to modify it. This is the name that will show up in the registry. The
default version is `0.1` and you should increment this whenever you make any
changes that require rebuilding the container.

After you've made the necessary changes to your Dockerfile you should run `rake
build[${directory name}]` to generate and push the container to the locally
running registiry. Locally running here means within the Vagrant VM.
