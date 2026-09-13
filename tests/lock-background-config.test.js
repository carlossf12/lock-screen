const assert = require("node:assert/strict");
const test = require("node:test");

const Config = require("../LockBackgroundConfig.js");

const DEFAULT_PRESET = "misty-torii-shrine";
const PRESETS = [
  {
    id: "misty-torii-shrine",
    label: "Misty Torii Shrine",
    assetPath: "assets/wallpapers/misty-torii-shrine.png",
  },
  {
    id: "moonlit-mountain",
    label: "Moonlit Mountain",
    assetPath: "assets/wallpapers/moonlit-mountain.png",
  },
  {
    id: "celestial-torii",
    label: "Celestial Torii",
    assetPath: "assets/wallpapers/celestial-torii.png",
  },
  {
    id: "synthwave-torii-sunset",
    label: "Synthwave Torii Sunset",
    assetPath: "assets/wallpapers/synthwave-torii-sunset.png",
  },
];

test("exposes the bundled preset catalog and default", () => {
  assert.equal(Config.defaultFixedPreset(), DEFAULT_PRESET);
  assert.deepEqual(Config.presetCatalog(), PRESETS);
  assert.equal(Config.presetLabel("celestial-torii"), "Celestial Torii");
  assert.equal(Config.presetLabel("invalid"), "Misty Torii Shrine");
  assert.equal(Config.presetAssetPath("invalid"), "assets/wallpapers/misty-torii-shrine.png");
});

test("normalizes missing, empty, invalid, and unknown config to fixed mode", () => {
  for (const raw of ["", "   ", "{", "{\"backgroundMode\":\"nope\"}"]) {
    assert.deepEqual(Config.normalize(raw), {
      backgroundMode: "fixed",
      backgroundPath: "",
      fixedPreset: DEFAULT_PRESET,
    });
  }
});

test("normalizes legacy and empty fixed presets to the default", () => {
  for (const raw of [
    '{"backgroundMode":"fixed","backgroundPath":""}',
    '{"backgroundMode":"fixed","backgroundPath":"","fixedPreset":""}',
    '{"backgroundMode":"fixed","backgroundPath":"","fixedPreset":"   "}',
  ]) {
    assert.deepEqual(Config.normalize(raw), {
      backgroundMode: "fixed",
      backgroundPath: "",
      fixedPreset: DEFAULT_PRESET,
    });
  }
});

test("normalizes every valid fixed preset", () => {
  for (const preset of PRESETS) {
    assert.equal(Config.normalize(JSON.stringify({
      backgroundMode: "fixed",
      fixedPreset: preset.id,
    })).fixedPreset, preset.id);
  }
});

test("normalizes an invalid fixed preset to the default", () => {
  assert.equal(Config.normalize(JSON.stringify({
    backgroundMode: "fixed",
    fixedPreset: "unknown-preset",
  })).fixedPreset, DEFAULT_PRESET);
});

test("normalizes valid current and custom config", () => {
  assert.deepEqual(Config.normalize("{\"backgroundMode\":\"current\"}"), {
    backgroundMode: "current",
    backgroundPath: "",
    fixedPreset: DEFAULT_PRESET,
  });

  assert.deepEqual(Config.normalize("{\"backgroundMode\":\"custom\",\"backgroundPath\":\" /tmp/wall.jpg \"}"), {
    backgroundMode: "custom",
    backgroundPath: "/tmp/wall.jpg",
    fixedPreset: DEFAULT_PRESET,
  });
});

test("current and custom normalization preserve a valid fixed preset", () => {
  for (const mode of ["current", "custom"]) {
    const config = Config.normalize(JSON.stringify({
      backgroundMode: mode,
      backgroundPath: mode === "custom" ? "/tmp/wall.jpg" : "",
      fixedPreset: "celestial-torii",
    }));
    assert.equal(config.fixedPreset, "celestial-torii");
  }
});

test("resolves primary source for fixed, current, and custom modes", () => {
  assert.equal(Config.primarySourceFor({ backgroundMode: "fixed", fixedPreset: "moonlit-mountain" }, "/state/current.jpg"), "assets/wallpapers/moonlit-mountain.png");
  assert.equal(Config.primarySourceFor({ backgroundMode: "current" }, "/state/current.jpg"), "/state/current.jpg");
  assert.equal(Config.primarySourceFor({ backgroundMode: "custom", backgroundPath: "/custom/lock.jpg" }, "/state/current.jpg"), "/custom/lock.jpg");
  assert.equal(Config.primarySourceFor({ backgroundMode: "custom", backgroundPath: "" }, "/state/current.jpg"), "");
});

