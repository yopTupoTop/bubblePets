pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IBubblePet is IERC721Upgradeable {
     struct Bubble {
        uint128 breedCount;
        uint128 feedCooldown;
        uint256 mood;
     }
}