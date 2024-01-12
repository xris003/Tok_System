// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// contract badge is ERC1155 {
//     using Counters for Counters.Counter;
//     Counters.Counter private _badgeId;

//     address public merchant;
//     address public user;
//     uint256 platinum;
//     uint256 diamond;
//     uint256 gold;

//     modifier onlyOwner() {
//         require(
//             msg.sender == merchant,
//             "You're not authorised to perform this function"
//         );
//         _;
//     }

//      constructor() ERC1155("BadgeItem") {}

//     function createbadge(string memory uri) public returns(uint256) {
//         _badgeId.increment();
//         merchant = msg.sender;
//         uint256 badgeId = _badgeId.current();

//         _mint(merchant, badgeId, 100, " ");

//         _setURI(uri);

//         return badgeId;
//     }

//     function badgeBal( uint badgeId) public view returns (uint256) {
//         merchant = msg.sender;
//         return balanceOf(badgeId, merchant);
//     }

// }

contract Badge is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _badgeId;

    address public merchant;

    modifier onlyOwner() {
        require(
            msg.sender == merchant,
            "You're not authorised to perform this function"
        );
        _;
    }

    struct ListedBadge {
        uint256 badgeId;
        address payable merchant;
        address payable buyer;
        uint256 price;
        bool currentlyListed;
    }

    // To map a badgeID to it's data.
    mapping(uint256 => ListedBadge) public idToListedBadge;

    // Map to check if a URI already exists
    mapping(string => bool) public tokenURIExists;

    constructor() ERC1155("BadgeItem") {
        merchant = msg.sender; // Set the merchant in the constructor
    }

    function createBadge(
        string memory uri,
        uint price
    ) public onlyOwner returns (uint256) {
        require(price > 0, "cannot set negative amount");

        require(
            tokenURIExists[uri] == false,
            "Badge with this MetaData already exists."
        );

        _badgeId.increment();
        uint256 badgeId = _badgeId.current();

        _mint(merchant, badgeId, 100, " "); // You might want to provide a more meaningful URI here

        _setURI(uri);

        //Update the mapping of tokenId's to Token details, useful for retrieval functions
        idToListedBadge[badgeId] = ListedBadge(
            badgeId,
            payable(address(this)),
            payable(msg.sender),
            price,
            true
        );

        return badgeId;
    }

    function badgeBal(uint256 badgeId) public view returns (uint256) {
        return balanceOf(merchant, badgeId);
    }

    function buyBadge(uint256 badgeId) public payable {
        uint price = idToListedBadge[badgeId].price;
        address _merchant = idToListedBadge[badgeId].merchant;
        address buyer = msg.sender;
    }
}
