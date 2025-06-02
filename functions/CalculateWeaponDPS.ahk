CalculateTotalDPS(weapon, quality := 20) {
  return Round(CalculatePhysicalDPS(weapon, quality) + CalculateElementalDPS(weapon), 2)
}
CalculatePhysicalDPS(weapon, quality) {
  return CalculateDPS(
    weapon.phys.default[1] + weapon.phys.flat[1] + weapon.phys.default[2] + weapon.phys.flat[2],
    weapon.aps.default, weapon.aps.ias, weapon.phys.ipd, quality
  )
}
CalculateElementalDPS(weapon) {
  return CalculateDPS(
    weapon.ele.fire[1] + weapon.ele.fire[2] +
    weapon.ele.cold[1] + weapon.ele.cold[2] +
    weapon.ele.light[1] + weapon.ele.light[2],
    weapon.aps.default, weapon.aps.ias
  )
}
CalculateDPS(base, aps := 1, ias := 0, ipd := 0, quality := 0) {
  return base / 2 * (1 + ipd / 100) * (1 + quality / 100) * Round(aps * (1 + ias / 100), 2)
}

ParseWeaponAffixes(item) {
  affixes := []
  affixTypes := {
    prefix: 0,
    suffix: 0,
    crafted: 0,
    craftedAffixType: "",
    implicit: 0,
    enchant: 0,
    rune: 0,
    affixCount: 0,
    craftedAffixKey: ""
  }
  lines := StrSplit(item, "`n")
  i := 1
  while (i <= lines.Length) {
    line := Trim(lines[i])
    ; Prefix/Suffix/Implicit
    if RegExMatch(line, "^\{.+(Implicit|Prefix|Suffix) Modifier.*\}$|\(enchant\)|\(rune\)", &modMatch) {
      type := ""
      modLines := []
      j := i
      if (modMatch[1]) {
        ; Handle Implicit/Prefix/Suffix Modifier
        type := StrLower(modMatch[1])
        affixTypes.%type%++
        ; ...existing code for affix...
      } else {
        ; Handle enchant or rune
        type := InStr(line, "(enchant)") ? "enchant" : "rune"
        modLines := [Trim(line, "`r`t`n")] ; Use the header line as the only mod line
        ; ...existing code for enchant/rune...
      }
      j++
      affixTypes.affixCount++
      statLine := Trim(lines[i + 1], "`n`t`r ")
      crafted := InStr(statLine, "(crafted)") ? true : false
      pure := true

      ; Collect all lines under this modifier

      while (j <= lines.Length) {
        modLine := Trim(lines[j], "`r`t`n")
        if (
          modLine == "" || RegExMatch(modLine, "^\(") ||
          RegExMatch(modLine, "^\{.+Modifier.*\}$") || InStr(modLine, "--------")
        ) {
          break
        }
        modLines.Push(modLine)
        j++
      }
      hybrid := modLines.Length == 2
      if (hybrid) {
        pure := !(InStr(modLines[1], affixLabels.ipd) and InStr(modLines[2], "to Accuracy Rating"))
      } else if (crafted) {
        pure := false
      }

      for _, statLine in modLines {
        actualNumbers := []

        if RegExMatch(statLine, "Adds\s+([-+]?\d*\.?\d+)(?:\([^)]+\))?\s+to\s+([-+]?\d*\.?\d+)(?:\([^)]+\))?", &m) {
          actualNumbers.Push(RegExReplace(m[1], "^\+", ""))
          actualNumbers.Push(RegExReplace(m[2], "^\+", ""))
        } else if RegExMatch(statLine, "([-+]?\d*\.?\d+)(?:\([^)]+\))?", &m) {
          actualNumbers.Push(RegExReplace(m[1], "^\+", ""))
        }

        stat := statLine
        stat := RegExReplace(stat, "(-?\d+\.?\d*\([^)]+\))", "") ; remove numbers with parenthesis
        stat := RegExReplace(stat, "(-?\d+\.?\d*)", "") ; remove remaining numbers
        stat := RegExReplace(stat, "\(crafted\)", "")
        stat := RegExReplace(stat, "\(enchant\)", "")
        stat := RegExReplace(stat, "\(rune\)", "")
        stat := RegExReplace(stat, "\(implicit\)", "")
        stat := Trim(stat)
        if (crafted) {
          affixTypes.crafted++
          affixTypes.craftedAffixKey := stat
          affixTypes.craftedAffixType := type
        }

        affixes.Push({
          type: type,
          crafted: crafted,
          numbers: actualNumbers,
          stat: stat,
          raw: statLine,
          hybrid: hybrid,
          pure: pure,
        })
      }
      i := j
      continue
    }
    i++
  }

  affixTotals := Map()
  for _, affix in affixes {
    key := affix.stat
    if (!affixTotals.Has(key)) {
      affixTotals[key] := {
        crafted: affix.crafted,
        pure: affix.pure,
        hybrid: affix.hybrid,
        total: [],
        affixes: []
      }
      loop affix.numbers.Length {
        affixTotals[key].total.Push(0)
      }
    } else {
      ; update mod types if next affix has them
      if (!affixTotals[key].crafted) {
        affixTotals[key].crafted := affix.crafted
      }
      if (!affixTotals[key].pure) {
        affixTotals[key].pure := affix.pure
      }
      if (!affixTotals[key].hybrid) {
        affixTotals[key].hybrid := affix.hybrid
      }
    }
    for idx, n in affix.numbers {
      affixTotals[key].total[idx] += n
    }

    affixTotals[key].affixes.Push({
      type: affix.type,
      values: affix.numbers,
      raw: affix.raw,
      crafted: affix.crafted,
      hybird: affix.hybrid,
      pure: affix.pure
    })
  }

  return {
    affixes: affixes,
    affixTypes: affixTypes,
    affixTotals: affixTotals
  }
}

