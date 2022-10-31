// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

// first deployed at: 0x3ae6EeBE64c4E3Bcdb6Ab8B3B0540575A39C098C
// second deployed at: 0xE527D24328CDDAf77914Bb5E55D788168fac598b

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Stats {
        uint256 hp;
        uint256 attack;
        uint256 defense;
    }

    mapping(uint256 => Stats) public tokenStats;

    constructor() ERC721("ChainBattles", "CB") {}

    /**
     * @dev Mints a new token.
     */
    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenStats[newItemId] = _generateBaseStats();
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    /**
     * @dev Train a character to increase its stats.
     * @param tokenId The id of the character to train.
     */
    function train(uint256 tokenId) public {
        require(_exists(tokenId), "Please use an existing token");
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this token to train it"
        );
        _increaseStats(tokenId);
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    /**
     * @dev Generates the SVG for the token
     */
    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        Stats memory stats = tokenStats[tokenId];
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "HP: ",
            stats.hp.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Attack: ",
            stats.attack.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Defense: ",
            stats.defense.toString(),
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

    /**
     * @dev Gets the URI for the token
     * @param tokenId The token ID to get the URI for
     */
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

    /**
     * @dev Generate a pseudo random series of numbers.
     */
    function _getPsuedoRandomNumber() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        _tokenIds.current()
                    )
                )
            );
    }

    /**
     * @dev Generate base stats for a new character.
     */
    function _generateBaseStats() private view returns (Stats memory) {
        uint256 someRandomNumbers = _getPsuedoRandomNumber();

        uint256 hp = someRandomNumbers % 1000;

        someRandomNumbers = _truncateNumber(someRandomNumbers, 3);

        uint256 attack = someRandomNumbers % 100;

        someRandomNumbers = _truncateNumber(someRandomNumbers, 2);

        uint256 defense = someRandomNumbers % 100;

        return Stats(hp, attack, defense);
    }

    /**
     * @dev Increase the stats of a character.
     * @param tokenId The id of the character to increase the stats of.
     */
    function _increaseStats(uint256 tokenId) private {
        uint256 someRandomNumbers = _getPsuedoRandomNumber();

        tokenStats[tokenId].hp = _increaseByPercent(
            tokenStats[tokenId].hp,
            _getLastDigitOf(someRandomNumbers)
        );

        someRandomNumbers = _truncateNumber(someRandomNumbers, 1);

        tokenStats[tokenId].attack = _increaseByPercent(
            tokenStats[tokenId].attack,
            _getLastDigitOf(someRandomNumbers)
        );

        someRandomNumbers = _truncateNumber(someRandomNumbers, 1);

        tokenStats[tokenId].defense = _increaseByPercent(
            tokenStats[tokenId].defense,
            _getLastDigitOf(someRandomNumbers)
        );
    }

    /**
     *@dev increase a number by a percent (a minimum increase of 1).
     *@param number the number to increase
     *@param percent the percent to increase by
     */
    function _increaseByPercent(uint256 number, uint256 percent)
        private
        pure
        returns (uint256)
    {
        uint256 increase = (number * percent) / 100;
        if (increase == 0) {
            increase = 1;
        }
        return increase + number;
    }

    /**
     * @dev Returns the last digit of a number
     * @param number The number to get the last digit of
     */
    function _getLastDigitOf(uint256 number) private pure returns (uint256) {
        return number % 10;
    }

    /**
     * @dev Reduces a number by a given amount of digits
     * @param number The number to reduce
     * @param digits The amount of digits to reduce by
     */
    function _truncateNumber(uint256 number, uint256 digits)
        private
        pure
        returns (uint256)
    {
        return (number / (10**digits));
    }
}
