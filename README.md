## litecoin-core

This repository contains the necessary files to build litecoin core from source code. 
Litecoin core is the official full node implementation for the litecoin cryptocurrency.

## Building Litecoin Core
To build litecoin core from source, follow these steps:

### Clone this repository:
```
git clone https://github.com/0xanonymeow/litecoin-core.git
```

### Navigate to the cloned directory:
```
cd litecoin-core
```

### Run the build script:
```
./build.sh
```

This will build the litecoin core software from source inside a docker container and run the litecoin daemon.

## Note
In case the savannah server is down or unreachable, the build script has been configured to fetch the updated `config.guess` and `config.sub` files from a gist. 
This ensures that the build process remains uninterrupted even when the official server is unavailable.

## Contributing
If you encounter any issues or have suggestions for improvements, feel free to open an issue or submit a pull request.

## License
Litecoin Core is released under the MIT License. [LICENSE](LICENSE)
