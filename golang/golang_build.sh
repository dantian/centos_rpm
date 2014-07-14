#!/bin/bash 

set -e

###############################################################################################
#### A script to download go and build rpms for CSV environment                          ######
###############################################################################################

function usage {
cat <<EOF
USAGE: ./golang_build.sh -v <rpm_version> [-r <rpm_release>]
ARGS:
-v The version of the rpm package, e.g., 2.3.1 
-r (Optional) The release version of the rpm package, e.g., 1.csv, 1.csv.el6.3
EOF
exit 1
}

# Set default values for various arguments
NAME=golang
VERSION=1.3
RELEASE=1.xyz
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

echo "######## Check tools on build host ##############"

autoconf --version

automake --version

rpmbuild --version

gcc --version

echo "######## download src rpm package #############"

### Download src rpm package 
cd $WORKSPACE

### for version 1.1.2
#wget http://go.googlecode.com/files/go${VERSION}.src.tar.gz

### for version 1.3 
rm -rf ${NAME}-${VERSION}*.src.rpm

wget ftp://fr2.rpmfind.net/linux/fedora/linux/development/rawhide/source/SRPMS/g/${NAME}-${VERSION}-2.fc21.src.rpm

## build the rpm

rm -rf BUILD SPECS RPMS SOURCES SRPMS
mkdir -p {BUILD,SPECS,RPMS,SOURCES,SRPMS}

pushd SOURCES
rpm2cpio ${WORKSPACE}/${NAME}-${VERSION}-2.fc21.src.rpm | cpio  -idmv
popd

cp -f SOURCES/${NAME}.spec ${NAME}.spec
mv SOURCES/${NAME}.spec SOURCES/${NAME}.spec.orig

### Update version and release information

sed -i "s/Version:.*/Version: $VERSION/" ${NAME}.spec
sed -i "s/Release:.*/Release: ${RELEASE}%{?dist}/" ${NAME}.spec

### Turn off build check
sed -i 's:^CGO_ENABLED=0:#CGO_ENABLED=0:' ${NAME}.spec

### Comment out install dependency on go
sed -i "s/^Requires:.* go = %{version}-%{release}/#Requires:   go = %{version}-%{release}/g" ${NAME}.spec

### Add symlinks for /usr/lib/golang/bin and /usr/lib/golang/bin/gofmt
sed -i '/mv $RPM_BUILD_ROOT%{goroot}\/bin\/go $RPM_BUILD_ROOT%{goroot}\/bin\/linux_%{gohostarch}\/go/ a  ln -sf %{goroot}/bin/linux_%{gohostarch}/go $RPM_BUILD_ROOT%{goroot}/bin/go' ${NAME}.spec
sed -i '/mv $RPM_BUILD_ROOT%{goroot}\/bin\/gofmt $RPM_BUILD_ROOT%{goroot}\/bin\/linux_%{gohostarch}\/gofmt/ a ln -sf %{goroot}/bin/linux_%{gohostarch}/gofmt $RPM_BUILD_ROOT%{goroot}/bin/gofmt' ${NAME}.spec

sed -i '/^%{_bindir}\/go$/ a %{goroot}/bin/go' ${NAME}.spec
sed -i '/^%{_bindir}\/gofmt/ a %{goroot}/bin/gofmt' ${NAME}.spec

### Use the updated spec file for building the rpm
cp ${NAME}.spec SPECS/

echo "############## show package spec file ################"
cat ${NAME}.spec

### Show modifications to the original spec file in the src rpm

echo "###### Show differences between the original spec file SOURCES/${NAME}.spec.orig and the new spec file SPECS/${NAME}.spec ######" 
diff SOURCES/${NAME}.spec.orig SPECS/${NAME}.spec || echo "###### End of spec file differences ######"

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

