// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

enum ProductType {
    Piamon,
    BlindBox
}

enum Element {
    Fire,
    Earth,
    Aqua,
    Wind,
    Light,
    Darkness
}

enum Race {
    Feathery,
    Furry,
    Scally,
    Crysty,
    Slimy,
    Voidy
}

struct PiamonTemplate {
    uint256 templateId;
    string metadataURI;
    uint256 price;
    uint256 totalQuantity;
}

struct BlindBox {
    string name;
    string imageUrl;
    string randomBoxUrl;
    string description;
    string baseMetadataUrl;
    uint256 price;
    uint256 saleTimeStart;
    uint256 saleTimeEnd;
    bool isSaleOpen;
    uint256 totalQuantity;
    uint256 unboxTime;
}

struct WhiteList {
    address minterAddress;
    uint256 price;
    uint256 availableQuantity;
}
