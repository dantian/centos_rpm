#!/bin/bash 

set -e

########################################################################################################
#### A script to download Amazon aws-cfn-bootstrap source RPM and build a runtime RPM for CentOS-6.x
########################################################################################################

NAME="aws-cfn-bootstrap"

# Go through the command line options to set variables

WORKSPACE=$PWD

### Download src rpm package of aws-cfn-bootstrap-latest.src.rpm
cd $WORKSPACE

rm -rf ${NAME}*.src.rpm
wget https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.src.rpm 

## build the rpm

rm -rf BUILD SPECS RPMS SOURCES SRPMS
mkdir -p {BUILD,SPECS,RPMS,SOURCES,SRPMS}

pushd SOURCES
rpm2cpio ${WORKSPACE}/${NAME}-latest.src.rpm | cpio  -idmv
popd

cp SOURCES/${NAME}.spec SPECS/

## Update ${NAME}.spec file for CentOs-6.x

PYTHON_SITELIB=`python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"`

sed -i "s#%global python_sitelib %{sys_python_sitelib}#%global python_sitelib ${PYTHON_SITELIB}#" SPECS/${NAME}.spec 
sed -i 's#%global __python %{__sys_python}#%global __python /usr/bin/python#' SPECS/${NAME}.spec
sed -i 's#BuildRequires: system-python#BuildRequires: python#' SPECS/${NAME}.spec
sed -i 's#Requires: %{sys_python_pkg}-daemon#Requires: python-daemon#' SPECS/${NAME}.spec
sed -i 's#Requires: %{sys_python_pkg}-pystache#Requires: pystache#' SPECS/${NAME}.spec

echo "### Show RPM spec file differences: diff SOURCES/${NAME}.spec SPECS/${NAME}.spec ###"
diff SOURCES/${NAME}.spec SPECS/${NAME}.spec || echo "### show spec file updates ###"

echo "### Rename SOURCES/${NAME}.spec as SOURCES/${NAME}.spec.orig ###"
mv SOURCES/${NAME}.spec SOURCES/${NAME}.spec.orig

echo "### Build the runtime RPM ###"
/usr/bin/rpmbuild -ba --define="_topdir $PWD" --define="_tmppath $PWD/_tmp" SPECS/${NAME}.spec

echo "### Show the runtime RPM file ###"
ls -l RPMS/noarch/${NAME}-*.rpm

