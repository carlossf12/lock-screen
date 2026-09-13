var DEFAULT_FIXED_PRESET = "misty-torii-shrine"
var PRESET_CATALOG = [
  {
    id: "misty-torii-shrine",
    label: "Misty Torii Shrine",
    assetPath: "assets/wallpapers/misty-torii-shrine.png"
  },
  {
    id: "moonlit-mountain",
    label: "Moonlit Mountain",
    assetPath: "assets/wallpapers/moonlit-mountain.png"
  },
  {
    id: "celestial-torii",
    label: "Celestial Torii",
    assetPath: "assets/wallpapers/celestial-torii.png"
  },
  {
    id: "synthwave-torii-sunset",
    label: "Synthwave Torii Sunset",
    assetPath: "assets/wallpapers/synthwave-torii-sunset.png"
  }
]

function defaultFixedPreset() {
  return DEFAULT_FIXED_PRESET
}

function presetCatalog() {
  var result = []
  for (var i = 0; i < PRESET_CATALOG.length; i += 1) {
    var preset = PRESET_CATALOG[i]
    result.push({ id: preset.id, label: preset.label, assetPath: preset.assetPath })
  }
  return result
}

function isValidFixedPreset(value) {
  var id = String(value || "").trim()
  for (var i = 0; i < PRESET_CATALOG.length; i += 1) {
    if (PRESET_CATALOG[i].id === id) return true
  }
  return false
}

function normalizeFixedPreset(value) {
  var id = String(value || "").trim()
  return isValidFixedPreset(id) ? id : DEFAULT_FIXED_PRESET
}

function presetAssetPath(value) {
  var id = normalizeFixedPreset(value)
  for (var i = 0; i < PRESET_CATALOG.length; i += 1) {
    if (PRESET_CATALOG[i].id === id) return PRESET_CATALOG[i].assetPath
  }
  return PRESET_CATALOG[0].assetPath
}

function presetLabel(value) {
  var id = normalizeFixedPreset(value)
  for (var i = 0; i < PRESET_CATALOG.length; i += 1) {
    if (PRESET_CATALOG[i].id === id) return PRESET_CATALOG[i].label
  }
  return PRESET_CATALOG[0].label
}

function defaultConfig() {
  return {
    backgroundMode: "fixed",
    backgroundPath: "",
    fixedPreset: DEFAULT_FIXED_PRESET
  }
}

function normalize(raw) {
  var text = String(raw || "").trim()
  if (!text) return defaultConfig()

  var parsed
  try {
    parsed = JSON.parse(text)
  } catch (e) {
    return defaultConfig()
  }

  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return defaultConfig()

  var mode = String(parsed.backgroundMode || "fixed").trim()
  if (["fixed", "current", "custom"].indexOf(mode) === -1) return defaultConfig()

  return {
    backgroundMode: mode,
    backgroundPath: mode === "custom" ? String(parsed.backgroundPath || "").trim() : "",
    fixedPreset: normalizeFixedPreset(parsed.fixedPreset)
  }
}

function validateDraft(draft) {
  if (!draft || typeof draft !== "object" || Array.isArray(draft)) {
    return { valid: false, error: "Choose a background mode.", config: null }
  }

  var mode = String(draft.backgroundMode || "").trim()
  if (["fixed", "current", "custom"].indexOf(mode) === -1) {
    return { valid: false, error: "Choose a valid background mode.", config: null }
  }

  var path = mode === "custom" ? String(draft.backgroundPath || "").trim() : ""
  if (mode === "custom" && !path) {
    return { valid: false, error: "A custom image path is required.", config: null }
  }
  if (mode === "custom" && path.charAt(0) !== "/") {
    return { valid: false, error: "Custom image must use an absolute path.", config: null }
  }

  var presetProvided = draft.fixedPreset !== undefined && draft.fixedPreset !== null
  var fixedPreset = presetProvided
    ? String(draft.fixedPreset || "").trim()
    : DEFAULT_FIXED_PRESET
  if (!isValidFixedPreset(fixedPreset)) {
    return { valid: false, error: "Choose a valid fixed wallpaper preset.", config: null }
  }

  return {
    valid: true,
    error: "",
    config: {
      backgroundMode: mode,
      backgroundPath: path,
      fixedPreset: fixedPreset
    }
  }
}

function serialize(config) {
  var result = validateDraft(config)
  if (!result.valid) throw new Error(result.error)
  return JSON.stringify(result.config, null, 2) + "\n"
}

function sameConfig(left, right) {
  var a = validateDraft(left)
  var b = validateDraft(right)
  if (!a.valid || !b.valid) return false
  return a.config.backgroundMode === b.config.backgroundMode
    && a.config.backgroundPath === b.config.backgroundPath
    && a.config.fixedPreset === b.config.fixedPreset
}

function primarySourceFor(config, currentPath) {
  var normalized = normalize(JSON.stringify(config || {}))

  if (normalized.backgroundMode === "fixed") return presetAssetPath(normalized.fixedPreset)
  if (normalized.backgroundMode === "current") return String(currentPath || "")
  return normalized.backgroundPath
}

if (typeof module !== "undefined") {
  module.exports = {
    defaultFixedPreset: defaultFixedPreset,
    presetCatalog: presetCatalog,
    isValidFixedPreset: isValidFixedPreset,
    normalizeFixedPreset: normalizeFixedPreset,
    presetAssetPath: presetAssetPath,
    presetLabel: presetLabel,
    defaultConfig: defaultConfig,
    normalize: normalize,
    validateDraft: validateDraft,
    serialize: serialize,
    sameConfig: sameConfig,
    primarySourceFor: primarySourceFor
  }
}
