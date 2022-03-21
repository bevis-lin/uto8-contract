// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";
import "./PiamonTemplates.sol";

contract Piamon is ERC721, PiamonTemplates {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;

    struct PiamonInfo {
        uint256 templateId;
        PiamonData data;
        bool isMetadatLocked;
    }

    //nftId => PiamonInfo
    mapping(uint256 => PiamonInfo) public mintedPiamons;

    constructor() ERC721("PIAMON", "NFT") {}

    function mintTo(address recipient, uint256 templateId)
        public
        returns (uint256)
    {
        Template memory template = getTemplateById(templateId);
        require(template.id > 0, "Template not exists");

        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);

        PiamonData memory data = getPiamonDataByTemplateId(templateId);
        PiamonInfo memory info;
        info.templateId = templateId;
        info.data = data;
        info.isMetadatLocked = true;
        mintedPiamons[newItemId] = info;

        return newItemId;
    }
}
