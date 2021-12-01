FROM quay.io/pypa/manylinux2010_x86_64:2021-11-28-06a91ec

RUN yum install -y zlib-devel gcc-c++

WORKDIR /app
COPY . /app/

RUN curl --progress-bar https://codeload.github.com/edenhill/librdkafka/tar.gz/refs/tags/v1.7.0 -o librdkafka-1.7.0.tar.gz && tar xzvf librdkafka-1.7.0.tar.gz && cd librdkafka-1.7.0 \
  && ./configure --clean && make clean \
  && ./configure --enable-static --install-deps --source-deps-only --disable-gssapi \
  && make -j && make install

RUN python3.6 setup.py bdist_wheel \
  && python3.7 setup.py bdist_wheel \
  && python3.8 setup.py bdist_wheel \
  && python3.9 setup.py bdist_wheel \
  && python3.10 setup.py bdist_wheel sdist

# Set NAME & VERSION same as setup.py
ENV NAME "pup_confluent_kafka"
ENV VERSION "1.7.1"

RUN cd dist \
  && auditwheel repair ${NAME}-${VERSION}-cp36-cp36m-linux_x86_64.whl \
  && auditwheel repair ${NAME}-${VERSION}-cp37-cp37m-linux_x86_64.whl \
  && auditwheel repair ${NAME}-${VERSION}-cp38-cp38-linux_x86_64.whl \
  && auditwheel repair ${NAME}-${VERSION}-cp39-cp39-linux_x86_64.whl \
  && auditwheel repair ${NAME}-${VERSION}-cp310-cp310-linux_x86_64.whl

WORKDIR /app/dist/wheelhouse
