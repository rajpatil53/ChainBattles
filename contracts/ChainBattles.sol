// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// 0xa4f5B58C026A70Dd79505F386Aea15796eFd0C23
contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    mapping(uint256 => Stats) public tokenIdToLevels;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function randomNumber() public view returns (uint) {
        return uint(blockhash(block.number - 1)) % 101;
    }

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Level: ",
            getLevels(tokenId),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            getLife(tokenId),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            getSpeed(tokenId),
            "</text>",
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            getStrength(tokenId),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getLevels(uint256 tokenId) public view returns (string memory) {
        Stats memory stats = tokenIdToLevels[tokenId];
        return stats.level.toString();
    }

    function getLife(uint256 tokenId) public view returns (string memory) {
        Stats memory stats = tokenIdToLevels[tokenId];
        return stats.life.toString();
    }

    function getStrength(uint256 tokenId) public view returns (string memory) {
        Stats memory stats = tokenIdToLevels[tokenId];
        return stats.strength.toString();
    }

    function getSpeed(uint256 tokenId) public view returns (string memory) {
        Stats memory stats = tokenIdToLevels[tokenId];
        return stats.speed.toString();
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = Stats({
            level: 0,
            strength: randomNumber(),
            life: randomNumber(),
            speed: randomNumber()
        });
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );
        Stats memory currentStats = tokenIdToLevels[tokenId];
        Stats memory newStats;
        newStats.level = currentStats.level + 1;
        newStats.strength = currentStats.strength;
        newStats.speed = currentStats.speed;
        newStats.life = currentStats.life;
        tokenIdToLevels[tokenId] = Stats({
            level: currentStats.level + 1,
            strength: currentStats.strength,
            speed: currentStats.speed,
            life: currentStats.life
        });
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }
}
