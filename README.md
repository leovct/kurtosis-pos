# Polygon PoS Kurtosis Package

TODO

## Table of contents

TODO

## Quickstart

TODO

```bash
# create params.yml file
kurtosis run --enclave polygon-pos --args-file params.yml .
```

1. Get MATIC contract addresses.

```bash
kurtosis files inspect polygon-pos matic-contract-addresses contractAddresses.json | tail -n +2 | jq
```

<details>
<summary>Output example</summary>

```json
{
  "root": {
    "Registry": "0xc69c1e66f9EaD5836D96bD1128569eb2a0058579",
    "RootChain": "0x329cF899464ba580Bf047F4B886dB342c602f579",
    "GovernanceProxy": "0x7fC26B95dED0f51D4Efd4Bd7ee44260a941faaab",
    "RootChainProxy": "0xEd2Be21C3A66c11FefB10C6b07271C450Bd09Ae5",
    "DepositManager": "0x4F60Bb906ee2188a14915c6b9D45381e2e04BA4c",
    "DepositManagerProxy": "0x5d58414E85FC12d343Eb3445dD7417c483d939A9",
    "WithdrawManager": "0x5A0242103310c7992773430E790C142B7E94Ef3a",
    "WithdrawManagerProxy": "0x8eB57E8Ca6e1E3216b4293Cc37d621A43c17Ec40",
    "StakeManager": "0x31502454e4b07Ab6f35216fD734AAfd816a06110",
    "StakeManagerProxy": "0xB5322Da185AF39b53f8d3CBF40636eb3f1B527f2",
    "SlashingManager": "0x892bb1f48977B66A0620F5c10909b8cAfbb800be",
    "StakingInfo": "0xCf99c17529CC22C39551547E323ED9Dda6841734",
    "ExitNFT": "0xE70dAe11D895C2E508e7d1C0C91dD0F3e4e971C3",
    "StateSender": "0xF2749e312B43529cb35A91e355919A376Bd22ce3",
    "predicates": {
      "ERC20Predicate": "0x67382E0700054fa319fa040fC06313ECC65fdAE4",
      "ERC721Predicate": "0x3ABef506f9A595BF085F7Ca1b51150a8057ACcBA",
      "MarketplacePredicate": "0x69e31d96Db8C3067491ED68980c88669c7A25aAe",
      "TransferWithSigPredicate": "0x49Ee8a9900D1a673588F95f32721BE38EE696265"
    },
    "tokens": {
      "MaticToken": "0xA8CF7E31740f127cEdF36EEEDDA228565C0C781F",
      "MaticWeth": "0x090Ff2fCE9A4344CC8C011e40553AA8D1427D233",
      "TestToken": "0x0828Ad9C51E6c10038daeC6A63Fe110AB2E9F3f8",
      "RootERC721": "0xED3B4bf7e17E47DAC37D7bB913196E192DCaf748"
    }
  }
}
```

</details>
<br/>

2. Get the validators configuration.

```bash
kurtosis files inspect polygon-pos validators-config validators.js | tail -n +2
```

<details>
<summary>Output example</summary>

```js
exports = module.exports = [
  {
    "address": "0x97538585a02A3f1B1297EB9979cE1b34ff953f1E",
    "stake": 10000,
    "balance": 1000000000
  },
  {
    "address": "0xeeE6f79486542f85290920073947bc9672C6ACE5",
    "stake": 10000,
    "balance": 1000000000
  },
  {
    "address": "0xA831F4E702F374aBf14d8005e21DC6d17d84DfCc",
    "stake": 10000,
    "balance": 1000000000
  }
]
```

</details>
<br/>

3. Get the EL genesis.

```bash
kurtosis files inspect polygon-pos l2-el-genesis genesis.json | tail -n +2 | jq
```

4. Get the CL genesis.

```bash
kurtosis files inspect polygon-pos l2-cl-genesis genesis.json | tail -n +2 | jq
```

## Configuration

TODO
