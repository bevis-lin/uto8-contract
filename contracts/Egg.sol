// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";
import "./EggTemplates.sol";

contract Egg is ERC721, EggTemplates {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    //nft_id => EggInfo
    mapping(uint256 => EggInfo) public mintedEggs;

    constructor() ERC721("PiamonEgg", "NFT") {
        owner = msg.sender;
    }

    function mintTo(address recipient, uint256 _templateId)
        public
        returns (uint256)
    {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        EggInfo memory eggInfo;
        eggInfo.templateId = _templateId;
        eggInfo.isOpened = false;
        mintedEggs[newItemId] = eggInfo;
        return newItemId;
    }

    function unbox(uint256 nftId) public onlyOwner {
        EggInfo storage eggInfo = mintedEggs[nftId];
        require(eggInfo.isOpened == false, "This egg is already opened");

        PiamonBox memory availableBox;
        while (availableBox.templateId == 0) {
            availableBox = getAvailableBox(eggInfo.templateId);
        }
        eggInfo.box = availableBox;
        eggInfo.isOpened = true;
    }
}
