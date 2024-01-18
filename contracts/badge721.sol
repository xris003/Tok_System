// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Badge is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _badgeId;

    address public merchant;

    modifier onlyOwner() {
        require(
            msg.sender == merchant,
            "You're not authorized to perform this function"
        );
        _;
    }

    struct ListedBadge {
        uint256 badgeId;
        address payable owner;
        address payable merchant;
        uint256 price;
    }

    // To map a badgeID to its data.
    mapping(uint256 => ListedBadge) public idToListedBadge;

    // Map to check if a URI already exists
    mapping(string => bool) public tokenURIExists;

    constructor() ERC721("BadgeItem", "BADGE") {
        //merchant = msg.sender; // Set the merchant in the constructor
    }

    function createBadge(
        string memory uri,
        uint256 price
    ) public returns (uint256) {
        require(price > 0, "cannot set a negative amount");

        require(
            tokenURIExists[uri] == false,
            "Badge with this MetaData already exists."
        );

        _badgeId.increment();
        uint256 badgeId = _badgeId.current();
        address minter = msg.sender;

        _mint(minter, badgeId);

        tokenURI(badgeId);

        tokenURIExists[uri] = true;

        // Update the mapping of tokenId's to Token details, useful for retrieval functions
        idToListedBadge[badgeId] = ListedBadge(
            badgeId,
            payable(minter),
            payable(msg.sender),
            price
        );

        return badgeId;
    }

    function contractBuy(
        address _merchant,
        address buyer,
        uint256 badgeId
    ) public {
        _transfer(_merchant, buyer, badgeId);
        approve(address(this), badgeId);
    }

    function badgeBal() public view onlyOwner returns (uint256) {
        return balanceOf(merchant);
    }

    function buyBadge(uint256 badgeId) public payable {
        uint price = idToListedBadge[badgeId].price;
        address _merchant = idToListedBadge[badgeId].merchant;
        address buyer = msg.sender;

        require(msg.sender != _merchant, "Owner cannot buy his own NFT");

        require(
            msg.value == price,
            "Please submit the correct price to complete the purchase"
        );

        contractBuy(_merchant, buyer, badgeId);

        idToListedBadge[badgeId].merchant = payable(buyer);

        payable(_merchant).transfer(msg.value);
    }
}
