// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UserRequestToCompany {
    address public accuworkCompanyWalletAddress;
    address public userWalletAddress;

    // Event to log each transaction made in addWorkExperienceAndVerifyAndPay
    event TransactionRecord(
        address indexed user,
        WorkExperience workExperience,
        bool isVerified,
        uint256 amount
    );

    struct WorkExperience {
        string employeeName;
        string companyName;
        string position;
        string location;
        uint256 startDate;
        uint256 endDate;
    }

    mapping(address => WorkExperience) public workExperience;

    // When we deploy the smart contract, set accuworkCompanyWalletAddress as our metamask wallet address
    constructor() {
        accuworkCompanyWalletAddress = msg.sender;
    }

    modifier onlyAccuworkAdmin() {
        require(msg.sender == accuworkCompanyWalletAddress, "Not authorized");
        _;
    }

    // check user wallet has enough eth to request
    modifier userHasEnoughEth(uint256 amount) {
        require(msg.value >= amount, "Insufficient funds");
        _;
    }

    // Helper function to compare two strings
    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function verifyUserInfo(
        string memory employeeName,
        string memory companyName,
        string memory position,
        string memory location,
        uint256 startDate,
        uint256 endDate
    ) internal pure returns (bool) {
        // Check if the provided information matches the mock data
        bool isValid = compareStrings(employeeName, "John Doe") &&
            compareStrings(companyName, "Google") &&
            compareStrings(position, "Full Stack Developer") &&
            compareStrings(location, "Toronto") &&
            startDate == 123456789 &&
            endDate == 987654321;

        return isValid;
    }

    function addWorkExperienceAndVerifyAndPay(
        string memory employeeName,
        string memory companyName,
        string memory position,
        string memory location,
        uint256 startDate,
        uint256 endDate
    ) external payable onlyAccuworkAdmin returns (bool) {
        // Calculate total amount that user paid
        uint256 totalAmount = msg.value;

        // if the user doesn't have enough money, return false
        if (totalAmount < 0.0002 ether) {
            return false;
        }

        uint256 ethAmountForAccuwork = totalAmount;

        // send money from user wallet to accuwork wallet
        payable(accuworkCompanyWalletAddress).transfer(ethAmountForAccuwork);

        // msg.sender is the address of user wallet
        // add user info to blockchain
        workExperience[msg.sender] = WorkExperience({
            employeeName: employeeName,
            companyName: companyName,
            position: position,
            location: location,
            startDate: startDate,
            endDate: endDate
        });

        bool isVerified = verifyUserInfo(
            employeeName,
            companyName,
            position,
            location,
            startDate,
            endDate
        );

        // Emit a transaction event
        emit TransactionRecord(
            msg.sender,
            workExperience[msg.sender],
            isVerified,
            totalAmount
        );

        return isVerified;
    }
}
