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
    mapping(uint256 => uint256) public blindBoxTotalMint;
    mapping(uint256 => uint256) public templateTotalMint;

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
            string memory piamonMetadataUrl
        ) = salesProvider.getMetadataForBlindBox(blindBoxId);

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

    function UnboxBlindBox(uint256 _blindBoxId) public onlyOwner {
        (
            string memory blindBoxName,
            string memory imageUrl,
            string memory description,
            string memory piamonMetadataUrl
        ) = salesProvider.getMetadataForBlindBox(_blindBoxId);

        uint256 randomNumber = 69;
        //loop all minted NFT Ids in this BlindBox
        for (uint256 i = 1; i < blindBoxTotalMint[_blindBoxId]; i++) {
            uint256 piamonBoxId = i + randomNumber;
            if (piamonBoxId > 8000) {
                piamonBoxId -= 8000;
            }
            string memory metadataURI = string(
                abi.encodePacked(
                    piamonMetadataUrl,
                    Strings.toString(piamonBoxId),
                    ".json"
                )
            );
            _setTokenURI(i, metadataURI);
        }
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

        uint256 blindBoxId = salesProvider.nftBlindBoxIdMap[tokenId];

        (
            string name,
            string imageUrl,
            string randomBoxUrl,
            string description,
            string piamonMetadataUrl,
            uint256 price,
            uint256 saleTimeStart,
            uint256 saleTimeEnd,
            bool isSaleOpen,
            uint256 totalQuantity,
            uint256 unboxTime,
            uint256 vrfNumber
        ) = salesProvider.blindBoxes[blindBoxId];

        //string memory _tokenURI = _tokenURIs[tokenId];
        //string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        //if (bytes(base).length == 0) {
        //    return _tokenURI;
        //}
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        //if (bytes(_tokenURI).length > 0) {
        //    return string(abi.encodePacked(base, _tokenURI));
        //}

        string memory _baseURI = piamonMetadataUrl;
        uint256 unboxNFTID = tokenId + vrfNumber;

        if (bytes(piamonMetadataUrl).length > 0) {
            return
                string(
                    abi.encodePacked(
                        piamonMetadataUrl,
                        Strings.toString(unboxNFTID),
                        ".json"
                    )
                );
        }

        return super.tokenURI(tokenId);
    }
}
