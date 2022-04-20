// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SalesProvider is Ownable {
    BlindBox[] public blindBoxes;
    PiamonTemplate[] public piamonTemplates;

    struct BlindBox {
        string name;
        string imageUrl;
        string randomBoxUrl;
        string description;
        string piamonMetadataUrl;
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

    struct PiamonTemplate {
        uint256 templateId;
        string metadataURI;
        uint256 price;
        uint256 totalQuantity;
    }

    constructor() {
        // Set the transaction sender as the owner of the contract.
        //owner = msg.sender;
    }

    //keep white list for a blindbox
    mapping(uint256 => WhiteList[]) public blindBoxWhiteList;

    function addBlindBox(BlindBox memory _blindBox) public onlyOwner {
        blindBoxes.push(_blindBox);
    }

    function addWhiteListStruct(
        uint256 _blindBoxId,
        WhiteList memory _whiteList
    ) public onlyOwner {
        blindBoxWhiteList[_blindBoxId].push(_whiteList);
    }

    function addPiamonTemplateStruct(PiamonTemplate memory _template)
        public
        onlyOwner
    {
        piamonTemplates.push(_template);
    }

    function checkIsSaleOpen(uint256 _blindBoxId) public view returns (bool) {
        return blindBoxes[_blindBoxId].isSaleOpen;
    }

    function checkIsSaleStart(uint256 _blindBoxId) public view returns (bool) {
        return blindBoxes[_blindBoxId].saleTimeStart <= block.timestamp;
    }

    function checkIsSaleEnd(uint256 _blindBoxId) public view returns (bool) {
        return blindBoxes[_blindBoxId].saleTimeEnd > block.timestamp;
    }

    function getSaleTotalQuantity(uint256 _blindBoxId)
        public
        view
        returns (uint256)
    {
        return blindBoxes[_blindBoxId].totalQuantity;
    }

    function getSalePrice(uint256 _blindBoxId) public view returns (uint256) {
        return blindBoxes[_blindBoxId].price;
    }

    function getMetadataForBlindBox(uint256 _blindBoxId)
        public
        view
        returns (
            string memory name,
            string memory imageUrl,
            string memory description,
            string memory piamonMetadataUrl
        )
    {
        BlindBox storage blindBox = blindBoxes[_blindBoxId];
        name = blindBox.name;
        imageUrl = blindBox.imageUrl;
        description = blindBox.description;
        piamonMetadataUrl = blindBox.piamonMetadataUrl;
    }

    function getTemplate(uint256 _templateId)
        public
        view
        returns (
            string memory metadataURI,
            uint256 price,
            uint256 totalQuantity
        )
    {
        PiamonTemplate storage template = piamonTemplates[_templateId];
        metadataURI = template.metadataURI;
        price = template.price;
        totalQuantity = template.totalQuantity;
    }

    function checkIsWhiteListed(uint256 _blindBoxId, address _address)
        public
        view
        returns (bool)
    {
        bool isInWhiteList = false;

        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                isInWhiteList = true;
                break;
            }
        }

        return isInWhiteList;
    }

    function getWhiteList(uint256 _blindBoxId, address _address)
        public
        view
        returns (uint256 availableQuantity, uint256 price)
    {
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                availableQuantity = whiteList.availableQuantity;
                price = whiteList.price;
                break;
            }
        }
    }

    function decreaseWhiteListAvailableQuantity(
        uint256 _blindBoxId,
        address _address
    ) public returns (uint256 remainQuantity) {
        //uint256 remainQty = 0;
        WhiteList[] storage lists = blindBoxWhiteList[_blindBoxId];
        for (uint256 i = 0; i < lists.length; i++) {
            WhiteList storage whiteList = lists[i];
            if (whiteList.minterAddress == _address) {
                if (whiteList.availableQuantity > 0) {
                    whiteList.availableQuantity--;
                }
                remainQuantity = whiteList.availableQuantity;
                break;
            }
        }
    }
}
