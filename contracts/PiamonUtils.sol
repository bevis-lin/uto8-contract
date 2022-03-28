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
    uint16 computingPower;
    string headPart;
    string earPart;
    string eyePart;
}

struct PiamonBox {
    uint256 templateId;
    PiamonData data;
    bool isAllocated;
}

struct EggInfo {
    uint256 templateId;
    bool isOpened;
    PiamonBox box;
}
