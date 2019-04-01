---
layout: default
title: Software for Stats Tutorials
---

There are three options to work with the software:

1. Install RStudio locally
2. Using an online binder docker environment that launches R studio immediately. Remark: This tends to be unstable in combination with shiny Apps, the App gets disconnected when there is no browser activity in the App window.
3. Using an online binder docker environment that launches a Jupyter binder environment. See Note above.
4. Using an offline docker that launches a Jupyter environment. Most stable way to

### 1. Local installation

- Install [R/Rstudio](https://www.rstudio.com/products/rstudio)
- Install Bioconductor packages:
``` yaml
source("http://bioconductor.org/biocLite.R")
biocLite()
```
- Install MSnbase
``` yaml
biocLite(“MSnbase”)
```
- Install devtools and MSqRob
``` yaml
biocLite("devtools")
devtools::install_github("statOmics/MSqRob@MSqRob0.7.5")
```

- Download and unzip pda master tree
	- Go to the pda site on github: [https://github.com/statOmics/pda](https://github.com/statOmics/pda)
	- Click on the clone/download button and select download zip
![](./fig/downloadPdaMasterTree.png)
	- Unzip the repository
	- Open Rstudio and go to the unzipped folder


### 2. Getting started with MSqRob using an online docker container

Docker is a platform to develop, deploy, and run applications inside containers, improving security, reproducibility, and scalability in software development and data science. Docker containers differ from virtual machines because they take fewer resources, are very portable, and are faster to spin up.

- Launch an R studio interface in an R docker along with bioconductor packages for proteomics.

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/statOmics/shinyTest/master?urlpath=rstudio)

-  Alternatively, you can launch R studio via the jupyter binder environment:

[![Binder](http://mybinder.org/badge.svg)](http://mybinder.org/v2/gh/statOmics/shinyTest/master)

Once inside Jupyter Notebook, RStudio Server should be an option under the menu
"New":

![](./figs/rstudio-session.jpg)

### 3. Install the Docker locally

#### 3.1 Generate and install docker container

- You can install your own local docker by downloading the entire PDA master branch of the  githyb repository and invoking in a console:

```
docker build <path to proteomicsShortCourse directory> -t msqrob_docker
```
- This only has to be done once and generates a container that is always exactly alike.

#### 3.1b Alternatively we can install from existing docker image

A docker image is a blue print of a docker container that can be used to quickly generate containers that are all exactly alike.

1. Open a terminal
![Figure Launch Docker 1](./figs/installDocker1.png)

2. In the Gulbenkian Institute you find the docker image on your local machine. Type

```
sudo docker load -i /media/gtpb_shared_drive/To_Participant/statsDocker/msqrob_docker.tar
```

If the docker image is on another location, you have to adjust the path "/media/gtpb_shared_drive/To_Participant/statsDocker/msqrob_docker.tar" to "yourPathName/yourDockerImageName".

We run the command as a super user
`sudo` because normal users do not have the permission to launch docker on the PCs in the tutorial room.
The `docker` command launches docker.
The `load` command will enable a new docker to be installed locally.
The switch `-i` stand for input
Then we give the full path to the docker, which is available on the share.

![Figure Launch Docker 2](pages/figs/installDocker2.png)

Now the docker installations starts.

Note, the installation only has to be executed done once.

#### 3.2 Launch the docker image.

Upon installation, we can launch the docker image on our machine.

1. Open a terminal

2. Launch the docker by typing the command.

```
sudo docker run -p 8888:8888 msqrob_docker
```

You have to run the command as a super user (sudo) because normal users do not have the permission to launch docker on the PCs in the tutorial roam.
The `docker` command launches docker.
The `run` command enables you to launch a Docker.
The `-p 8888:8888` command is used to listen to port 8888 of the docker and to pipe it to the port 8888 on the local machine.
The will enable us to view the jupyter server in the Docker via a webbrowser.

We can interact with the docker via a web browser.

3. Open Firefox

![Figure Launch Docker 1](./figs/launchDocker1b.png)

A new window will appear where you have to fill a the token.
You can copy the link token from the terminal.
Here, it was,
```
http://c924e5fb54b5:8888/?token=dd01e2e228d8200e8e2cba2f8fff2a9396f4c22b9068c4d5&token=dd01e2e228d8200e8e2cba2f8fff2a9396f4c22b9068c4d5
```

we first replace the machine name `c924e5fb54b5` by localhost and paste the adjusted address in the browser.
```
http://localhost:8888/?token=dd01e2e228d8200e8e2cba2f8fff2a9396f4c22b9068c4d5&token=dd01e2e228d8200e8e2cba2f8fff2a9396f4c22b9068c4d5
```

Alternatively, you can connect paste the address
 ```
http://localhost:8888/
 ```
  in the browser and paste the token when requested.

Note, that copying in linux is possible via highlighting text. Pasting can be done by pushing the middle mouse button.

![Figure Launch Docker 2](./figs/launchDocker2.png)

Press enter! Then the jupyter hub environment will launch.

![Figure ](./figs/jupyterHub.png)

Select New>Rstudio Session to launch the statistical software R.
Now an interactive statistical programming environment will open in the browser that runs on a cloud server.

### Close the Docker

Only if you work with a local Docker.
1. Close RStudio
2. Log off the jupyter environment
3. Open a new terminal and type the command

```
sudo docker stop c924e5fb54b5
```
where you replace `c924e5fb54b5` with the name of your docker.
