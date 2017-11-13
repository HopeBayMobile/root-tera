
# How To Use Script

# 1.Prepare apk and hcfs first
## Apk name app-release.apk
## HCFS from source build, and copy hold system folder
## Apk with branch tmp_root_tera and name apk app-release.apk.
## HCFS with branch root_android_7_0 and name directory system.

# 2. Prepare two libcurl for 6.0.1 and 7.1.2
## then name libcurl-32bit-6.0.1.so and libcurl-32bit-7.1.2.so

# ONLY use this script with last commit contain "Version: xxxx"


HCFS_32_dir="system"
apk_filename="app-release.apk"


get_latest_version() {
    git log | grep --regexp="Version: " -m 1 | sed 's/Version: //g' | sed 's/    //g' > ./out/version
}

checkout() {
    git checkout .
}

message() {
    echo
    echo "Packaging $1"
    echo
}

package() {
    # Add version name for directory
    version=`cat ./out/version`
    echo "Root-tera Version: $version"
    mv root-tera root-tera-$version-$1
    zip -r out/root-tera-$version-$1.zip root-tera-$version-$1
    mv root-tera-$version-$1 root-tera
}

copy_hcfs_32bit() {
    check_hcfs_files    
    cp -r out/system/bin/* root-tera/files/
    cp -r out/system/lib/* root-tera/files/
    remove_unnecessary
}

check_hcfs_files() {    
    if [ ! -d ./out/$HCSF_32_dir ]; then
	echo "./out/system not found"
	exit 1
    fi
}

copy_apk() {
    check_apk_file
    cp -r out/app-release.apk root-tera/files/HopebayHCFSmgmt.apk
}

check_apk_file() {
    if [ ! -e ./out/$apk_filename ]; then
	echo "app-release.apk not found in ./out"
	exit 1
    fi
}

check_libcurl_file() {
    if [ ! -e ./out/$1 ]; then
	echo "prebuild libcurl not found: $1"
	exit 1
    fi

    echo "libcurl file found: $1"
}

remove_unnecessary() {
    rm root-tera/files/api_test
    rm root-tera/files/libhcfsapi.so
    rm root-tera/files/liblz4-tera.so
}

seven_to_eight_64() {
    version="7.1.X-8.0.0_64-bit"
    message $version

    git checkout origin/master
    copy_apk
    
    package $version
    checkout
}

seven_to_eight_32() {
    version="7.1.X-8.0.0_32-bit"
    message $version

    git checkout origin/master
    copy_hcfs_32bit

    # Copy coresponding libcurl
    check_libcurl_file libcurl-32bit-7.1.2.so
    cp -r out/libcurl-32bit-7.1.2.so root-tera/files/libcurl.so

    copy_apk

    package $version
    checkout
}

six_to_seven_64() {
    version="6.0.X-7.0.0_64-bit"
    message $version

    git checkout origin/feature/android_7_0
    cp -r root-tera/files out/
    git checkout origin/master
    cp -r out/files root-tera/

    copy_apk
    package $version
    rm -rf out/files
    checkout
}

six_to_seven_32() {
    version="6.0.X-7.0.0_32-bit"
    message $version

    git checkout origin/master

    copy_hcfs_32bit

    # Copy coresponding libcurl
    check_libcurl_file libcurl-32bit-6.0.1.so
    cp -r out/libcurl-32bit-6.0.1.so root-tera/files/libcurl.so

    copy_apk
    package $version
    checkout
}

four_point_four_32() {
    version="4.4.X_32-bit"
    message $version

    git checkout origin/master
    copy_hcfs_32bit
    copy_apk

    package $version
    checkout
}

# Main


if [[ $1 == "clean" ]]; then
    rm -rf out/root-tera*.zip
    echo "Clean package in ./out"
    echo ""
    ls -l ./out
    exit 0
fi


if [ ! -d out ]; then
    mkdir out
    echo "put necessery apk and hcfs in ./out"
    exit 1
fi

git checkout .
git checkout origin/master
get_latest_version

seven_to_eight_64
seven_to_eight_32
six_to_seven_64
six_to_seven_32
four_point_four_32

rm ./out/version
