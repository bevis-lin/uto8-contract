// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./SalesBatch.sol";

contract Piamon is ERC721URIStorage, SalesBatch {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    using Strings for uint256;

    constructor() ERC721("PIAMON", "UTO8") {}

    function mintTo(address recipient, uint256 blindBoxId)
        public
        payable
        returns (uint256)
    {
        uint256 price = blindBoxes[blindBoxId].price;
        require(price <= msg.value, "Ether value sent is not correct");
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        string memory tokenURI = constructInitialTokenURI(
            blindBoxId,
            newItemId
        );
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function constructInitialTokenURI(uint256 blindBoxId, uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        // get random number from map
        //uint256 randomNumber = randomMap[tokenId];
        // build tokenURI from randomNumber
        //string memory randomTokenURI = string(abi.encodePacked(_baseTokenURI, randomNumber.toString(), ".png"));
        BlindBox storage blindBox = blindBoxes[blindBoxId];

        string memory imageUrl = blindBox.imageUrl;

        // metadata
        string memory name = string(
            abi.encodePacked(blindBox.name, " #", tokenId.toString())
        );
        string memory description = blindBox.description;

        // prettier-ignore
        return string(
            abi.encodePacked(
                'data:application/json;base64,',
                Base64.encode(
                    bytes(
                        abi.encodePacked('{"name":"', name, '", "description":"', description, '", "image": "', imageUrl, '"}')
                    )
                )
            )
        );
    }
}