CalculateNewAffixValues(affixTotals, statNeedle, includeCrafted := true) {
  totals := [0, 0]

  if (!affixTotals.Has(statNeedle)) {
    return totals
  }

  for _, affix in affixTotals.Get(statNeedle).affixes {
    if (!includeCrafted && affix.crafted) {
      continue
    }

    for idx, n in affix.values {
      totals[idx] += n
    }
  }

  return totals
}

affixLabels := {
  ias: "% increased Attack Speed",
  ipd: "% increased Physical Damage",
  flat: "Adds  to  Physical Damage",
  fire: "Adds  to  Fire Damage",
  cold: "Adds  to  Cold Damage",
  light: "Adds  to  Lightning Damage",
}
weaponKeys := {
  phys: "phys",
  ele: "ele",
  aps: "aps",
  fire: "fire",
  cold: "cold",
  light: "light",
  flat: "flat",
  ias: "ias",
  ipd: "ipd",
}
affixMetaData := Map()
.Set(affixLabels.ias, {
  name: affixLabels.ias,
  raw: "{2}({1}-{2})% increased Attack Speed",
  ranges: {
    one: [16, 20],
    two: [16, 20]
  },
  key: weaponKeys.aps "." weaponKeys.ias,
  type: "suffix"
})
.Set(affixLabels.ipd, {
  name: affixLabels.ipd,
  raw: "{2}({1}-{2})% increased Physical Damage",
  ranges: {
    one: [100, 129],
    two: [100, 129],
  },
  key: weaponKeys.phys "." weaponKeys.ipd,
  type: "prefix"
})
.Set(affixLabels.flat, {
  name: affixLabels.flat,
  raw: "Adds {2}({1}-{2}) to {4}({3}-{4}) Physical Damage",
  ranges: {
    one: [[13, 17], [26, 30]],
    two: [[18, 24], [36, 42]]
  },
  key: weaponKeys.phys "." weaponKeys.flat,
  type: "prefix"
})
.Set(affixLabels.fire, {
  name: affixLabels.fire,
  raw: "Adds {2}({1}-{2}) to {4}({3}-{4}) Fire Damage",
  ranges: {
    one: [[35, 41], [63, 73]],
    two: [[60, 72], [110, 128]]
  },
  key: weaponKeys.ele "." weaponKeys.fire,
  type: "prefix"
})
.Set(affixLabels.cold, {
  name: affixLabels.cold,
  raw: "Adds {2}({1}-{2}) to {4}({3}-{4}) Cold Damage",
  ranges: {
    one: [[35, 41], [63, 73]],
    two: [[60, 72], [110, 128]]
  },
  key: weaponKeys.ele "." weaponKeys.cold,
  type: "prefix"
})
.Set(affixLabels.light, {
  name: affixLabels.light,
  raw: "Adds {2}({1}-{2}) to {4}({3}-{4}) Lightning Damage",
  ranges: {
    one: [[6, 8], [100, 113]],
    two: [[10, 14], [162, 197]],
  },
  key: weaponKeys.ele "." weaponKeys.light,
  type: "prefix"
})

