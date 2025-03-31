.DEFAULT_GOAL := all
CXX=g++
ONNX_SRC_DIR=onnx

onnx_build_dir := `pwd`/onnx/build
onnx_install_dir := ~/install/onnx

build_onnx: onnx
	cd onnx && mkdir -p build
	cd $(onnx_build_dir) && cmake -DCMAKE_INSTALL_PREFIX=$(onnx_install_dir) ..
	cd $(onnx_build_dir) && make -j4 && make -j4 install

BUILD_FLAGS=-I $(onnx_install_dir)/onnx/include -I include
LINKER_FLAGS=-L $(onnx_install_dir)/onnx/lib64 -lonnx -lprotobuf

ONNX_PROTOBUF_FILES := $(addprefix include/onnx/, \
	onnx.pb.cc onnx.pb.h)

onnx_pb: $(ONNX_PROTOBUF_FILES)
	mkdir -p include/onnx
	protoc -I ${ONNX_SRC_DIR}/onnx/ onnx.proto --cpp_out=include/onnx

mparser: build_onnx onnx_pb
	$(CXX) -o mparser mparser.cpp include/onnx/onnx.pb.cc ${BUILD_FLAGS} ${LINKER_FLAGS}

all: mparser


# model
# wget https://github.com/onnx/models/blob/main/validated/vision/classification/mobilenet/model/mobilenetv2-12.tar.gz

mobilenetv2_12 := models/mobilenetv2-12/mobilenetv2-12.onnx
mobilenetv2_12_extract: $(mobilenetv2_12)
	mkdir -p models
	wget https://github.com/onnx/models/blob/main/validated/vision/classification/mobilenet/model/mobilenetv2-12.tar.gz
	cd models
	tar xf mobilenetv2-12.tar.gz

run-mobilenet: mparser $(mobilenetv2_12)
	./mparser $(mobilenetv2_12)

