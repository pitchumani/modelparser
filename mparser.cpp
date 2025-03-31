#include <onnx/onnx.pb.h>   // ONNX protobuf header
#include <iostream>
#include <fstream>

void display_model_insights(const onnx::ModelProto& model) {
    std::cout << "Model Insights:" << std::endl;
    std::cout << "-----------------" << std::endl;

    // Iterate through the nodes (operations) in the model
    for (const auto& node : model.graph().node()) {
        std::cout << "Operation: " << node.op_type() << std::endl;

        // Display input and output tensor information
        std::cout << "Inputs: ";
        for (const auto& input : node.input()) {
            std::cout << input << " ";
        }
        std::cout << std::endl;

        std::cout << "Outputs: ";
        for (const auto& output : node.output()) {
            std::cout << output << " ";
        }
        std::cout << std::endl;

        // Additional information like weights, biases can be displayed here
        // For Conv, you can display kernel size, strides, etc.
        if (node.op_type() == "Conv") {
            // Assume Conv node has weight parameters as inputs
            std::cout << "Convolution layer detected." << std::endl;
            std::cout << "Kernel Size: ... (To be implemented)" << std::endl;
        }

        std::cout << "-----------------" << std::endl;
    }
}

void analyze_parameters(const onnx::ModelProto& model) {
    int total_params = 0;

    std::cout << "-----------------" << std::endl;
    // Iterate over the graph's initializer to count the parameters (weights, biases)
    for (const auto& initializer : model.graph().initializer()) {
        std::cout << "Parameter: " << initializer.name() << std::endl;
        total_params += initializer.int64_data_size();
    }

    std::cout << "Total Parameters: " << total_params << std::endl;
    std::cout << "-----------------" << std::endl;
}

// Function to load and parse the ONNX model
void parse_onnx_model(const std::string& model_path, onnx::ModelProto& model) {

    // Open the ONNX model file
    std::ifstream input_model(model_path, std::ios::binary);
    if (!input_model) {
        std::cerr << "Failed to open the ONNX model file!" << std::endl;
        return;
    }

    // Parse the model using the Protobuf API
    if (!model.ParseFromIstream(&input_model)) {
        std::cerr << "Failed to parse the ONNX model!" << std::endl;
        return;
    }

    // Output some basic information about the model
    std::cout << "Model parsed successfully!" << std::endl;
    // ModelProto info
    std::cout << "ir_version: " << model.ir_version() << std::endl;
    std::cout << "producer_name: " << model.producer_name() << std::endl;
    std::cout << "producer_version: " << model.producer_version() << std::endl;
    std::cout << "domain: " << model.domain() << std::endl;
    // ModelProto.graph info
    std::cout << "Model name: " << model.graph().name() << std::endl;
    std::cout << "Number of nodes (operations): " << model.graph().node_size() << std::endl;
    std::cout << "-----------------" << std::endl;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <onnx_model_path>" << std::endl;
        return 1;
    }

    onnx::ModelProto model;
    const std::string model_path = argv[1];
    parse_onnx_model(model_path, model);

    // display_model_insights(model);
    // analyze_parameters(model);
    return 0;
}
