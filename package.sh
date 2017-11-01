# Prepare apk and hcfs first
# Apk with branch tmp_root_tera and name apk app-release.apk.
# HCFS with branch root_android_7_0 and name directory system. 
# ONLY use this script with last commit contain Version: xxxx 


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
    
    zip -r out/root-tera-`cat ./out/version`_$1.zip root-tera
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
    copy_apk
    package $version
    checkout
}


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

rm ./out/version
