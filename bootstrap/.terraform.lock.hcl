# This file is maintained automatically by "tofu init".
# Manual edits may be lost in future updates.

provider "registry.opentofu.org/fluxcd/flux" {
  version     = "1.5.1"
  constraints = ">= 1.5.0"
  hashes = [
    "h1:bRvBt2mZHViqpn/+50OfjNJHlf3mDd6GCeKY9PbSBoA=",
    "zh:0e123771d8d7ad8ffb67936ddb7e75bcca1014fb074256cf2134fec2e61b570b",
    "zh:205443f05174602a74f43d911b521524bc0c36e24181b5692e7a7e1135fe78b0",
    "zh:542984db329bdee7efade02f6178eab6203341d1606569aefeb73d8b115cf9ba",
    "zh:587767f0337710752568b28eccf620af617b30ddc06f3789fc391b44f4823b04",
    "zh:6ee2f4a426aa3486af699ded7cae8ba3b822bf5c9761738f6a3a3f8bec4d10bb",
    "zh:74c65e55ffff36cca242fc8422c0497e3b0f2a7f957a762ce9e1db61e39a05df",
    "zh:801817429ccc5208ce4af2ca95823564d94dbb68b05da8220c037343d079487f",
    "zh:ab43649549f3d7e93bed628245363dc583a087fecd6e08c3e2a8a300b27f33ae",
    "zh:ade188fccfb8023b139cec2f7f9f0d06d9f4d7474b830904991ab1c061323ce3",
    "zh:b6de06b932396594af8d944262d2e822c85a2544393141fceb15bc790272e1c3",
    "zh:b7c74c01a10fbcac4c6af58862a18861df3f7433ee6689f895e72f839d82e1d0",
    "zh:ce74d56f62860f05762ec0917fc80d37008c3dc1bd4584a089824915e5a91f0e",
    "zh:ff9f2dc2448bb31e1b47d7a95cf62fe272d9518fb04a3c25b02bc6db5c307d12",
    "zh:ffbc086caf558291d8a1843c36baf68062450d6dbe911f66995b9cba6497d5e9",
  ]
}

provider "registry.opentofu.org/hashicorp/helm" {
  version     = "2.17.0"
  constraints = "2.17.0"
  hashes = [
    "h1:69PnHoYrrDrm7C8+8PiSvRGPI55taqL14SvQR/FGM+g=",
    "zh:02690815e35131a42cb9851f63a3369c216af30ad093d05b39001d43da04b56b",
    "zh:27a62f12b29926387f4d71aeeee9f7ffa0ccb81a1b6066ee895716ad050d1b7a",
    "zh:2d0a5babfa73604b3fefc9dab9c87f91c77fce756c2e32b294e9f1290aed26c0",
    "zh:3976400ceba6dda4636e1d297e3097e1831de5628afa534a166de98a70d1dcbe",
    "zh:54440ef14f342b41d75c1aded7487bfcc3f76322b75894235b47b7e89ac4bfa4",
    "zh:6512e2ab9f2fa31cbb90d9249647b5c5798f62eb1215ec44da2cdaa24e38ad25",
    "zh:795f327ca0b8c5368af0ed03d5d4f6da7260692b4b3ca0bd004ed542e683464d",
    "zh:ba659e1d94f224bc3f1fd34cbb9d2663e3a8e734108e5a58eb49eda84b140978",
    "zh:c5c8575c4458835c2acbc3d1ed5570589b14baa2525d8fbd04295c097caf41eb",
    "zh:e0877a5dac3de138e61eefa26b2f5a13305a17259779465899880f70e11314e0",
  ]
}

provider "registry.opentofu.org/integrations/github" {
  version     = "6.5.0"
  constraints = ">= 6.1.0"
  hashes = [
    "h1:ikIBPXI5lx7cV4aqLWYuL+LQnHmf+FybvdpcsfAqK4o=",
    "zh:3088bfd30c51ebfcb7c8d829465ec7b3c19af684cf1aff1ea1111ad3c6421c11",
    "zh:34f9054b0123f9fa7ab8ebc73591d2cf502f1cc75e7594bde42ce799fcac32b6",
    "zh:406dc2e63d43a24ac4f1b004e5c60ada3347207ea750bbd51e6199eb7f044f9f",
    "zh:43e7b6cb7e5062d9b7b7cf4d23f6ea99fb9605fb014fede62cda307051063c05",
    "zh:6a0923ebcc09cb98c488c11582375d2145ba965d1e6f2f69c077be8e1224020b",
    "zh:a2331f06b7ed57e83eadb784211067d675826f67cf0ed051c8ab20335d83de9a",
    "zh:a3f82213c98319f20438bdb92145ce1b0407cd8b8eec9745c036db10deb3d3a2",
    "zh:b4b8db8537d8e6fb3f05ed875726823e1dc6925c479db8749016e71568ebafc4",
    "zh:cdcf76f6f6f5c638db540490ab35bb1aacfc27204f1197004da5e950024afc06",
    "zh:de36cea60efe2b74cec958f88ec5c39d467ad9443c9c9e311424c3db229c4e78",
    "zh:dfb8949edc6722da66c78a19ccb1b81ac855439a28ca3badfdac5c10bbf2190d",
    "zh:e1a81734cc81f4f51dd11ca8a62b420f68e72d00835ed54f84d71bd56d19f37f",
    "zh:ec0d51640c3e3cf933c73d0ed79ba8b395d1b94fed8117a6438dba872aa5561f",
    "zh:ec59b7c420a2358e9750e9c6a8a5ef26ccbb8a2cae417e115e86d63520759ea5",
    "zh:fbd1fee2c9df3aa19cf8851ce134dea6e45ea01cb85695c1726670c285797e25",
  ]
}

provider "registry.opentofu.org/tehcyx/kind" {
  version     = "0.8.0"
  constraints = ">= 0.8.0"
  hashes = [
    "h1:XU9venmnQH9nyspWhmVpygiWR5kZtn5m0lf+62VuqtA=",
    "zh:68994ea296bc704069a140c198155b7a6d345837f9dabd5c39bb17d957ca1ef3",
    "zh:724cb92ca5e917039da9f43d115a3b8471b007f78f904b3884c5adfe0ca9bd79",
    "zh:7d149ba9087fac3b767b4ce78a779ec77dee3cac899d5d4c3da25ace5f332d2a",
    "zh:80c5d674e3edc7c73f3ec13eb8b56be9ed5d2a52e1daf8cbe7629832819fc85a",
    "zh:d565aaa3863cb2aef1da1df8886602e6a5f630053b9e7ee05947cabd7d002674",
    "zh:f83ee5ebbbc908a9a5e5877b7d43f81eeda8287dd8ae91573a7870956031f4d9",
  ]
}
