if [ ! -d "leptonica" ]; then
  mkdir ~/downloads
  wget https://github.com/DanBloomberg/leptonica/archive/v1.73.zip -O ~/downloads/leptonica.zip
  unzip ~/downloads/leptonica.zip
  mv leptonica-1.73 leptonica
fi

cd leptonica

if [ ! -e "prog/dna_reg" ]; then
  chmod +x ./configure
  ./configure
  make
fi

sudo make install
sudo ldconfig

cd ../

if [ ! -d "tesseract" ]; then
  mkdir ~/downloads
  wget https://github.com/tesseract-ocr/tesseract/archive/3.04.00.zip -O ~/downloads/tesseract.zip
  unzip ~/downloads/tesseract.zip
  mv tesseract-3.04.00 tesseract
fi

cd tesseract

if [ ! -e "api/tesseract" ]; then
  ./autogen.sh
  ./configure
  make
fi

sudo make install
sudo ldconfig

mkdir -p /usr/share/tessdata
cd /usr/share/tessdata
wget https://github.com/tesseract-ocr/tessdata/raw/master/eng.traineddata
wget https://github.com/tesseract-ocr/tessdata/raw/master/ita.traineddata
