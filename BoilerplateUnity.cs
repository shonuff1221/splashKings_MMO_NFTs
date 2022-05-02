//setting up the player address & the right blockchain network
string account = PlayerPrefs.GetString("Account");

string GameMasteraccount = PlayerPrefs.GetString("Account");

string chain = "avalanche";
string network = "mainnet";

string TokenContract    = "0xbc6f589171d6d66EB44ebCC92dFFb570Db4208da " // hardcode WaveToken Contract address here
string contract         = ""                                            // hardcode baseContract address here


//!!Create a new Hero!!

//first, check if the player actually has any balance to pay the gas fees & the required tokens
string balance = await EVM.BalanceOf(chain, network, account);
int basepriceHero = 99;
BigInteger tokenbalance = await ERC20.BalanceOf(chain, network, contract, account);
string methodToCall = "createNewHero"; 

//this abi needs to be slightly reformatted before being used. given that the smart contract is changing soon, this makes more sense down the line since its a major hassle.
string abi = "[	{		"anonymous": false,		"inputs": [			{				"indexed": true,				"internalType": "address",				"name": "owner",				"type": "address"			},			{				"indexed": true,				"internalType": "address",				"name": "spender",				"type": "address"			},			{				"indexed": false,				"internalType": "uint256",				"name": "value",				"type": "uint256"			}		],		"name": "Approval",		"type": "event"	},	{		"anonymous": false,		"inputs": [			{				"indexed": true,				"internalType": "address",				"name": "from",				"type": "address"			},			{				"indexed": true,				"internalType": "address",				"name": "to",				"type": "address"			},			{				"indexed": false,				"internalType": "uint256",				"name": "value",				"type": "uint256"			}		],		"name": "Transfer",		"type": "event"	},	{		"inputs": [			{				"internalType": "address",				"name": "owner",				"type": "address"			},			{				"internalType": "address",				"name": "spender",				"type": "address"			}		],		"name": "allowance",		"outputs": [			{				"internalType": "uint256",				"name": "",				"type": "uint256"			}		],		"stateMutability": "view",		"type": "function"	},	{		"inputs": [			{				"internalType": "address",				"name": "spender",				"type": "address"			},			{				"internalType": "uint256",				"name": "amount",				"type": "uint256"			}		],		"name": "approve",		"outputs": [			{				"internalType": "bool",				"name": "",				"type": "bool"			}		],		"stateMutability": "nonpayable",		"type": "function"	},	{		"inputs": [			{				"internalType": "address",				"name": "account",				"type": "address"			}		],		"name": "balanceOf",		"outputs": [			{				"internalType": "uint256",				"name": "",				"type": "uint256"			}		],		"stateMutability": "view",		"type": "function"	},	{		"inputs": [],		"name": "totalSupply",		"outputs": [			{				"internalType": "uint256",				"name": "",				"type": "uint256"			}		],		"stateMutability": "view",		"type": "function"	},	{		"inputs": [			{				"internalType": "address",				"name": "to",				"type": "address"			},			{				"internalType": "uint256",				"name": "amount",				"type": "uint256"			}		],		"name": "transfer",		"outputs": [			{				"internalType": "bool",				"name": "",				"type": "bool"			}		],		"stateMutability": "nonpayable",		"type": "function"	},	{		"inputs": [			{				"internalType": "address",				"name": "from",				"type": "address"			},			{				"internalType": "address",				"name": "to",				"type": "address"			},			{				"internalType": "uint256",				"name": "amount",				"type": "uint256"			}		],		"name": "transferFrom",		"outputs": [			{				"internalType": "bool",				"name": "",				"type": "bool"			}		],		"stateMutability": "nonpayable",		"type": "function"	}]"
int value = 0;

if(balance != "0" && tokenbalance > basepriceHero && methodToCall == "createNewHero")
{

    string args = "[0]"; //here would be the input of the class choice of the players new hero
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);

}
else{

    // display insufficient gas fee balance msg. here
    print('insufficient wallet balance to cover gas fees!');
}

//!!Create new weapon!!

int basepriceEquipment = 50;
methodToCall = "createNewWeapon";
if(balance != "0" && tokenbalance > basepriceEquipment && methodToCall == "createNewWeapon")
{

    
    string args = "[0]"; //here would be the input of the desired Equipment Type, numbercoded.  0 would be a sword.
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);

}


//!!Create new Armor

int basepriceEquipment = 50;
methodToCall = "createNewArmor";
if(balance != "0" && tokenbalance > basepriceEquipment && methodToCall == "createNewArmor")
{

    
    string args = "[0]"; //here would be the input of the desired Equipment Type, numbercoded.  0 would be a robe.
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}

//!!give Resource to Player!! This has to be run outside unity on a backend somewhere, otherwise you risk exposure of the private keys.


methodToCall = "giveResource";
uint _AmountToGive = 0;
string playerToAward = account;
uint _ResourceTypeToGive = 0;
if(balance != "0" && tokenbalance > basepriceEquipment && methodToCall == "giveResource")
{

    
    string args = $"[{_AmountToGive},{playerToAward},{_ResourceTypeToGive}]"; 
    string response =await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}


//!!use Resource of Player!! This has to be run outside unity on a backend somewhere, otherwise you risk exposure of the private keys.


methodToCall = "useResource";
uint _RequiredAmount = 0;
string playerToAward = account;
uint _ResourceTypeRequired = 0;
{

    
    string args = $"[{_RequiredAmount},{playerToAward},{_ResourceTypeRequired}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}



//!!give XP to Player!! This has to be run outside unity on a backend somewhere, otherwise you risk exposure of the private keys, which should never be hardcoded ANYWHERE.


methodToCall = "giveXP";

string playerToAward = account;

{

    
    string args = $"[{playerToAward}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}

//!!Player Skilling!!

methodToCall = "Skilling";
uint8 _SkillToRaise = 0;
uint8 _AmountOfSkillpointsToUse = 1;

{

    
    string args = $"[{_AmountOfSkillpointsToUse},{_SkillToRaise}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}


//!!Player Casts Skill!!

methodToCall = "PlayerCastsSkill";
string _SkillToCast = "VoodooCurse";
uint8 _TargetID = 42;
uint8 _category = 1 ; //combat. 0 is crafting, 2 is gathering(disabled atm)

{

    
    string args = $"[{_SkillToCast},{_TargetID},{_category}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}

//!!Player Equips Gear!!

methodToCall            = "equipGear";
uint256 _equipmentID    = 0;
uint256 _HeroID         = 0;
uint256 _EquipmentTypeToWear = 0; // 0 for Weapon, 1 for Armor
{

    
    string args = $"[{_equipmentID},{_HeroID},{_EquipmentTypeToWear}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}


//!!Player unequips Gear!!

methodToCall            = "unequipGear";
uint256 _equipmentID    = 0;
uint256 _HeroID         = 0;
uint256 _EquipmentTypeToUnequip = 0; // 0 for Weapon, 1 for Armor
{

    
    string args = $"[{_equipmentID},{_HeroID},{_EquipmentTypeToUnequip}]"; 
    string response = await WEB3GL.SendContract(methodToCall,abi,contract,args,value);
    print(response);
    
}







