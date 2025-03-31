.DEFAULT_GOAL := all
CXX=g++
BUILD_FLAGS=-I ~/install/onnx/include -I include -lonnx -lprotobuf
LINKER_FLAGS=-L ~/install/onnx/lib64
ONNX_SRC_DIR=~/code/onnx

ONNX_PROTOBUF_FILES := $(addprefix include/onnx/, \
	onnx.pb.cc onnx.pb.h)

onnx_pb: $(ONNX_PROTOBUF_FILES)
	mkdir -p include/onnx
	protoc -I ${ONNX_SRC_DIR}/onnx/ onnx.proto --cpp_out=include/onnx

mparser: onnx_pb
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

