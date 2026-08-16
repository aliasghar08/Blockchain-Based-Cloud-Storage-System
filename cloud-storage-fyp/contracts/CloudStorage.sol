// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract CloudStorage {
    
    struct File {
        string cid;        // The IPFS Content Identifier (Hash)
        string fileName;
        uint256 fileSize;  // Size in bytes
        string fileType;   // MIME type (e.g., 'application/pdf')
        address owner;
        uint256 uploadTime;
    }

    // Mapping from user address to their uploaded files
    mapping(address => File[]) private userFiles;
    
    // Mapping from user address to files shared WITH them
    mapping(address => File[]) private sharedWithMe;

    // Mapping to track which user has access to which file (cid => user => bool)
    mapping(string => mapping(address => bool)) private sharedAccess;

    event FileUploaded(string cid, string fileName, uint256 fileSize, string fileType, address owner);
    event FileShared(string cid, address sharedWith, address owner);

    function uploadFile(
        string memory _cid, 
        string memory _fileName, 
        uint256 _fileSize, 
        string memory _fileType
    ) public {
        require(bytes(_cid).length > 0, "CID cannot be empty");
        require(bytes(_fileName).length > 0, "File name cannot be empty");

        File memory newFile = File({
            cid: _cid,
            fileName: _fileName,
            fileSize: _fileSize,
            fileType: _fileType,
            owner: msg.sender,
            uploadTime: block.timestamp
        });

        userFiles[msg.sender].push(newFile);
        sharedAccess[_cid][msg.sender] = true;

        emit FileUploaded(_cid, _fileName, _fileSize, _fileType, msg.sender);
    }

    function shareFile(string memory _cid, address _user) public {
        require(sharedAccess[_cid][msg.sender] == true, "You do not have permission");
        require(msg.sender != _user, "Cannot share with yourself");
        require(sharedAccess[_cid][_user] == false, "User already has access");

        sharedAccess[_cid][_user] = true;
        
        // Find the file and add it to the sharedWithMe mapping of the target user
        File[] memory senderFiles = userFiles[msg.sender];
        for (uint i = 0; i < senderFiles.length; i++) {
            if (keccak256(abi.encodePacked(senderFiles[i].cid)) == keccak256(abi.encodePacked(_cid))) {
                sharedWithMe[_user].push(senderFiles[i]);
                break;
            }
        }

        emit FileShared(_cid, _user, msg.sender);
    }

    function hasAccess(string memory _cid, address _user) public view returns (bool) {
        return sharedAccess[_cid][_user];
    }

    function getMyFiles() public view returns (File[] memory) {
        return userFiles[msg.sender];
    }

    function getSharedWithMe() public view returns (File[] memory) {
        return sharedWithMe[msg.sender];
    }
}