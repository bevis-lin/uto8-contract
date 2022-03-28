// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "./PiamonUtils.sol";

contract PiamonTemplates {
    using Counters for Counters.Counter;
    Counters.Counter private _counter;
    uint256 public totalTempaltes;

    struct PiamonTemplate {
        uint256 id;
        string name;
        string imageUrl;
        string description;
    }

    //templateId => Template
    mapping(uint256 => PiamonTemplate) public piamonTemplates;

    //templateId => PiamonData
    mapping(uint256 => PiamonData) public piamonDatas;

    function create(
        string memory _name,
        string memory _imageUrl,
        string memory _description
    ) public {
        _counter.increment();
        uint256 newId = _counter.current();
        PiamonTemplate memory newTemplate;
        newTemplate.id = newId;
        newTemplate.name = _name;
        newTemplate.imageUrl = _imageUrl;
        newTemplate.description = _description;
        piamonTemplates[newId] = newTemplate;
        totalTempaltes++;
    }

    function getAllTemplates() public view returns (PiamonTemplate[] memory) {
        PiamonTemplate[] memory returnTemplates = new PiamonTemplate[](
            totalTempaltes
        );
        for (uint256 i = 0; i < totalTempaltes; i++) {
            returnTemplates[i] = piamonTemplates[i];
        }
        return returnTemplates;
    }

    function getTemplateById(uint256 templateId)
        public
        view
        returns (PiamonTemplate memory)
    {
        return piamonTemplates[templateId];
    }

    function getPiamonDataByTemplateId(uint256 templateId)
        public
        view
        returns (PiamonData memory)
    {
        return piamonDatas[templateId];
    }
}
