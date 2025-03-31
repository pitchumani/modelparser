.DEFAULT_GOAL := all
CXX=g++
ONNX_SRC_DIR=onnx

onnx_build_dir := onnx/build
onnx_install_dir := ~/install/onnx

build_onnx: onnx
	echo "Build and Install onnx"
	cd onnx && mkdir -p build
	cd $(onnx_build_dir) && cmake -DCMAKE_INSTALL_PREFIX=$(onnx_install_dir) ..
	cd $(onnx_build_dir) && make -j4 && make -j4 install
	echo "files in onnx install dir"
	ls $(onnx_install_dir)/
	ls $(onnx_install_dir)/lib

BUILD_FLAGS=-I $(onnx_install_dir)/onnx/include -I include
LINKER_FLAGS=-L $(onnx_install_dir)/onnx/lib64 -L $(onnx_install_dir)/onnx/lib $(onnx_install_dir)/lib/libonnx.a -lprotobuf

ONNX_PROTOBUF_FILES := $(addprefix include/onnx/, \
	onnx.pb.cc onnx.pb.h)

onnx_pb: $(ONNX_PROTOBUF_FILES)
	echo "Build onnx protobuf files"
	mkdir -p include/onnx
	protoc -I ${ONNX_SRC_DIR}/onnx/ onnx.proto --cpp_out=include/onnx

mparser: build_onnx onnx_pb
	echo "Build model parser 'mparser'"
	ls include/
	$(CXX) -o mparser mparser.cpp include/onnx/onnx.pb.cc ${BUILD_FLAGS} ${LINKER_FLAGS}

all: mparser


# model
# wget https://github.com/onnx/models/blob/main/validated/vision/classification/mobilenet/model/mobilenetv2-12.tar.gz

mobilenetv2_12 := models/mobilenetv2-12/mobilenetv2-12.onnx
mobilenetv2_12_extract: $(mobilenetv2_12)
	echo "Download and extract MobileNetv2.12 model"
	mkdir -p models
	wget https://github.com/onnx/models/blob/main/validated/vision/classification/mobilenet/model/mobilenetv2-12.tar.gz
	cd models
	tar xf mobilenetv2-12.tar.gz

run-mobilenet: mparser $(mobilenetv2_12)
	echo "Parse MobileNetv2.12 model"
	./mparser $(mobilenetv2_12)

