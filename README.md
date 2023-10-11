Dynamic Recon Ops
=================
This repository is a private fork of [mbrdmn][mbrdmn]'s [Dynamic Recon Ops][dro]
scenario for Arma 3.  It contains the unpacked Altis PBO from Steam Workshop,
plus ~~all~~ most published versions for other maps, plus a simple toolkit to
repack the scenario for arbitrary maps.

**NOTE**: This repository is not the upstream project and may lag behind the
published version!

Packing the scenario
--------------------
Run `build.sh`.  You need [armake2][armake2].

Notes
-----
+ Some smaller terrains don't work (probably because the objective placement logic
  doesn't have the space).  This includes at least CUP Shapur.

[mbrdmn]: https://steamcommunity.com/profiles/76561197967479574
[dro]: https://steamcommunity.com/sharedfiles/filedetails/?id=722652837
[armake2]: https://github.com/KoffeinFlummi/armake2
