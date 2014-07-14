Go RPM for CentOS 6
==================

This repository contains files for releasing the Go Programming Language **http://golang.org/** (golang rpm) on CentOS 6. It uses the Fedora release **http://www.rpmfind.net/linux/rpm2html/search.php?query=golang** as the base, and made some modifications.


Steps to run the build:
--------------------

Setup Build Host:
++++++++++++++++

On a CentOS-6 host, install the necessary tools for building RPM. These include the following rpms:

* rpm-build, gcc, autoconf, automake

Check out this repository:
+++++++++++++++++++++++++

cd 
git clone https://github.com/dantian/centos_rpm

Run the build:
+++++++++++++

In the following commands, replace xyz with a character string representing a meaningful name abbreviation.

cd centos_rpm/golang
bash golang_build.sh -v 1.3 -r 2.xyz

The result rpm files are in the dist folder.


Issues & Resolutions:
--------------------

We have made modifications to the original Fedora golang.spec file to make this build work. When Fedora makes new releases, our modifications could be obsolete. Then it is necessary to update the golang_build.sh file to take out the modifications (implemented in the sed commands).

The following is a list of the issues and our modifications.

Create RPM without build checks
+++++++++++++++++++++++++++++++

We commented out the command to run build checks in the build. Our release is less safe as it does not run the necessary checks for the build artifacts.


Remove dependency on go
+++++++++++++++++++++++++++++++

The Fedora release spec file contains runtime dependency for go. We removed this dependency. The runtime dependency on golang-bin already contains the go binary executables.

Add symlinks for /usr/lib/golang/bin/{go,gofmt}
+++++++++++++++++++++++++++++++++++++++++++++++

The original release puts the binary executables go and gofmt into the folder ${GOHOME}/bin/linux_${ARCH}. Then the applications can not run these executables in the folder ${GOHOME}/bin. We modified the release so that there are symlinks for these executables in the folder ${GOHOME}/bin.
