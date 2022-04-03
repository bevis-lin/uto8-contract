// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

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
    int256 allocatedId; //NFT Id
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
    string saleOpenTime;
    string saleCloseTime;
    string unboxTime;
    // int256 limitedElement;
    // int256 limitedRace;
}
