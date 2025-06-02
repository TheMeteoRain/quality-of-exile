#Requires AutoHotkey v2.0

#Include "..\functions\CalculateWeaponDPS.ahk"

item1 := "
    (
    Item Class: Two Hand Axes
    Rarity: Rare
    Dusk Butcher
    Karui Chopper
    --------
    Two Handed Axe
    Physical Damage: 121-189
    Elemental Damage: 36-66 (augmented), 17-283 (augmented)
    Critical Strike Chance: 5.00%
    Attacks per Second: 1.35 (augmented)
    Weapon Range: 1.3 metres
    --------
    Requirements:
    Level: 58
    Str: 151
    Dex: 43
    --------
    Sockets: R-G 
    --------
    Item Level: 84
    --------
    { Corruption Implicit Modifier — Attack, Speed }
    6(5-7)% increased Attack Speed (implicit)
    --------
    { Prefix Modifier ""Frigid"" (Tier: 7) — Damage, Elemental, Cold, Attack }
    Adds 36(29-40) to 66(58-68) Cold Damage
    { Prefix Modifier ""Shocking"" (Tier: 4) — Damage, Elemental, Lightning, Attack }
    Adds 17(14-20) to 283(281-327) Lightning Damage
    { Suffix Modifier ""of Rejuvenation"" (Tier: 4) — Life, Attack }
    Grants 2 Life per Enemy Hit
    { Suffix Modifier ""of Fame"" (Tier: 3) — Attack, Speed }
    22(20-22)% increased Attack Speed
    --------
    Corrupted
    )"
item2 := "
    (
    Item Class: Two Hand Axes
    Rarity: Rare
    Miracle Sunder
    Sundering Axe
    --------
    Two Handed Axe
    Quality: +24% (augmented)
    Physical Damage: 171-354 (augmented)
    Critical Strike Chance: 5.00%
    Attacks per Second: 1.48 (augmented)
    Weapon Range: 1.3 metres
    --------
    Requirements:
    Level: 61
    Str: 149
    Dex: 76
    --------
    Sockets: B-G G 
    --------
    Item Level: 84
    --------
    +20% to Damage over Time Multiplier for Bleeding (implicit)
    --------
    +2 to Level of Socketed Melee Gems
    +43 to Strength
    +8 to Dexterity
    20% increased Physical Damage
    Adds 41 to 83 Physical Damage
    14% increased Attack Speed
    +23 to Accuracy Rating
    )"
item3 := "
    (
    Item Class: One Hand Swords
    Rarity: Rare
    Woe Beak
    Twilight Blade
    --------
    One Handed Sword
    Physical Damage: 68-195 (augmented)
    Critical Strike Chance: 5.00%
    Attacks per Second: 1.30
    Weapon Range: 1.1 metres
    --------
    Requirements:
    Level: 66
    Str: 91
    Dex: 91
    --------
    Sockets: G R 
    --------
    Item Level: 83
    --------
    { Implicit Modifier — Attack }
    40% increased Global Accuracy Rating (implicit)
    --------
    { Prefix Modifier "Journeyman's" (Tier: 7) — Damage, Physical, Attack }
    22(20-24)% increased Physical Damage
    +30(21-46) to Accuracy Rating
    { Prefix Modifier "The Elder's" (Tier: 3) — Damage, Physical, Attack, Gem }
    Socketed Gems are Supported by Level 16 Ruthless — Unscalable Value
    105(101-115)% increased Physical Damage
    { Suffix Modifier "of the Pugilist" (Tier: 5) }
    6(5-7)% reduced Enemy Stun Threshold
    (The Stun Threshold determines how much Damage can Stun something)
    { Suffix Modifier "of the Jaguar" (Tier: 3) — Attribute }
    +39(38-42) to Dexterity
    --------
    Elder Item
    )"

values1 := {
  current: {
    phys: 207.70,
    ele: 269.34,
    total: 477.04
  },
  quality: {
    phys: 249.24,
    ele: 269.34,
    total: 518.58
  },
  total: {
    phys: 570.76,
    ele: 269.34,
    total: 840.10
  }
}
values2 := {
  current: {
    phys: 388.14,
    ele: 0.00,
    total: 388.14
  },
  total: {
    phys: 860.18,
    ele: 0.00,
    total: 860.18
  }
}
values3 := {
  current: {
    phys: 171.16,
    ele: 0.00,
    total: 171.16
  },
  quality: {
    phys: 205.39,
    ele: 0.00,
    total: 205.39
  },
  total: {
    phys: 288.61,
    ele: 0.00,
    total: 288.61
  }
}
tests := [[item1, values1], [item2, values2], [item3, values3]]

AssertEqual(actual, expected, msg := "") {
  if (actual != expected) {
    MsgBox "Assertion failed! " msg "`nExpected: " expected "`nActual: " actual
    ExitApp
  }
}

TestWeaponDPS(item, values) {
  dps := CalculateWeaponDPS(item)
  weapon := dps.weapon
  optimalWeapon := dps.optimalWeapon
  nonCraftedWeapon := dps.nonCraftedWeapon
  parsed := ParseWeaponAffixes(item)

  AssertEqual(Round(weapon.phys.dps, 2), values.current.phys)
  AssertEqual(Round(weapon.ele.dps, 2), values.current.ele)
  AssertEqual(Round(weapon.totalDpsCurrentQuality, 2), values.current.total)

  if (values.HasOwnProp("quality")) {
    AssertEqual(Round(weapon.phys.maxQualityDps, 2), values.quality.phys)
    AssertEqual(Round(weapon.ele.dps, 2), values.quality.ele)
    AssertEqual(Round(weapon.totalDps, 2), values.quality.total)
  }

  AssertEqual(Round(optimalWeapon.physDps, 2), values.total.phys)
  AssertEqual(Round(optimalWeapon.eleDps, 2), values.total.ele)
  AssertEqual(Round(optimalWeapon.totalDps, 2), values.total.total)
}

for test in tests {
  item := test[1]
  values := test[2]

  TestWeaponDPS(item, values)
}

item := FileRead(".\item.txt")

MainGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
MainGui.BackColor := "black"
WinSetTransparent("255", MainGui)

if (!CalculateWeaponDPS(item, MainGui)) {
  return
}

MainGui.Show("NoActivate y0")