constants = import_module("../../package_io/constants.star")


def new_prefunded_account(address, full_public_key, private_key):
    return struct(
        address=address, full_public_key=full_public_key, private_key=private_key
    )


def to_ethereum_pkg_pre_funded_accounts(pre_funded_accounts):
    balance = constants.VALIDATORS_BALANCE_ETH
    return {
        account.address: {"balance": "{}ETH".format(balance)}
        for account in pre_funded_accounts
    }


# The keys were generated using this command:
# polycli wallet inspect --mnemonic "sibling lend brave explain wait orbit mom alcohol disorder message grace sun" --addresses 20 | jq '.Addresses[] | {Path: .Path, Address: .ETHAddress, FullPublicKey: ("0x" + .HexFullPublicKey), PrivateKey: .HexPrivateKey}'.
PRE_FUNDED_ACCOUNTS = [
    # m/44'/60'/0'/0/0
    new_prefunded_account(
        "0x97538585a02A3f1B1297EB9979cE1b34ff953f1E",
        "0x93e8717f46b146ebfb99159eb13a5d044c191998656c8b79007b16051bb1ff762d09884e43783d898dd47f6220af040206cabbd45c9a26bb278a522c3d538a1f",
        "2a4ae8c4c250917781d38d95dafbb0abe87ae2c9aea02ed7c7524685358e49c2",
    ),
    # m/44'/60'/0'/0/1
    new_prefunded_account(
        "0xeeE6f79486542f85290920073947bc9672C6ACE5",
        "0x0f554daf002c359281a9c5c3cb6639cab12259f570d6d10cb15e3f82a79e75aa4924f01f530068b4a0113f77e69ba5434ca01100a182fbca2609e29c4a9de91f",
        "f92738db8be69a9694b08acfc8e8fa843578da5adfcf4de77482c5a2b15681ad",
    ),
    # m/44'/60'/0'/0/2
    new_prefunded_account(
        "0xA831F4E702F374aBf14d8005e21DC6d17d84DfCc",
        "0xcc0eeb4abe520999ee310aa0a9a485527edd584c1fd9e9981144ff2c574e5bf87b5549902afd05ab2b5c50bd8b1f2c6f648da71723fdf5721afe39c6fe491a45",
        "8f723ed84785cbb3202643d986c4ec6052ec9c55af8cbb84046eab7104ad0e75",
    ),
    # m/44'/60'/0'/0/3
    new_prefunded_account(
        "0xd3cc855bDb41498920792b77aBCB7431617fA9a4",
        "0x79e9c953100c624ffc7f32f61fb378f28141bebc00d51376fd96d5c1b31517cb13182f489b0e4578430d9d8e72de1be51c0c624f7aea86e650bf86d3d5da063a",
        "0b8a62723fa93e4da7b3f09845d0c2c23d2807bd9f6b15ffb9037768e45ceca1",
    ),
    # m/44'/60'/0'/0/4
    new_prefunded_account(
        "0xF2dBc05C1f99b6E3442Dbd5524d1fAB7959Fc939",
        "0x22997e0dc45b54926a12b5e668347979df3abc8c1d2bc2cec388e40c569b35be3cb907d15e5eb616afcf3279e8d0901373e81e1b25149e497036c7646542f492",
        "d160c2a27d6724c946082baeee53fd12d3053d95ddcea692db7ab24eaeee668c",
    ),
    # m/44'/60'/0'/0/5
    new_prefunded_account(
        "0x9bDc763175f3506dEdb5F139854730E23cA82F69",
        "0x72aff4b816c1ab1a2b58f2b22ae6f2547197f06419dd82b1aa7ebf9bc4cd6c679b8f616fa6669dc236c212b2c5894dec62516239fd33788dc24f8cdaed9bf0fa",
        "bca5312c2a0d4cd192d6ed46dadeeb04df40de4e08b1c1757b07fff42b4b951b",
    ),
    # m/44'/60'/0'/0/6
    new_prefunded_account(
        "0x307f0aA1456F0B3EDec56D6bA7ebC817D09483cC",
        "0x5499522100dd63e08eadb19aa547ec775b21d8de43e127973a65404224343dd8086c266e651ea9553c2b9db633b74754198c9b233adf7faa1c7f42613d0d18cd",
        "c76fcf0d1a590a60e619a92929848d836975eb9270daf91baeb06449211d62cb",
    ),
    # m/44'/60'/0'/0/7
    new_prefunded_account(
        "0x2c64Cab78F2A9AAb96514c5151Afa571301D45d9",
        "0x98050375761d6e2dd76d7dee10fa6eb7c6c2ff50870983eddb939b7d21ed000001e419bd73619c77ce049b9511fb3df85e4965d7365cc783f5f48f41071d09c2",
        "ab2e777a68e3976dfd099114ca296ea21c14562ae662cc2f093917a842b1d2d3",
    ),
    # m/44'/60'/0'/0/8
    new_prefunded_account(
        "0xB14908C693fb97dd65bFf82161c2Bdf442B0C952",
        "0x48cc364c82d72238fd94b3a02deaefb05ac8be2da1f8e28d79f7a04a48a656de84abd0f4a03dcb18802f8b8887c649dad0493956a4e947b29f79da29830f038c",
        "92a496c090beb90eac20b8436717f8943e05aff216dbfd3ddcab5463cf2a937f",
    ),
    # m/44'/60'/0'/0/9
    new_prefunded_account(
        "0x3d3e0AdB250437A85013EdD735Af309D29FC6b09",
        "0xa9cd729e66235cc5b32379d24eef7db703b1e552854c02f3abd2bf6633279bc81d5619163d252b8ed718a3080f5b093370fb6135ae6ddde9f7b9a8a0a548328b",
        "0dd4644d7ac1c3a4b210132e694ef6e5121e79bdc75e5eb2383f85af3f9b8c22",
    ),
    # m/44'/60'/0'/0/10
    new_prefunded_account(
        "0x3857C1b962cd62f2c45196b319493cEd7bB2b580",
        "0xa9182f349f6696c9409244a0c68b366ff0242550dfcf42c0ed2fbb6f4d7576addb6d744910ec6fbd59f529933b0c93a54e04de4f20eb1e2db32d3be96442b839",
        "c4189cdedadb8a4e191f190de6f056eed3cf9aa7c003d146558a9e9979e7dd99",
    ),
    # m/44'/60'/0'/0/11
    new_prefunded_account(
        "0x37B6d1C512ffD61242c69863da2CADDBA89f06a1",
        "0x75911c34f7f0d4032e7b90a8fb8f8dec6e5639c3c58ac0e50634fe5350a3a7b1906620b6e12a513d71b0d665a462521602d56a8ac3320777c896223ff85aced1",
        "fe991dc58ae456b7e44eabddd475dace31dbbcc709c0dd26c73f1bf9efe9e6ef",
    ),
    # m/44'/60'/0'/0/12
    new_prefunded_account(
        "0x230fbC3D831bADa13df3F91ac6143FaFf595367A",
        "0x1c5cd9439d8ad6f72bc4a4e0623f1521c5a2634f2afd51454f44b045581910aab8c3eed7fdfa9764c2ece1527b83ac580f9e83201d81ffdabe9c5ad37c5b4b34",
        "4560a7941500b694f880f73de5e85886f90a4a59264aeec5dc74e6468fb6e7c3",
    ),
    # m/44'/60'/0'/0/13
    new_prefunded_account(
        "0x22b15948E0925214E959Fca360ffdfA74780dF93",
        "0x52ee83dc0ba83f0c12cd8061a7174666f7b1718ac011adc1b2e742f6ec3d2e0a99a33c170b0202c29381611ef2254186808667385384aa927760167043e6f486",
        "2cdae5202d2fcee6ff93ad695e5046ebd89d95d75cddee7f89e1306b0c841eba",
    ),
    # m/44'/60'/0'/0/14
    new_prefunded_account(
        "0xf3DB09Faf87062b10e4e65000897d0e06e7BECd4",
        "0x8115ba7ae42a0b4427ef598ab3b7adca32549783b6b4317ceaf53fb51dc0b543200c8935ddf85816252857b3cef2ccab2768d92ecf3a2c162769096fd8d06aff",
        "5d3af80cb644f2e3323cc9ae274acc471c63977ebd1bbb9c0f52a8607b8cdf5a",
    ),
    # m/44'/60'/0'/0/15
    new_prefunded_account(
        "0x67f6074cd99d55a3587dCF745bC72AA64585C927",
        "0xd828760cc874e8c2ed91af9ffc5d06892b8441fbc4538978cd0764c5137e25455913ef5a39947ac7dfe7bc7134738017842a178d6fe1c50d593253f77c49d4e0",
        "95eb7846413fb242606bd4ecc05f327ed0548bde68077f746c201a3f94caf025",
    ),
    # m/44'/60'/0'/0/16
    new_prefunded_account(
        "0xe06dcDdcf4eC8932FeeD78A6f0170Ca1F783927C",
        "0x9e393f7aba401b52f923864c741586d8a2e0baab346a53f1f8a730a5b06cdab38a942608cdb685f9b489aa175299f9e72e093045f80bffba500e9d75623ab546",
        "e179a53c5d09f522b0fa627c8f4aa62d5f9191cb187cf498d151d4f1ebd3bca2",
    ),
    # m/44'/60'/0'/0/17
    new_prefunded_account(
        "0x0dC6e87ac93c46fB6724220e9DF084Ffbd02c2a9",
        "0xbbf5fd6e7591d868178354b5bf2caf1254ebf6efd6b89255d27a6cec0f4e5b10689fec08200077903c2d44ce1cc8f8525a962b4c1880a352ab1147d0fa865839",
        "24115bec2c77044f7a3fdf5fd690bb102a7f4ee091b1ec3570818c763a749905",
    ),
    # m/44'/60'/0'/0/18
    new_prefunded_account(
        "0x56aBACAB4Bc41B6f8FA15b49B244C59FCc152D09",
        "0x1db327a8bc8bea06a84ed55786ab894c154f4856739bf65d26db013e40ddf9f8ed96c0a8d14ca8d3e63341303b07504c331fb1900480edbda98d47558413c27a",
        "5a3ac29a7ffaedc8dcc2a00c09c43271d116572d18fd66a6b05b4e0c65180ecb",
    ),
    # m/44'/60'/0'/0/19
    new_prefunded_account(
        "0xa4ce59D3d8687938cdcAc9Fd73b74e43a6405fB5",
        "0x02643ae6ac8e86e956288476a9aa6e085578229856e5c041270e255163656907c50ed45c59568c20abd2c1a4f28cba8a98699612d52fd554267100cc84cd0441",
        "b86c932e205594b7bda97488ee43a2d1c7acc99837640644976c8690a4b5ddb2",
    ),
]
