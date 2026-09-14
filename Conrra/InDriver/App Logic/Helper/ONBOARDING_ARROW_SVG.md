# How to add an SVG arrow for the onboarding Next button

iOS does not use SVG directly in `UIImageView` or `UIButton`. Use one of these approaches:

---

## Option 1: Asset catalog with PDF (recommended)

1. **Convert SVG to PDF** (vector keeps quality at any size):
   - In Figma: select the arrow, Export → PDF.
   - Or use an online converter or `rsvg-convert` (e.g. `rsvg-convert -f pdf -o arrow.pdf arrow.svg`).

2. **Add to the app’s asset catalog**:
   - In Xcode, open **Assets.xcassets** (e.g. `Configurable/Theme/Assets.xcassets`).
   - Right‑click → **New Image Set**.
   - Name it **`onboarding_arrow`** (this is the name used in code).
   - In the set’s attributes, set **Scales** to **Single Scale** or **All**, and **Render As** to **Template Image** (so the button’s `tintColor` applies).
   - Drag your **PDF** into the 1x slot (or into the set). Xcode will use it as a vector asset.

3. **Code**: `HelperViewController` already looks for `[UIImage imageNamed:@"onboarding_arrow"]`. If that image exists, the Next button uses it and the "›" title is removed.

---

## Option 2: PNG from SVG (simpler, not vector)

1. Export the arrow from Figma (or another tool) as **PNG @1x, @2x, @3x** (e.g. 24pt, 48pt, 72pt).
2. In the asset catalog, create an image set named **`onboarding_arrow`** and add the three PNGs to 1x, 2x, 3x.
3. Set **Render As** to **Template Image** so the button tint (e.g. black) applies.
4. Same code as above: the Next button will use this image when present.

---

## Option 3: SF Symbol (no asset)

If you don’t add an asset named **`onboarding_arrow`**, the code falls back to the system **chevron.right** symbol. No SVG or image is required; the button will show the system chevron with your yellow background and black tint.

---

## Summary

- **Asset name in code:** `onboarding_arrow`
- **Where to add:** Any **Assets.xcassets** that is included in the Conrra target (e.g. `Configurable/Theme/Assets.xcassets`).
- **Template image:** Use **Template Image** so the arrow color follows the button’s `tintColor` (black on yellow).
