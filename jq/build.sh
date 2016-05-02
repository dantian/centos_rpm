#!/bin/bash 

set -e

###############################################################################################
#### A script to download jq and install on a CentOS-5 or CentOS-6 host                  ######
###############################################################################################

function usage {
cat <<EOF
USAGE: ./build.sh -v <rpm_version> [-r <rpm_release>]
ARGS:
-v The version of the rpm package, e.g., 2.3.1 
-r (Optional) The release version of the rpm package, e.g., 1.csv, 1.csv.el6.3
EOF
exit 1
}

# Set default values for various arguments
NAME=jq
RELEASE=1.csv
ARCH=`/bin/arch`



# Go through the command line options to set variables

while getopts "v:r:h:" flag
do
    case "${flag}" in
        v) VERSION="$OPTARG"; echo "version set to $VERSION";;
        r) RELEASE="$OPTARG"; echo "release set to $RELEASE";;
        h) usage;;
        *) echo Unknown flag $flag; usage;;
    esac
done

[ -z $VERSION ] && echo "Version must be set." && usage

WORKSPACE=$PWD

### Check build tool versions

echo "############# check version: autoconf -V ##########"
autoconf -V

echo "############ check version: gcc --version #########"
gcc --version


### Download src rpm package 
cd $WORKSPACE

### for version 1.5
#wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-1.5.tar.gz

curl -Ovl https://github.com/stedolan/${NAME}/releases/download/${NAME}-${VERSION}/${NAME}-linux64

curl -Ovl https://github.com/stedolan/${NAME}/releases/download/${NAME}-${VERSION}/${NAME}-linux32

## build the rpm

rm -rf BUILD SPECS RPMS SOURCES SRPMS
mkdir -p {BUILD,SPECS,RPMS,SOURCES,SRPMS}

cp ${NAME}-linux* SOURCES

sed -i "s/Version:.*/Version: $VERSION/" ${NAME}.spec
sed -i "s/Release:.*/Release: ${RELEASE}%{?dist}/" ${NAME}.spec

cp ${NAME}.spec SPECS/

echo "############## show package spec file ################"
cat ${NAME}.spec

if [ "$ARCH" == "x86_64" ]
then
    /usr/bin/rpmbuild -ba --define="_topdir $PWD" --define="_tmppath $PWD/_tmp" SPECS/${NAME}.spec
else
    /usr/bin/rpmbuild -ba --define="_topdir $PWD" --define="_tmppath $PWD/_tmp" --define="dist .el5" SPECS/${NAME}.spec
fi

### Move rpm files into folder $WORKSPACE/dist
cd $WORKSPACE
rm -rf $WORKSPACE/dist
mkdir -p $WORKSPACE/dist
mv $WORKSPACE/RPMS/*/*.rpm $WORKSPACE/dist/
mv $WORKSPACE/SRPMS/*.rpm $WORKSPACE/dist/

for file in dist/*.rpm; do 
    echo "############ $file contents #############" 
    rpm -qpl $file
    echo "############ $file dependencies ##############"
    rpm -qpR $file
done


