#!/bin/sh

[ -z "$1" ] && {
  echo "missing argument"
  exit 1
}

BINARY=$(realpath $1) || exit 1

[ -f $BINARY ] || {
  echo "could not find $1"
  exit 1
}

DIR=$(mktemp -d)
pushd $DIR &>/dev/null

echo "FROM scratch" > Dockerfile

for file in $(ldd $BINARY | sed -r 's/[^ ]+ => ([^\(]+) \(0x.+/\1/g'); do
  [ -f $file ] && {
    cp $file .
    echo "COPY $(basename $file) $(dirname $file)/" >> Dockerfile
  }
done

cp $BINARY .
echo "COPY $(basename $BINARY) /" >> Dockerfile
echo "ENTRYPOINT [\"/$(basename $BINARY)\"]" >> Dockerfile

docker build -t $(basename $BINARY) .

popd &>/dev/null
rm -rf $DIR
