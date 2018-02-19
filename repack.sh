#!/bin/bash

command -v unzip >/dev/null 2>&1 || { echo "Unzip package is reuqired. Aborting." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "Tar package is reuqired. Aborting." >&2; exit 1; }
command -v lz4 >/dev/null 2>&1 || { echo "liblz4-tool package is reuqired. Aborting." >&2; exit 1; }
command -v md5sum >/dev/null 2>&1 || { echo "md5sum package is reuqired. Aborting." >&2; exit 1; }

dir=`pwd`
file=""

usage() {
    echo "Usage: $0 [-d <directory>] [-f <file>]

Option					Meaning
 -h					Show this help text and exit
 -d					Set working directory
 -f					Input is ZIP archive containing FW"
    exit
}

fw_check() {
count=`ls -1 *.tar.md5 2>/dev/null | wc -l`
if [ $count != 0 ]; then
    echo "Found potential Odin archive(s)"
else
    echo "Odin firmware not found"
    exit 1
fi
}

extract_zip() {
    if [ ! -f "${1}" ]; then
        echo "Specified file not found!"
        usage
    fi
    filename="${1##*/}"
    dir="${dir}/${filename%.zip}"
    unzip -qq "${1}" -d "${dir}"
}

decompress_data() {
[ -d "${entry%.tar.md5}" ] || mkdir "${entry%.tar.md5}"
    tar_result="$(tar -xvf ${entry} -C ${entry%.tar.md5})"
    tar_result="${tar_result//$'\n'/ }"
    tar_result="${tar_result//.lz4/}"
    lz4 -md "${entry%.tar.md5}/*.lz4"
    archivename="${entry##*/}"
    tar -H ustar --directory="${entry%.tar.md5}" -cf "${entry%.tar.md5}/${archivename%.md5}" ${tar_result}
    $(cd "${entry%.tar.md5}" && md5sum -t "${archivename%.md5}" >> "${archivename%.md5}")
    mv "${entry%.tar.md5}/${archivename%.md5}" "${entry%.tar.md5}/${archivename}"
}

while getopts ":hd:f:" o; do
    case "${o}" in
        h)
            usage
            ;;
        d)
            dir=${OPTARG}
            ;;
        f)
            file=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -z "${file}" ]; then
    extract_zip "${file}"
fi

fw_check

for entry in ${dir}/*.tar.md5; do
    decompress_data
done
