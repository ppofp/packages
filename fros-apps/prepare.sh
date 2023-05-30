test -z $1 && exit 1
test -z $2 && exit 1
test -z $3 && exit 1
echo "=====================pkg dir = $1, board = $2, sub = $3============================"
PKG_DIR=$1
ARCH="$2_$3"
echo "build_dir = $PKG_DIR, ARCH=$ARCH"
cp ./src/$ARCH/* $PKG_DIR -fr
