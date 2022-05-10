FROM ubuntu:20.04

# set non-interactive shell
ENV DEBIAN_FRONTEND noninteractive

# install base packages
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      wget \
      cmake \
      libgtest-dev \
      libgmock-dev \
      net-tools \
      lcov \ 
      iputils-ping \
      nodejs \
      openjdk-11-jdk \
      maven \
      git 

# Args
ARG CMAKE_BUILD_TYPE="Release"
ARG LEVELDB_VERSION="1.22"
ARG NURAFT_VERSION="1.3.0"
ARG JMETER_VERSION="5.4.3"

# Install LevelDB
RUN wget https://github.com/google/leveldb/archive/${LEVELDB_VERSION}.tar.gz && \
    tar xzvf ${LEVELDB_VERSION}.tar.gz && \
    rm -f ${LEVELDB_VERSION}.tar.gz && \
    cd leveldb-${LEVELDB_VERSION} && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DLEVELDB_BUILD_TESTS=0 -DLEVELDB_BUILD_BENCHMARKS=0 -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DBUILD_SHARED_LIBS=0 . && \
    make -j$(nproc) && \
    make install

# Install NuRaft
RUN wget https://github.com/eBay/NuRaft/archive/v${NURAFT_VERSION}.tar.gz && \
    tar xzvf v${NURAFT_VERSION}.tar.gz && \
    rm v${NURAFT_VERSION}.tar.gz && \
    cd "NuRaft-${NURAFT_VERSION}" && \
    ./prepare.sh && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DDISABLE_SSL=1 -DCMAKE_POSITION_INDEPENDENT_CODE=ON .. && \
    make -j$(nproc) static_lib && \
    cp libnuraft.a /usr/local/lib && \
    cp -r ../include/libnuraft /usr/local/include 



# Install Jmeter
RUN wget https://downloads.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && \
    tar -xf apache-jmeter-${JMETER_VERSION}.tgz -C /opt/ && \
    rm apache-jmeter-${JMETER_VERSION}.tgz  
# Disable SSL
RUN sed -i 's/#server.rmi.ssl.disable=false/server.rmi.ssl.disable=true/' /opt/apache-jmeter-${JMETER_VERSION}/bin/user.properties
# Set JMeter server engine port
RUN echo "server.rmi.localport=4000"  >> /opt/apache-jmeter-${JMETER_VERSION}/bin/user.properties
ENV remote true
# Set working directory
WORKDIR /opt/tx-processor

WORKDIR /opt/tx-processor/src/uhs/client/JmeterCustomSampler
COPY src/uhs/client/JmeterCustomSampler/pom.xml ./pom.xml
RUN mvn verify clean 
COPY src/uhs/client/JmeterCustomSampler .
RUN mvn package 
RUN cp /opt/tx-processor/src/uhs/client/JmeterCustomSampler/target/JmeterCustomSampler-1.0-SNAPSHOT.jar /opt/apache-jmeter-5.4.3/lib/ext/JmeterCustomSampler-1.0-SNAPSHOT.jar
RUN javac -h . -cp target/classes /opt/tx-processor/src/uhs/client/JmeterCustomSampler/src/main/java/hu/bme/mit/opencbdc/OpenCBDCJavaClient.java
WORKDIR /opt/tx-processor

# Copy source
COPY . .
# Update submodules and run configure.sh
RUN git submodule init && git submodule update --merge
WORKDIR /opt/tx-processor

# Build binaries
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} .. && \
    make -j$(nproc)
