// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "base64-sol/base64.sol";
import "./UTO8.sol";
//import "./PiamonUtils.sol";
import "./SalesProvider.sol";

contract Piamon is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    using Strings for uint256;

    UTO8 uto8;
    SalesProvider salesProvider;
    //BlindBoxId => Total Mint Count
    mapping(uint256 => uint256) public blindBoxTotalMint;
    mapping(uint256 => uint256) public templateTotalMint;
    //keep NFT Id and BlindBox Id mapping , NFT_ID => BlindBox_ID => Serial_ID
    mapping(uint256 => uint256[]) public nftBlindBoxIdMap;

    enum ProductType {
        Piamon,
        BlindBox
    }

    constructor(address tokenAddress) ERC721("PIAMON", "UTO8") {
        uto8 = UTO8(tokenAddress);
    }

    function setSalesProvider(address contractAddress) public onlyOwner {
        salesProvider = SalesProvider(contractAddress);
    }

    function mintTo(
        address recipient,
        ProductType productType,
        uint256 productId
    ) public returns (uint256) {
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
        require(salesProvider.checkIsSaleOpen(blindBoxId), "Sale is closed");
        require(salesProvider.checkIsSaleEnd(blindBoxId), "Sale has ended");
        require(
            blindBoxTotalMint[blindBoxId] <
                salesProvider.getSaleTotalQuantity(blindBoxId),
            "No blindbox available"
        );

        bool isWhiteListMinter = false;
        uint256 mintPrice;

        if (!salesProvider.checkIsSaleStart(blindBoxId)) {
            require(
                salesProvider.checkIsWhiteListed(blindBoxId, recipient),
                "Public sale is not open yet"
            );

            (uint256 availableQty, uint256 whiteListPrice) = salesProvider
                .getWhiteList(blindBoxId, recipient);

            require(
                availableQty > 0,
                "Reach whitelist mint quantity limitation"
            );

            // require(
            //     whiteList.price <= msg.value,
            //     "Ether value sent is not correct"
            // );

            mintPrice = whiteListPrice;

            isWhiteListMinter = true;
        }

        if (!isWhiteListMinter) {
            mintPrice = salesProvider.getSalePrice(blindBoxId);
        }

        bool tokenSent = uto8.transferFrom(msg.sender, owner(), mintPrice);
        require(
            tokenSent,
            "Failed to transfer tokens from user to contract owner"
        );

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        string memory tokenURI = constructInitialTokenURI(
            blindBoxId,
            newItemId
        );
        _setTokenURI(newItemId, tokenURI);

        if (isWhiteListMinter) {
            salesProvider.decreaseWhiteListAvailableQuantity(
                blindBoxId,
                recipient
            );
        }

        blindBoxTotalMint[blindBoxId] = blindBoxTotalMint[blindBoxId] + 1;
        //salesProvider.addNFTAndBlindBoxMapping(newItemId, blindBoxId);
        nftBlindBoxIdMap[newItemId] = [
            blindBoxId,
            blindBoxTotalMint[blindBoxId]
        ];

        return newItemId;
    }

    function mintWithTemplate(address recipient, uint256 templateId)
        internal
        returns (uint256)
    {
        (
            string memory metadataURI,
            uint256 price,
            uint256 totalQuantity
        ) = salesProvider.getTemplate(templateId);

        require(
            totalQuantity > templateTotalMint[templateId],
            "Template sold out"
        );
        currentTokenId.increment();
        //uint256 price = salesProvider.piamonTemplates[templateId].price;
        require(price <= msg.value, "Ether value sent is not correct");
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        _setTokenURI(newItemId, metadataURI);

        templateTotalMint[templateId] = templateTotalMint[templateId] + 1;

        return newItemId;
    }

    function constructInitialTokenURI(uint256 blindBoxId, uint256 tokenId)
        internal
        view
        returns (string memory)
    {
        //BlindBox storage blindBox = salesProvider.blindBoxes[blindBoxId];

        (
            string memory blindBoxName,
            string memory imageUrl,
            string memory description,
            string memory piamonMetadataUrl,
            uint256 totalQuantity,
            uint256 vrfNumber
        ) = salesProvider.getBlindBoxInfo(blindBoxId);

        //string memory imageUrl = blindBox.imageUrl;

        // metadata
        string memory name = string(
            abi.encodePacked(blindBoxName, " #", tokenId.toString())
        );

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

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        //check if NFT was created base on blindbox or template
        if (nftBlindBoxIdMap[tokenId].length > 0) {
            uint256 blindBoxId = nftBlindBoxIdMap[tokenId][0];

            (
                string memory blindBoxName,
                string memory imageUrl,
                string memory description,
                string memory piamonMetadataUrl,
                uint256 totalQuantity,
                uint256 vrfNumber
            ) = salesProvider.getBlindBoxInfo(blindBoxId);

            //if vrfNumber == 0 means the blindbox has not been unboxed
            if (vrfNumber > 0) {
                uint256 tempUnboxedNFTID = nftBlindBoxIdMap[tokenId][1] +
                    vrfNumber;
                uint256 unboxedNFTID = 0;
                if (tempUnboxedNFTID > totalQuantity) {
                    unboxedNFTID = tempUnboxedNFTID - totalQuantity;
                } else {
                    unboxedNFTID = tempUnboxedNFTID;
                }

                if (bytes(piamonMetadataUrl).length > 0) {
                    return
                        string(
                            abi.encodePacked(
                                piamonMetadataUrl,
                                Strings.toString(unboxedNFTID),
                                ".json"
                            )
                        );
                } else {
                    return super.tokenURI(tokenId);
                }
            } else {
                return super.tokenURI(tokenId);
            }
        } else {
            return super.tokenURI(tokenId);
        }
    }
}
