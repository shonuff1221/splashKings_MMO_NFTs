//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import {sharedDefinitions} from "./sharedstructs.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol";

contract GameEquipmentArmors is ERC721 {
    address public owner;
    address public GamecontractMaster;
    sharedDefinitions.Armor[] public Armors;

    constructor() ERC721("ShonuffsHeroesArmors", "Armors") {
        owner = msg.sender;
    }

    function setMasterContract(address _newMasterContract) external {
        require(owner ==msg.sender);
        GamecontractMaster = _newMasterContract;
    }

    function createnewArmor(
        sharedDefinitions.ArmorTypes armorTypeToForge,
        address OwnerToBe
    ) external {
        require(msg.sender == GamecontractMaster);
        uint256 id = Armors.length;

        Armors.push(
            sharedDefinitions.Armor(
                armorTypeToForge,
                OwnerToBe,
                id,
                false,
                0,
                0,
                0,
                0
            )
        );
        _safeMint(msg.sender, id);
    }

    function equipGear(uint256 _equipID)
        external
        returns (sharedDefinitions.Armor memory)
    {
        require(msg.sender == GamecontractMaster);
        require(
            tx.origin == Armors[_equipID].player && !(Armors[_equipID].isUsed)
        );
        Armors[_equipID].isUsed = true;
        return Armors[_equipID];
    }

    function unequipGear(uint256 _equipID) external returns (bool) {
        require(msg.sender == GamecontractMaster);
        require(
            tx.origin == Armors[_equipID].player && Armors[_equipID].isUsed
        );
        Armors[_equipID].isUsed = false;

        return true;
    }

    // displays NFT Stats to Openseas
    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        sharedDefinitions.Armor memory EQAttributes = Armors[_tokenId];

        string memory EQID = Strings.toString(EQAttributes.EquipmentID);
        string memory ATTACKSTAT = Strings.toString(
            uint256(EQAttributes.AttackStat)
        );
        string memory DEFENSESTAT = Strings.toString(
            uint256(EQAttributes.DefenseStat)
        );
        string memory HPSTAT = Strings.toString(uint256(EQAttributes.HPStat));
        string memory MANASTAT = Strings.toString(
            uint256(EQAttributes.ManaStat)
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "description": "An Armorset ",',
                        '"attributes": [ ',
                        '{"trait_type": "Equipment ID", "value":',
                        EQID,
                        "}, ",
                        '{"trait_type": "Attack Stat", "value":',
                        ATTACKSTAT,
                        "}, ",
                        '{"trait_type": "Defense Stat", "value":',
                        DEFENSESTAT,
                        "}, ",
                        '{"trait_type": "HP Stat", "value":',
                        HPSTAT,
                        "}, ",
                        '{"trait_type": "Mana Stat", "value":',
                        MANASTAT,
                        "}",
                        "]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