GetAffixRawString(affix, weaponKey) {
  meta := affixMetaData.Get(affix)
  needle := "{\d{1}}"
  count := 0
  pos := 1

  while pos := RegExMatch(meta.raw, needle, &m, pos) {
    count++
    pos += StrLen(m[0]) ; move past the current match
  }

  if (count <= 3) {
    return Format(meta.raw, meta.ranges.%weaponKey%[1], meta.ranges.%weaponKey%[2])
  } else {
    return Format(meta.raw, meta.ranges.%weaponKey%[1][1], meta.ranges.%weaponKey%[1][2], meta.ranges.%weaponKey%[2][1],
      meta.ranges.%weaponKey%[2][2])
  }
}

CalculateOptimalDPS(weapon, types, totals, affixLabels) {
  ; Assume weapon is already filled with base values
  physDps := weapon.phys.maxQualityDps
  eleDps := weapon.ele.dps
  totalDps := weapon.totalDps
  bestType := types.craftedAffixKey
  found := false

  blockedAffixes := Map()
  for key, meta in affixMetaData {
    if (totals.Has(key)) {
      stats := totals.Get(key)
      for affix in stats.affixes {
        if ((affix.type == "suffix" or affix.type == "prefix") and affix.pure) {
          blockedAffixes.Set(key, true)
        }
      }
    }
  }

  GetMaxRanges(meta, weaponKey) {
    keys := StrSplit(meta.key, ".")

    if (IsNumber(meta.ranges.%weaponKey%[1])) {
      testWeapon.%keys[1]%.%keys[2]% += meta.ranges.%weaponKey%[2]
      return
    }

    testWeapon.%keys[1]%.%keys[2]% := [meta.ranges.%weaponKey%[1][2], meta.ranges.%weaponKey%[2][2]]
  }

  weaponValueKey := "one"
  if (weapon.isTwoHanded) {
    weaponValueKey := "two"
  }

  for key, meta in affixMetaData {
    testWeapon := CopyWeapon(weapon)
    testDps := 0

    if (
      ; non-crafted mod already exist on that type
      (types.craftedAffixKey == key and blockedAffixes.Has(key)
      ) or
      ; mod is pure
      (totals.Has(key) and totals.Get(key).pure)
    ) {
      continue
    }

    if (types.crafted) {
      if (meta.type == types.craftedAffixType) {
        GetMaxRanges(meta, weaponValueKey)
        testDps := CalculateTotalDPS(testWeapon)
      }
    } else {
      if (types.prefix != 3 and meta.type == "prefix") {
        GetMaxRanges(meta, weaponValueKey)
        testDps := CalculateTotalDPS(testWeapon)
      } else if (types.suffix != 3 and meta.type == "suffix") {
        GetMaxRanges(meta, weaponValueKey)
        testDps := CalculateTotalDPS(testWeapon)
      }
    }

    if (testDps > totalDps) {
      totalDps := testDps
      bestType := GetAffixRawString(key, weaponValueKey)
      found := true
      physDps := CalculatePhysicalDPS(testWeapon, 20)
      eleDps := CalculateElementalDPS(testWeapon)
    }
  }

  return {
    physDps: physDps,
    eleDps: eleDps,
    totalDps: totalDps,
    bestCraftedType: bestType,
    found: found
  }
}

CopyWeapon(weapon) {
  return {
    name: weapon.name,
    itemClass: weapon.itemClass,
    rarity: weapon.rarity,
    corrupted: weapon.corrupted,
    isTwoHanded: weapon.isTwoHanded,
    quality: weapon.quality,
    totalDps: weapon.totalDps,
    totalDpsCurrentQuality: weapon.totalDpsCurrentQuality,
    aps: {
      default: weapon.aps.default,
      augmentedValue: weapon.aps.augmentedValue,
      augmented: weapon.aps.augmented,
      ias: weapon.aps.ias,
    },
    phys: {
      default: [weapon.phys.default[1], weapon.phys.default[2]],
      augmentedValue: [weapon.phys.augmentedValue[1], weapon.phys.augmentedValue[2]],
      flat: [weapon.phys.flat[1], weapon.phys.flat[2]],
      ipd: weapon.phys.ipd,
      augmented: weapon.phys.augmented,
      dps: weapon.phys.dps,
      maxQualityDps: weapon.phys.maxQualityDps,
    },
    ele: {
      fire: [weapon.ele.fire[1], weapon.ele.fire[2]],
      cold: [weapon.ele.cold[1], weapon.ele.cold[2]],
      light: [weapon.ele.light[1], weapon.ele.light[2]],
      dps: weapon.ele.dps,
    },
  }
}

