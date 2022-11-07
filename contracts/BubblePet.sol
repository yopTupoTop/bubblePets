pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/MerkleProofUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "contracts/interfaces/IBubblePet.sol";

contract BubblePet is IBubblePet, ERC721Upgradeable, ERC721EnumerableUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    
    Bubble[] bubbles;
    uint256 basePrice;

    CountersUpgradeable.Counter private _counter;

    mapping(uint256 => address) internal bubbleToOwner;
    mapping(address => uint256) internal ownersBubbleCount;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            IERC165Upgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function getBubble(uint256 bubbleId) external view returns (uint128, uint128, uint256) {

        Bubble storage bubble = bubbles[bubbleId];

        uint128 breedCount = bubble.breedCount;
        uint128 feedCooldown = bubble.feedCooldown;
        uint256 mood = bubble.mood;

        return (breedCount, feedCooldown, mood);
    }

    function mint(address to) external payable {
        require(msg.value == basePrice, "NFT mint: not enougth ETH");

        _counter.increment();
        _mint(to, _counter.current());
        bubbleToOwner[_counter.current()] = to;
        ownersBubbleCount[to]++;
    }

    function transfer(address to, uint256 bubbleId) external {
        require(to != address(0));
        require(to != address(this));
        require(msg.sender == bubbleToOwner[bubbleId]);

        bubbleToOwner[bubbleId] = to;
        ownersBubbleCount[msg.sender]--;
        ownersBubbleCount[to]++;
        _transfer(msg.sender, to, bubbleId);
    } 

    function approveTransfer(address to, uint256 bubbleId) external {
        require(msg.sender == bubbleToOwner[bubbleId]);
        _approve(to, bubbleId);
    } 

    function transferNftFrom(address from, address to, uint256 bubbleId) external {
        require(to != address(0));
        require(to != address(this));
        require(from == bubbleToOwner[bubbleId]);
        transferFrom(from, to, bubbleId);
    }

}