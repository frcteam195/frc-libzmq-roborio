YEAR=$(shell grep Package packageinfo/control | cut -c 13-16)
VER=$(shell grep Version packageinfo/control | cut -c 10-)
IPK_NAME=frc${YEAR}-libzmq_${VER}_cortexa9-vfpv3.ipk
DOCKER_IMAGE=roborio-cross-${YEAR}-t195

ipk: ${IPK_NAME}
	
libzmq: libzmq_${VER}.so

libzmq_${VER}.so:
	mkdir -p build
	docker run --rm -v ${PWD}/build:/artifacts ${DOCKER_IMAGE} /bin/bash -c '\
		curl -SLO https://github.com/zeromq/libzmq/releases/download/v${VER}/zeromq-${VER}.tar.gz \
		&& tar xzf zeromq-${VER}.tar.gz \
		&& cd zeromq-${VER} \
		&& ./configure --host=arm-frc${YEAR}-linux-gnueabi CC=arm-frc${YEAR}-linux-gnueabi-gcc CXX=arm-frc${YEAR}-linux-gnueabi-g++ \
		&& make -j4 \
		&& chown -R `id -u`:`id -g` src/.libs/libzmq.so \
		&& arm-frc${YEAR}-linux-gnueabi-strip src/.libs/libzmq.so \
		&& cp src/.libs/libzmq.so /artifacts/libzmq.so'
	'
	
clean:
	docker run --rm -v ${PWD}/build:/artifacts ${DOCKER_IMAGE} /bin/bash -c '\
		cd /artifacts \
		&& rm -f libzmq.so \
		&& rm -f control.tar.gz \
		&& rm -f data.tar.gz \
		&& rm -f debian-binary \
		&& rm -f ${IPK_NAME} \'
	
${IPK_NAME}: libzmq_${VER}.so
	
include buildenv/Makefile