CalculateWeaponDPS(item, GuiCtrl := unset) {
  ; check if the copy-pasted text is a weapon
  if (!RegExMatch(item, "Attacks per Second: ", &m)) {
    return false
  }

  try {
    weaponName := ""
    weaponClass := ""
    weaponRarity := ""
    isTwoHanded := false

    lines := StrSplit(item, "`n")
    for idx, line in lines {
      line := Trim(line)
      if (RegExMatch(line, "^Item Class: (.+)$", &m)) {
        weaponClass := m[1]
        if (RegExMatch(weaponClass, "(Two Hand|Warstaves|Bow)")) {
          isTwoHanded := true
        }
      } else if (RegExMatch(line, "^Rarity: (.+)$", &m)) {
        weaponRarity := m[1]
      } else if (weaponName == "" && idx > 2 && line != "" && !InStr(line, ":") && !InStr(line, "--------")) {
        ; First non-empty, non-header, non-divider line after rarity is usually the name
        weaponName := Trim(line, "`r`t`n")
      }
    }
    corrupted := InStr(item, "corrupted")

    weapon := {
      name: weaponName,
      corrupted: corrupted,
      itemClass: weaponClass,
      rarity: weaponRarity,
      isTwoHanded: isTwoHanded,
      quality: 0,
      totalDps: 0,
      totalDpsCurrentQuality: 0,
      ; attacks pers second
      aps: {
        default: 1,
        augmentedValue: 0,
        augmented: false,
        ias: 0,
      },
      phys: {
        default: [0, 0],
        augmentedValue: [0, 0],
        flat: [0, 0],
        ipd: 0,
        augmented: false,
        dps: 0,
        maxQualityDps: 0,
      },
      ele: {
        fire: [0, 0],
        cold: [0, 0],
        light: [0, 0],
        dps: 0,
      },
    }

    parsedAffixes := ParseWeaponAffixes(item)
    affixes := parsedAffixes.affixes
    types := parsedAffixes.affixTypes
    totals := parsedAffixes.affixTotals

    if (totals.Has(affixLabels.ias)) {
      weapon.aps.ias := totals.Get(affixLabels.ias).total[1]
    }
    if (totals.Has(affixLabels.ipd)) {
      weapon.phys.ipd := totals.Get(affixLabels.ipd).total[1]
    }
    if (totals.Has(affixLabels.flat)) {
      weapon.phys.flat := totals.Get(affixLabels.flat).total
    }
    if (totals.Has(affixLabels.fire)) {
      weapon.ele.fire := totals.Get(affixLabels.fire).total
    }
    if (totals.Has(affixLabels.cold)) {
      weapon.ele.cold := totals.Get(affixLabels.cold).total
    }
    if (totals.Has(affixLabels.light)) {
      weapon.ele.light := totals.Get(affixLabels.light).total
    }

    if (RegExMatch(item, "Quality: \+(\d+)%", &m)) {
      weapon.quality := m[1]
    }

    if (RegExMatch(item, "Attacks per Second: (\d+\.?\d*)( \(augmented\))?", &m)) {
      weapon.aps.augmented := m[2] != ""
      if (weapon.aps.augmented) {
        weapon.aps.augmentedValue := m[1]
      } else {
        weapon.aps.default := m[1]
      }
    }

    if (RegExMatch(item, "Physical Damage: (\d+\.?\d*)-(\d+\.?\d*)( \(augmented\))?", &physMatch)) {
      weapon.phys.augmented := physMatch[3] != ""
      if (weapon.phys.augmented) {
        weapon.phys.augmentedValue[1] := physMatch[1]
        weapon.phys.augmentedValue[2] := physMatch[2]
      } else {
        weapon.phys.default[1] := physMatch[1]
        weapon.phys.default[2] := physMatch[2]
      }
    }

    if (weapon.aps.augmented) {
      weapon.aps.default := Round(weapon.aps.augmentedValue / (1 + weapon.aps.ias / 100), 2)
    }

    if (weapon.phys.augmented) {
      weapon.phys.default[1] := Round(
        weapon.phys.augmentedValue[1] / (1 + weapon.phys.ipd / 100) /
        (1 + weapon.quality / 100) - weapon.phys.flat[1]
      )
      weapon.phys.default[2] := Round(
        weapon.phys.augmentedValue[2] / (1 + weapon.phys.ipd / 100) /
        (1 + weapon.quality / 100) - weapon.phys.flat[2]
      )
    }

    weapon.phys.dps := CalculatePhysicalDPS(weapon, weapon.quality)
    weapon.ele.dps := CalculateElementalDPS(weapon)
    weapon.phys.maxQualityDps := CalculatePhysicalDPS(weapon, 20)
    weapon.totalDps := weapon.phys.maxQualityDps + weapon.ele.dps
    weapon.totalDpsCurrentQuality := CalculateTotalDPS(weapon, weapon.quality)

    if (Round(weapon.totalDps) == 0) {
      return false
    }

    nonCraftedWeapon := CopyWeapon(weapon)
    if (types.craftedAffixKey == affixLabels.flat) {
      nonCraftedWeapon.phys.flat := CalculateNewAffixValues(totals, affixLabels.flat, false)
    } else if (types.craftedAffixKey == affixLabels.ipd) {
      nonCraftedWeapon.phys.ipd := CalculateNewAffixValues(totals, affixLabels.ipd, false)[1]
    } else if (types.craftedAffixKey == affixLabels.ias) {
      nonCraftedWeapon.aps.ias := CalculateNewAffixValues(totals, affixLabels.ias, false)[1]
    }
    nonCraftedWeapon.phys.dps := CalculatePhysicalDPS(nonCraftedWeapon, nonCraftedWeapon.quality)
    nonCraftedWeapon.phys.maxQualityDps := CalculatePhysicalDPS(nonCraftedWeapon, 20)
    nonCraftedWeapon.ele.dps := CalculateElementalDPS(nonCraftedWeapon)
    optimalWeapon := CalculateOptimalDPS(nonCraftedWeapon, types, totals, affixLabels)

    if (IsSet(GuiCtrl)) {
      GuiCtrl.Add("Text", "cffda82", weapon.name)
      GuiCtrl.Add("Text", "c398fff section center w150 X0 XS", Format("== Current DPS ({}%) ==", weapon.quality))
      GuiCtrl.Add("Text", "cwhite YS", "Physical DPS: " Round(weapon.phys.dps, 2))
      GuiCtrl.Add("Text", "ca78eff", "Elemental DPS: " Round(weapon.ele.dps, 2))
      GuiCtrl.Add("Text", "cff82e0 section", "Total DPS: " Round(weapon.totalDpsCurrentQuality, 2))
      if (weapon.quality < 20) {
        GuiCtrl.Add("Text", "c398fff center section w150 YP50 X0", "== Max Quality DPS (20%) ==")
        GuiCtrl.Add("Text", "cwhite YS ", "Physical DPS: " Round(weapon.phys.maxQualityDps, 2))
        GuiCtrl.Add("Text", "ca78eff", "Elemental DPS: " Round(weapon.ele.dps, 2))
        GuiCtrl.Add("Text", "cff82e0 section", "Total DPS: " Round(weapon.totalDps, 2))
      }
      if (optimalWeapon.found and !weapon.corrupted) {
        GuiCtrl.Add("Text", "c398fff center section XS w150 YP50 X0", Format("== Optimal Upgrade (20%) =="))
        GuiCtrl.Add("Text", "c398fff center w150", Format("Crafted: {}", optimalWeapon.bestCraftedType))
        GuiCtrl.Add("Text", "cwhite YS", "Physical DPS: " Round(optimalWeapon.physDps, 2))
        GuiCtrl.Add("Text", "ca78eff", "Elemental DPS: " Round(optimalWeapon.eleDps, 2))
        GuiCtrl.Add("Text", "cff82e0", "Total DPS: " Round(optimalWeapon.totalDps, 2))
      }
    }

    return {
      weapon: weapon,
      nonCraftedWeapon: nonCraftedWeapon,
      optimalWeapon: optimalWeapon,
    }
  } catch Error as e {
    if (IsSet(GuiCtrl)) {
      GuiCtrl.Add("Text", "cwhite", "Not supported.")
    }
    throw e
  }
}
