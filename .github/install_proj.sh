sudo apt-get update && sudo apt-get install -y cmake sqlite libtiff-dev curl libcurl4-openssl-dev libssl-dev libproj-dev proj-bin

#  curl https://download.osgeo.org/proj/"${PROJ_VERSION}".tar.gz -o "${PROJ_VERSION}".tar.gz

if [ ! -d "$PROJ_VERSION" ]; then
  curl -L https://download.osgeo.org/proj/"${PROJ_VERSION}".tar.gz -o "${PROJ_VERSION}".tar.gz
  tar -xzf "${PROJ_VERSION}".tar.gz
fi

cd "$PROJ_VERSION" || exit

if [ ! -d "build" ]; then
  mkdir build
fi

cd build || exit
cmake ..
sudo cmake --build . -j "$(nproc)" --target install
sudo ldconfig

export PROJ_DIR=/usr/local
export PROJ_LIB=/usr/local/lib
export PROJ_INCLUDE=/usr/local/include

proj

echo "PROJ_DIR: $PROJ_DIR"
echo "PROJ_LIB: $PROJ_LIB"
echo "PROJ_INCLUDE: $PROJ_INCLUDE"

gem install rgeo-proj4 -- --with-proj-dir=$PROJ_DIR --with-proj-include=$PROJ_INCLUDE --with-proj-lib=$PROJ_LIB
bundle config build.rgeo-proj4 --with-proj-dir=$PROJ_DIR --with-proj-include=$PROJ_INCLUDE --with-proj-lib=$PROJ_LIB
bundle install
