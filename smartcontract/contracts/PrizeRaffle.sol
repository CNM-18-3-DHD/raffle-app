// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PrizeRaffle is ERC721 {
    address public owner;
    uint256 private randNonce = 0;

    uint256 public endTime;
    
    // Determine how hard to draw a prize
    uint public emptyPoolSize;
    uint nextPrizeId = 0;

    struct Prize {
        uint id;
        string image;
        string description;
    }

    mapping (uint256 => Prize) public prizes;
    Prize[] public prizeDetails;
    Prize[] public availablePrizes;    // Prizes left
    
    struct DrawDetail {
        uint256 id;
        address drawer;
        uint prizeIndex;
        bool isWon;
    }

    event PrizeWonTranfer (
        address winner,
        uint prizeId
    );

    DrawDetail[] public drawDetail;
    uint256 nextDrawId = 0;

    constructor(
        string memory name,
        string memory symbol,
        uint256 _endTime,
        uint _emptyPoolSize
    ) ERC721(name, symbol) {
        owner = msg.sender;
        endTime = _endTime;
        emptyPoolSize = _emptyPoolSize;
    }

    function updateEmptyPool(uint _newEmptyPoolSize) external onlyOwner {
        emptyPoolSize = _newEmptyPoolSize;
    }

    function addPrize(string memory _image, string memory _description) external onlyOwner {
        uint id = nextPrizeId;
        _safeMint(owner, id);
        Prize memory newPrize = Prize(id, _image, _description);
        prizes[id] = newPrize;
        prizeDetails.push(newPrize);
        availablePrizes.push(newPrize);
        nextPrizeId++;
    }

    function draw() external canDraw returns (uint256, uint, bool) {
        address drawer = msg.sender;
        uint256 drawId = nextDrawId;
        uint prizeIndex = drawPossiblePrize();
        bool isWon = isPrizeAvailable(prizeIndex);
        drawDetail.push(DrawDetail(drawId, drawer, prizeIndex, isWon));
        nextDrawId++;
        if (isWon) {
            transferPrize(drawer, prizeIndex);
        }
        return (drawId, prizeIndex, isWon);
    }

    function transferPrize(address to, uint indexId) internal {
        Prize memory transfer = availablePrizes[indexId];
        safeTransferFrom(owner, to, transfer.id);
        emit PrizeWonTranfer(to, transfer.id);

        // Remove from available prize pool
        availablePrizes[indexId] = availablePrizes[availablePrizes.length - 1];
        availablePrizes.pop();
    }

    function isPrizeAvailable(uint index) internal view returns (bool) {
        return (index < availablePrizes.length);
    }

    function drawPossiblePrize() internal returns (uint) {
        return rand(0, availablePrizes.length + emptyPoolSize);
    }

    // Probably not safe
    function rand(uint min, uint max) internal returns (uint) {
        randNonce++;
        uint rawRandom = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
        return (rawRandom % (min + max) - min);
    }

    function withdrawPrize() external onlyOwner {
        require(block.timestamp > endTime, "Campain has not ended");
        for (int i = int(availablePrizes.length) - 1; i >= 0; i--) {
            transferPrize(owner, uint(i));
        }
    }

    // Views =====================================
    function getPrizesLength() external view returns (uint) {
        return prizeDetails.length;
    }

    function getPrize(uint index) external view returns (uint, string memory, string memory) {
        require(prizeDetails.length > 0 && index < prizeDetails.length, "Index out of bound");
        Prize memory prize = prizeDetails[index];
        return (prize.id, prize.image, prize.description);
    }

    function getAvailablePrizesLength() external view returns (uint) {
        return availablePrizes.length;
    }

    function getAvailablePrize(uint index) external view returns (uint, string memory, string memory) {
        require(availablePrizes.length > 0 && index < availablePrizes.length, "Index out of bound");
        Prize memory prize = availablePrizes[index];
        return (prize.id, prize.image, prize.description);
    }

    function getDrawLength() external view returns (uint) {
        return drawDetail.length;
    }

    function getDraw(uint index) external view returns (uint, address, uint, bool) {
        require(drawDetail.length > 0 && index < drawDetail.length, "Index out of bound");
        DrawDetail memory detail = drawDetail[index];
        return (detail.id, detail.drawer, detail.prizeIndex, detail.isWon);
    }

    // Modifiers =================================
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner is allowed to call this");
        _;
    }

    modifier canDraw() {
        require(block.timestamp <= endTime, "Campain ended");
        require(availablePrizes.length > 0, "There are no prizes left");
        _;
    }
}
