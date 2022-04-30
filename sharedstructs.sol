//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

library sharedDefinitions {
    struct Hero {
        address player;
        uint256 characterID;
        Classes Class;
        int256 maxHP;
        int256 maxMana;
        int256 defenseStat;
        int256 attackDamage;
        uint256 Level;
        uint256 EXP;
        int256 skillPoints;
        Weapon EquipedWeapon;
        Armor EquipedArmor;
    }
    struct Weapon {
        WeaponTypes weapon;
        address player;
        uint256 EquipmentID;
        bool isUsed;
        int256 AttackStat;
        int256 DefenseStat;
        int256 HPStat;
        int256 ManaStat;
    }

    struct Armor {
        ArmorTypes weapon;
        address player;
        uint256 EquipmentID;
        bool isUsed;
        int256 AttackStat;
        int256 DefenseStat;
        int256 HPStat;
        int256 ManaStat;
    }

    enum WeaponTypes {
        Sword,
        Staff,
        Bow,
        Shield,
        Dagger
    }

    enum ArmorTypes {
        Robe,
        Platearmor
    }

    enum Classes {
        Rogue,
        Mage,
        Archer,
        Warrior
    }
}
