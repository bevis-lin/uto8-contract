// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

struct PiamonData {
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
}

struct PiamonBox {
    string boxId; //1000001
    PiamonData data;
    int256 allocatedId; //NFT Id
}

struct EggInfo {
    uint256 templateId;
    bool isOpened;
    PiamonBox box;
}

struct BlindBox {
    uint256 id;
    string name;
    string c_name;
    string imageUrl;
    string filmUrl;
    string description;
    string c_description;
    int256 currency;
    int256 price;
    string saleOpenTime;
    string saleCloseTime;
    string unboxTime;
    int256 limitedElement;
    int256 limitedRace;
}


/////// BLINDBOX_ICON
/////// BLINDBOX_NAME_ZHTW
/////// BLINDBOX_DESCRIPTION_ZHTW
/////// BLINDBOX_NAME
/////// BLINDBOX_DESCRIPTION
/////// BLINDBOX_CURRENCY
/////// BLINDBOX_PRICE
/////// BLINDBOX_SALESSTART_DATE
/////// BLINDBOX_SALESEND_DATE
/////// BLINDBOX_OPEN_DATE
/////// BLINDBOX_ELEMENT_LIMIT
/////// BLINDBOX_RACE_LIMIT
/////// BLINDBOX_FILM
/////// with revailed race is optional 
}
