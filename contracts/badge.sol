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
        address payable owner;
        address payable merchant;
        uint256 price;
        bool currentlyListed;
    }

    // To map a badgeID to it's data.
    mapping(uint256 => ListedBadge) public idToListedBadge;

    // Map to check if a URI already exists
    mapping(string => bool) public tokenURIExists;

    constructor() ERC1155("BadgeItem") {
        // merchant = msg.sender; // Set the merchant in the constructor
    }

    function createBadge(
        string memory uri,
        uint256 price
    ) public returns (uint256) {
        require(price > 0, "cannot set negative amount");

        require(
            tokenURIExists[uri] == false,
            "Badge with this MetaData already exists."
        );

        _badgeId.increment();
        uint256 badgeId = _badgeId.current();
        merchant = msg.sender;

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

    function contractBuy(
        address _merchant,
        address buyer,
        uint256 amount,
        uint256 badgeId
    ) public {
        safeTransferFrom(merchant, buyer, amount, badgeId, "");

        isApprovedForAll(_merchant, buyer);
        // isApprovedForAll(account, operator);
    }

    function badgeBal(uint256 badgeId) public view onlyOwner returns (uint256) {
        return balanceOf(merchant, badgeId);
    }

    function buyBadge(uint256 badgeId, uint amount) public payable {
        uint price = idToListedBadge[badgeId].price;
        address _merchant = idToListedBadge[badgeId].merchant;
        address buyer = msg.sender;

        require(
            msg.value == price,
            "Please submit price in order to complete the purchase"
        );

        idToListedBadge[badgeId].merchant = payable(msg.sender);

        contractBuy(_merchant, buyer, amount, badgeId);

        payable(_merchant).transfer(price);
    }
}
