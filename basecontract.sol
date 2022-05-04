//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {GameEquipmentWeapons} from "./GameEquipmentWeapon.sol";
import {GameEquipmentArmors} from "./GameEquipmentArmor.sol";
import {sharedDefinitions} from "./sharedstructs.sol";
import {CraftingLib} from "./CraftingLib.sol";
import {GatheringLib} from "./GatheringLib.sol";
import {CombatLib} from "./CombatLib.sol";

contract BaseContract is ERC721 {
    uint256 private PriceForNewHero = 10;
    uint256 private PriceForNewEquipment = 5;
    IERC20 WaveToken;
    address payable private owner;
    sharedDefinitions.Hero[] private Heroes; // ERC 721 Tokens

    // resource tracker

    mapping(address => uint256) private PlayerWoodCount;
    mapping(address => uint256) private PlayerStoneCount;
    mapping(address => uint256) private PlayerIronCount;

    //level tracker
    mapping(address => uint256) public PlayerLevel;
    mapping(address => uint256) private PlayerXP;

    mapping(address => sharedDefinitions.SkillBuild) public SkillTree;

    event newHeroJoinsTheQuest(address indexed sender, uint256 indexed tokenId);
    event levelUp(address indexed Player, uint256 indexed newLevel);
    GameEquipmentWeapons gameEquipmentWeaponContract;
    GameEquipmentArmors gameEquipmentArmorContract;

    constructor(
        address _gameEquipmentContractWeapons,
        address _gameEquipmentContractArmors,
        address _TokenAddress
    ) ERC721("ShonuffsHeroes", "HERO") {
        WaveToken = IERC20(_TokenAddress);
        owner = payable(msg.sender);
        gameEquipmentWeaponContract = GameEquipmentWeapons(
            _gameEquipmentContractWeapons
        );
        gameEquipmentArmorContract = GameEquipmentArmors(
            _gameEquipmentContractArmors
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdrawMoney() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    function GetAllowance() public view returns (uint256) {
        return WaveToken.allowance(msg.sender, address(this));
    }

    function equipGear(
        uint256 _equipmentID,
        uint256 _HeroID,
        uint256 _EquipmentTypeToWear
    ) external {
        uint256 weapon = 0;
        uint256 armor = 1;

        require(msg.sender == Heroes[_HeroID].player);
        // 0 -> Weapon

        if (_EquipmentTypeToWear == weapon) {
            Heroes[_HeroID].EquipedWeapon = gameEquipmentWeaponContract
                .equipGear(_equipmentID);
        } else if (_EquipmentTypeToWear == armor) {
            Heroes[_HeroID].EquipedArmor = gameEquipmentArmorContract.equipGear(
                _equipmentID
            );
        }
    }

    function unequipGear(
        uint256 _equipmentID,
        uint256 _HeroID,
        uint256 _EquipmentTypeToUnequip
    ) external {
        uint256 weapon = 0;
        uint256 armor = 1;

        require(msg.sender == Heroes[_HeroID].player);

        if (_EquipmentTypeToUnequip == weapon) {
            if (gameEquipmentWeaponContract.unequipGear(_equipmentID)) {
                // if unequiped, give default weapon back
                Heroes[_HeroID].EquipedWeapon = sharedDefinitions.Weapon(
                    sharedDefinitions.WeaponTypes.Sword,
                    address(0),
                    0,
                    false,
                    0,
                    0,
                    0,
                    0
                );
            }
        } else if (_EquipmentTypeToUnequip == armor) {
            if (gameEquipmentArmorContract.unequipGear(_equipmentID)) {
                // if unequiped, give default armor back
                Heroes[_HeroID].EquipedArmor = sharedDefinitions.Armor(
                    sharedDefinitions.ArmorTypes.Robe,
                    address(0),
                    0,
                    false,
                    0,
                    0,
                    0,
                    0
                );
            }
        }
    }

    function createNewHero(sharedDefinitions.Classes _class) external payable {
        require(
            PriceForNewHero >= GetAllowance(),
            "Not enough approved Tokens, please approve before transferring"
        );
        WaveToken.transfer(address(this), PriceForNewHero); // transfer of Tokens to this contract

        uint256 id = Heroes.length;
        sharedDefinitions.Armor memory baseArmor = sharedDefinitions.Armor(
            sharedDefinitions.ArmorTypes.Robe,
            address(0),
            0,
            false,
            0,
            0,
            0,
            0
        ); // non NFT Equip,
        sharedDefinitions.Weapon memory baseWeapon = sharedDefinitions.Weapon(
            sharedDefinitions.WeaponTypes.Sword,
            address(0),
            0,
            false,
            0,
            0,
            0,
            0
        ); // non NFT Equip
        Heroes.push(
            sharedDefinitions.Hero(
                msg.sender,
                id,
                _class,
                100,
                100,
                3,
                10,
                1,
                0,
                0,
                baseWeapon,
                baseArmor
            )
        );
        _safeMint(msg.sender, id);
        emit newHeroJoinsTheQuest(msg.sender, id);
    }

    //the way enums work is they are ordered from 0 to whatever. So the first item would be 0 as a parameter, the second would be 1, etc. For a sword, we would need the argument 0, for a staff 1 etc.

    function createNewWeapon(uint8 _WeaponTypeToForge) public payable {
        require(
           GetAllowance()  >= PriceForNewEquipment,
            "Not enough approved Tokens, please approve before transferring"
        );
        WaveToken.transfer(address(this), PriceForNewEquipment); // transfer of Tokens to this contract

        gameEquipmentWeaponContract.createnewWeapon(
            sharedDefinitions.WeaponTypes(_WeaponTypeToForge),
            msg.sender
        );
    }

    function createNewArmor(uint8 _ArmorTypeToForge) public payable {
        require(
             GetAllowance()  >= PriceForNewEquipment,
            "Not enough approved Tokens, please approve before transferring"
        );
        WaveToken.transfer(address(this), PriceForNewEquipment); // transfer of Tokens to this contract

        gameEquipmentArmorContract.createnewArmor(
            sharedDefinitions.ArmorTypes(_ArmorTypeToForge),
            msg.sender
        );
    }

    function SetNewPrices(
        uint256 _PriceForNewHero,
        uint256 _PriceForNewEquipment
    ) external onlyOwner {
        PriceForNewHero = _PriceForNewHero;
        PriceForNewEquipment = _PriceForNewEquipment;
    }

    function WithdrawTokens() external onlyOwner {
        // withdraw all  ERC Tokens to owner contract

        WaveToken.transfer(msg.sender, WaveToken.balanceOf(address(this)));
    }

    function ChangeOwner(address payable OwnerToBe) external onlyOwner {
        owner = OwnerToBe;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        sharedDefinitions.Hero memory charAttributes = Heroes[_tokenId];

        string memory NftID = Strings.toString(charAttributes.characterID);
        string memory maxHP = Strings.toString(uint256(charAttributes.maxHP));
        string memory maxMana = Strings.toString(
            uint256(charAttributes.maxMana)
        );
        string memory level = Strings.toString(charAttributes.Level);
        string memory attackDamage = Strings.toString(
            uint256(charAttributes.attackDamage)
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{ "description": "A hero ",',
                        '"attributes": [ ',
                        '{"trait_type": "NftID", "value":',
                        NftID,
                        "}, ",
                        '{"trait_type": "level", "value":',
                        level,
                        "}, ",
                        '{"trait_type": "HP", "value":',
                        maxHP,
                        "}, ",
                        '{"trait_type": "Mana", "value":',
                        maxMana,
                        "}, ",
                        '{"trait_type": "attackDamage", "value":',
                        attackDamage,
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

    function giveResource(
        uint256 _amount,
        address _PlayerToAward,
        uint8 _ResourceToGive
    ) external onlyOwner {
        uint256 Wood = 0;
        uint256 Stone = 1;
        uint256 Iron = 2;

        if (_ResourceToGive == Wood) {
            PlayerWoodCount[_PlayerToAward] += _amount;
        } else if (_ResourceToGive == Stone) {
            PlayerStoneCount[_PlayerToAward] += _amount;
        } else if (_ResourceToGive == Iron) {
            PlayerIronCount[_PlayerToAward] += _amount;
        }
    }

    function useResource(
        uint256 _requiredAmount,
        address _ActingPlayer,
        uint8 _ResourceToUse
    ) external onlyOwner returns (bool) {
        uint256 Wood = 0;
        uint256 Stone = 1;
        uint256 Iron = 2;

        if (_ResourceToUse == Wood) {
            require(PlayerWoodCount[_ActingPlayer] >= _requiredAmount);
            PlayerWoodCount[_ActingPlayer] -= _requiredAmount;
            return true;
        } else if (_ResourceToUse == Stone) {
            require(PlayerStoneCount[_ActingPlayer] >= _requiredAmount);
            PlayerStoneCount[_ActingPlayer] -= _requiredAmount;
            return true;
        } else if (_ResourceToUse == Iron) {
            require(PlayerIronCount[_ActingPlayer] >= _requiredAmount);
            PlayerIronCount[_ActingPlayer] -= _requiredAmount;
            return true;
        }

        return false;
    }

    function giveXPtoPlayer(uint256 _amount, address _PlayerToAward)
        external
        onlyOwner
    {
        PlayerXP[_PlayerToAward] += _amount;
        CheckIfLevelup(_PlayerToAward);
    }

    uint256 private BaseLevelupXPRequired = 100;

    function CheckIfLevelup(address _PlayerToAward) private onlyOwner {
        require(
            PlayerLevel[_PlayerToAward] * BaseLevelupXPRequired <
                PlayerXP[_PlayerToAward]
        ); // every levelup requires Currentlevel * BaseLevelupXPRequired

        PlayerXP[_PlayerToAward] -=
            PlayerLevel[_PlayerToAward] *
            BaseLevelupXPRequired;
        PlayerLevel[_PlayerToAward] += 1;
        SkillTree[msg.sender].availableSkillpoints += 1;
        emit levelUp(_PlayerToAward, PlayerLevel[_PlayerToAward]);
    }

    function Skilling(uint256 _amount, uint8 _SkillToRaise) external {
        require(SkillTree[msg.sender].availableSkillpoints >= _amount);

        if (_SkillToRaise == 0) {
            SkillTree[msg.sender].availableSkillpoints -= _amount;
            SkillTree[msg.sender].Crafting += _amount;
        } else if (_SkillToRaise == 1) {
            SkillTree[msg.sender].availableSkillpoints -= _amount;
            SkillTree[msg.sender].Combat += _amount;
        } else if (_SkillToRaise == 2) {
            SkillTree[msg.sender].availableSkillpoints -= _amount;
            SkillTree[msg.sender].Gathering += _amount;
        }
    }

    function PlayerCastsSkill(
        string memory _SkillToCast,
        uint256 _TargetID,
        uint8 _category
    ) external {
        //crafting
        if (_category == 0) {
            CraftingLib.CraftingSkillCast(
                _SkillToCast,
                _TargetID,
                gameEquipmentWeaponContract,
                gameEquipmentArmorContract,
                PlayerLevel[msg.sender]
            );
        }
        //combat
        else if (_category == 1) {
            CombatLib.CombatSkillCast(
                _SkillToCast,
                PlayerLevel[msg.sender],
                Heroes[_TargetID]
            );
        }
        //gathering skills disabled for now.
        /*  else if(_category == 2){

            

            GatheringLib.GatheringSkillCast();

        }
*/
    }
}