test("validates fixed and current drafts with an empty canonical path", () => {
  for (const mode of ["fixed", "current"]) {
    assert.deepEqual(Config.validateDraft({ backgroundMode: mode, backgroundPath: "/ignored.jpg" }), {
      valid: true,
      error: "",
      config: { backgroundMode: mode, backgroundPath: "", fixedPreset: DEFAULT_PRESET },
    });
  }
});

test("strict draft validation rejects an explicit invalid fixed preset", () => {
  for (const fixedPreset of ["", "unknown-preset"]) {
    const result = Config.validateDraft({
      backgroundMode: "fixed",
      backgroundPath: "",
      fixedPreset,
    });
    assert.equal(result.valid, false);
    assert.equal(result.config, null);
    assert.match(result.error, /preset/i);
  }
});

test("validates a custom draft with a trimmed absolute path", () => {
  assert.deepEqual(Config.validateDraft({
    backgroundMode: "custom",
    backgroundPath: " /tmp/lock-screen-test/lock.webp ",
  }), {
    valid: true,
    error: "",
    config: {
      backgroundMode: "custom",
      backgroundPath: "/tmp/lock-screen-test/lock.webp",
      fixedPreset: DEFAULT_PRESET,
    },
  });
});

test("draft validation preserves fixed preset in current and custom modes", () => {
  for (const mode of ["current", "custom"]) {
    const result = Config.validateDraft({
      backgroundMode: mode,
      backgroundPath: mode === "custom" ? "/tmp/wall.jpg" : "",
      fixedPreset: "synthwave-torii-sunset",
    });
    assert.equal(result.valid, true);
    assert.equal(result.config.fixedPreset, "synthwave-torii-sunset");
  }
});

test("rejects an empty or relative custom path", () => {
  for (const path of ["", "   ", "Pictures/lock.jpg"]) {
    const result = Config.validateDraft({ backgroundMode: "custom", backgroundPath: path });
    assert.equal(result.valid, false);
    assert.equal(result.config, null);
    assert.match(result.error, /absolute path|required/i);
  }
});

test("rejects an invalid draft mode", () => {
  const result = Config.validateDraft({ backgroundMode: "unknown", backgroundPath: "" });
  assert.equal(result.valid, false);
  assert.equal(result.config, null);
  assert.match(result.error, /mode/i);
});

test("normalizes invalid JSON to fixed mode", () => {
  assert.deepEqual(Config.normalize("{"), {
    backgroundMode: "fixed",
    backgroundPath: "",
    fixedPreset: DEFAULT_PRESET,
  });
});

test("serializes fixed, current, and custom configs canonically", () => {
  assert.equal(Config.serialize({ backgroundMode: "fixed", backgroundPath: "/ignored" }),
    '{\n  "backgroundMode": "fixed",\n  "backgroundPath": "",\n  "fixedPreset": "misty-torii-shrine"\n}\n');
  assert.equal(Config.serialize({ backgroundMode: "current", backgroundPath: "/ignored", fixedPreset: "moonlit-mountain" }),
    '{\n  "backgroundMode": "current",\n  "backgroundPath": "",\n  "fixedPreset": "moonlit-mountain"\n}\n');
  assert.equal(Config.serialize({ backgroundMode: "custom", backgroundPath: " /tmp/wall.jpg ", fixedPreset: "celestial-torii" }),
    '{\n  "backgroundMode": "custom",\n  "backgroundPath": "/tmp/wall.jpg",\n  "fixedPreset": "celestial-torii"\n}\n');
});

test("round-trips canonical config through parse, serialize, and parse", () => {
  const parsed = Config.normalize('{"backgroundPath":" /tmp/wall.jpg ","backgroundMode":"custom"}');
  const reparsed = Config.normalize(Config.serialize(parsed));

  assert.deepEqual(reparsed, parsed);
});

test("serialize refuses invalid drafts", () => {
  assert.throws(
    () => Config.serialize({ backgroundMode: "custom", backgroundPath: "" }),
    /required/i,
  );
});

test("compares configs after canonical validation", () => {
  assert.equal(
    Config.sameConfig(
      { backgroundMode: "fixed", backgroundPath: "/ignored" },
      { backgroundMode: "fixed", backgroundPath: "" },
    ),
    true,
  );
  assert.equal(
    Config.sameConfig(
      { backgroundMode: "fixed", backgroundPath: "", fixedPreset: "misty-torii-shrine" },
      { backgroundMode: "fixed", backgroundPath: "", fixedPreset: "moonlit-mountain" },
    ),
    false,
  );
  assert.equal(
    Config.sameConfig(
      { backgroundMode: "custom", backgroundPath: "/one.jpg" },
      { backgroundMode: "custom", backgroundPath: "/two.jpg" },
    ),
    false,
  );
});
