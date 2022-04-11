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

struct PiamonBox {
    uint256 serialNo;
    Element element;
    Race race;
    uint16 spiritualPower;
    string headPart;
    string earPart;
    string eyePart;
    string tailPart;
    string mouthPart;
    string backPart;
    bool isCustom;
    uint256 allocatedId; //NFT Id
}

struct PiamonTemplate {
    uint256 templateId;
    string metadataURI;
    uint256 price;
    uint256 totalQuantity;
}

struct BlindBox {
    //string code;
    string name;
    string imageUrl;
    //string filmUrl;
    string description;
    // string c_description;
    // int256 currency;
    uint256 price;
    bool isSaleOpen;
    uint256 totalQuantity;
    uint256 unboxTime;
    // int256 limitedElement;
    // int256 limitedRace;
}

struct WhiteList {
    address minterAddress;
    uint256 price;
    uint256 availableQuantity;
}
