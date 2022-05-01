//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import {sharedDefinitions} from "./sharedstructs.sol";
import {GameEquipmentWeapons} from "./GameEquipmentWeapon.sol";
import {GameEquipmentArmors} from "./GameEquipmentArmor.sol";

library CraftingLib {
    function CraftingSkillCast(
        string memory _SkillToCast,
        uint256 _TargetID,
        GameEquipmentWeapons gameEquipmentWeaponContract,
        GameEquipmentArmors gameEquipmentArmorContract,
        uint256 playerLevel
    ) external returns (bool) {
        //  require(msg.sender == contractAddressTohardcode )to disable external calls from outside the master contract.
        if (keccak256(bytes(_SkillToCast)) == keccak256(bytes("CraftArmor"))) {
            require(playerLevel >= 5);
            craftArmorSkill(_TargetID, gameEquipmentArmorContract);
        } else if (
            keccak256(bytes(_SkillToCast)) == keccak256(bytes("CraftWeapon"))
        ) {
            require(playerLevel >= 10);
            craftWeaponSkill(_TargetID, gameEquipmentWeaponContract);
        }

        return false;
    }

    function craftArmorSkill(
        uint256 _TargetID,
        GameEquipmentArmors gameEquipmentArmorContract
    ) internal returns (bool) {
        gameEquipmentArmorContract.createnewArmor(
            sharedDefinitions.ArmorTypes(_TargetID),
            msg.sender
        );
        return true;
    }

    function craftWeaponSkill(
        uint256 _TargetID,
        GameEquipmentWeapons gameEquipmentWeaponContract
    ) internal returns (bool) {
        gameEquipmentWeaponContract.createnewWeapon(
            sharedDefinitions.WeaponTypes(_TargetID),
            msg.sender
        );
        return true;
    }
}
