import mnist_loader
import network

if __name__ == "__main__":
    print("Begin training")
    traing_data, validation_data, test_data = mnist_loader.load_data_wrapper()
    net = network.Network([784, 30, 10])
    net.SGD(traing_data, 30, 10, 3.0, test_data=test_data)