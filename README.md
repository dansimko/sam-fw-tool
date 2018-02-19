This simple bash script automate tasks required to decompress images in newer Odin firmwares for use with Odin <= 3.12.10

## Usage

If executed without any command line options, the script will automatically look for *.tar.md5 files in current working directory, unpack them, decompress the images and create new .tar.md5 archives, which can be used with (older) Odin.

	# ./repack.sh

You can also specify working directory:

	# ./repack.sh -d path/to/your/extracted/firmware

or you can point the script to zip archive of the firmware:

	# ./repack.sh -f path/to/your/zip/firmware

The zip archive will be extracted to current working directory. Fortunately, you can use both flags at the same time:

	# ./repack.sh -d path/to/your/working/dir -f path/to/your/zip/firmware

By default, the resulting files will be stored in `pwd`/firmware, this can be overriden using -o flag:

	# ./repack.sh -o output/path
