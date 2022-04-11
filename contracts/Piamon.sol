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
    mapping(uint256 => uint256) public blindBoxTotalMint;
    mapping(uint256 => uint256) public templateTotalMint;

    constructor() ERC721("PIAMON", "UTO8") SalesBatch() {}

    function mintTo(
        address recipient,
        ProductType productType,
        uint256 productId
    ) public payable returns (uint256) {
        if (productType == ProductType.Piamon) {
            return mintWithTemplate(recipient, productId);
        } else if (productType == ProductType.BlindBox) {
            return mintWithBlindBox(recipient, productId);
        } else {
            revert("Wrong product type");
        }
    }

    function mintWithBlindBox(address recipient, uint256 blindBoxId)
        internal
        returns (uint256)
    {
        bool isWhiteListMinter = false;

        if (!blindBoxes[blindBoxId].isSaleOpen) {
            require(
                checkIsWhiteListed(blindBoxId, recipient),
                "Public sale is not open yet"
            );

            WhiteList memory whiteList = getWhiteList(blindBoxId, recipient);

            require(
                whiteList.availableQuantity > 0,
                "Reach whitelist mint quantity limitation"
            );

            require(
                whiteList.price <= msg.value,
                "Ether value sent is not correct"
            );

            isWhiteListMinter = true;
        }

        require(
            blindBoxTotalMint[blindBoxId] <
                blindBoxes[blindBoxId].totalQuantity,
            "No blindbox available"
        );

        if (!isWhiteListMinter) {
            uint256 price = blindBoxes[blindBoxId].price;
            require(price <= msg.value, "Ether value sent is not correct");
        }

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        string memory tokenURI = constructInitialTokenURI(
            blindBoxId,
            newItemId
        );
        _setTokenURI(newItemId, tokenURI);

        if (isWhiteListMinter) {
            decreaseWhiteListAvailableQuantity(blindBoxId, recipient);
        }

        blindBoxTotalMint[blindBoxId] = blindBoxTotalMint[blindBoxId] + 1;

        return newItemId;
    }

    function mintWithTemplate(address recipient, uint256 templateId)
        internal
        returns (uint256)
    {
        PiamonTemplate storage template = piamonTemplates[templateId];
        require(
            template.totalQuantity > templateTotalMint[templateId],
            "Template sold out"
        );
        currentTokenId.increment();
        uint256 price = piamonTemplates[templateId].price;
        require(price <= msg.value, "Ether value sent is not correct");
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, piamonTemplates[templateId].metadataURI);

        templateTotalMint[templateId] = templateTotalMint[templateId] + 1;

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
