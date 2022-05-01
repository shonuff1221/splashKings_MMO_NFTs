//SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.13;

import {sharedDefinitions} from "./sharedstructs.sol";

library CombatLib {
    function CombatSkillCast(
        string memory _SkillToCast,
        uint256 playerLevel,
        sharedDefinitions.Hero storage HeroTarget
    ) external returns (bool) {
        //  require(msg.sender == contractAddressTohardcode )to disable external calls from outside the master contract.

        if (keccak256(bytes(_SkillToCast)) == keccak256(bytes("GettingBuff"))) {
            require(playerLevel >= 5);
            require(msg.sender == HeroTarget.player);
            GettingBuff(HeroTarget);
        } else if (
            keccak256(bytes(_SkillToCast)) == keccak256(bytes("VoodooCurse"))
        ) {
            require(playerLevel >= 10);
            require(HeroTarget.maxHP > 0);
            require(HeroTarget.player != msg.sender);
            VoodooCurse(HeroTarget);
        }

        return false;
    }

    function GettingBuff(sharedDefinitions.Hero storage HeroTarget) internal {
        // checks are in the CombatSkillCast Function before!

        HeroTarget.maxHP += 100;
    }

    function VoodooCurse(sharedDefinitions.Hero storage HeroTarget) internal {
        if (HeroTarget.maxHP >= 30) {
            HeroTarget.maxHP -= 30 - HeroTarget.defenseStat;
        } else {
            //should death for characters be possible?
        }
    }
}
