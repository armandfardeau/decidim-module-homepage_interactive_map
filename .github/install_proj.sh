sudo apt-get update && sudo apt install cmake sqlite libtiff-dev curl libcurl4-openssl-dev libssl-dev -y

if [ ! -d "$PROJ_VERSION" ]; then
  curl https://download.osgeo.org/proj/"${PROJ_VERSION}".tar.gz -o "${PROJ_VERSION}".tar.gz
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
