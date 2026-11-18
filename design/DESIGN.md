---
name: Teal Meridian
colors:
  surface: '#f5fafa'
  surface-dim: '#d5dbdb'
  surface-bright: '#f5fafa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff5f4'
  surface-container: '#e9efef'
  surface-container-high: '#e4e9e9'
  surface-container-highest: '#dee4e3'
  on-surface: '#171d1d'
  on-surface-variant: '#3e4946'
  inverse-surface: '#2c3132'
  inverse-on-surface: '#ecf2f1'
  outline: '#6e7a76'
  outline-variant: '#bdc9c5'
  surface-tint: '#006b5e'
  primary: '#005e53'
  on-primary: '#ffffff'
  primary-container: '#00796b'
  on-primary-container: '#a1feec'
  inverse-primary: '#7ad7c6'
  secondary: '#006a63'
  on-secondary: '#ffffff'
  secondary-container: '#8bf1e6'
  on-secondary-container: '#006f67'
  tertiary: '#1b5d4f'
  on-tertiary: '#ffffff'
  tertiary-container: '#377667'
  on-tertiary-container: '#bafae8'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#97f3e2'
  primary-fixed-dim: '#7ad7c6'
  on-primary-fixed: '#00201b'
  on-primary-fixed-variant: '#005047'
  secondary-fixed: '#8ef4e9'
  secondary-fixed-dim: '#71d7cd'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#00504a'
  tertiary-fixed: '#afefdd'
  tertiary-fixed-dim: '#94d3c1'
  on-tertiary-fixed: '#00201a'
  on-tertiary-fixed-variant: '#065043'
  background: '#f5fafa'
  on-background: '#171d1d'
  surface-variant: '#dee4e3'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0em
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: 0em
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
    letterSpacing: 0em
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
    letterSpacing: 0.01em
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  space-xxl: 3rem
---

## Brand & Style

The design system establishes an ultra-reliable, focused utility aesthetic for offline text translation. The visual atmosphere centers on immediate utility, optical clarity, and low-latency interaction. It evokes reassurance, precision, and zero-connectivity resilience—feeling native to modern mobile platforms while maintaining strong editorial crispness.

The visual direction follows an authentic **Material 3 (Material You)** philosophy infused with high-performance utility minimalism:
- **Surface Elevation Hierarchy:** Deep reliance on tonal surface tiers (`surface-container-low`, `surface-container`, `surface-container-high`) rather than harsh physical drops.
- **Physical Affordances:** Fluid interactive feedback, tactile pill-shaped interactive targets, rounded card perimeters, and clear offline state badges that immediately communicate on-device model status.
- **High-Density Legibility:** Distraction-free translation workspaces with expansive typography contrasts between input queries, translations, and ancillary linguistic controls.

## Colors

The palette is engineered around clean teal tones, dynamic tonal surface containers, and rigorous accessibility standards (WCAG AAA for text fields, AA for interactive accents).

- **Primary (`#00796B`):** Deep, confident pine teal used for primary action buttons, key toggle states, active navigation indicators, and key operational confirmations.
- **Secondary (`#4DB6AC`):** Vibrant seafoam teal used for offline pack download progress rings, soft active pill badge fills, accent highlights, and secondary chips.
- **Tertiary (`#004D40`):** Ultra-dense spruce teal reserved for high-emphasis headlines, active text cursor accents, and selected source language selectors.
- **Neutral (`#5A6060`):** Balanced cool slate-slate gray generating the neutral and neutral-variant palettes. Powers border dividers, inactive iconography, placeholder states, and ambient tonal layer steps.

### Tonal Surface Palette
- `surface`: `#FAFDFB` (pure canvas background)
- `surface-container-low`: `#F2F6F4` (grouped input blocks)
- `surface-container`: `#ECF1EF` (standard card background, language pickers)
- `surface-container-high`: `#E3EAE7` (interactive modal sheets, offline pack trays)
- `on-surface`: `#191C1B` (primary typography, high contrast)
- `on-surface-variant`: `#3F4947` (secondary metadata, pronunciation text, language flags)
- `outline-variant`: `#BFC9C6` (subtle dividers, zero-shadow card strokes)

## Typography

Inter powers all functional scales, chosen for its neutral grotesque architecture, tall x-height, and legible disambiguation of glyphs across multiple language scripts.

- **Translation Displays (`body-lg`, `display-lg-mobile`):** Input text and translated outputs use `body-lg` for standard paragraphs and `display-lg-mobile` for brief phrases. The line-height allows inline phonetic/phonology guides without vertical collisions.
- **Labels & Status (`label-md`, `label-sm`):** Offline status badges, phonetic guides, and script identifiers leverage tight, slightly tracked upper/sentence case to ensure optical legibility inside compact pills.
- **System Density:** Numeric counts (storage MBs, dictionary counts) use tabular figure alternates (`tnum`) inherent to Inter to prevent jitter when recalculating package sizes.

## Layout & Spacing

The layout is anchored on an 8pt base grid with a 4pt micro-increment for dense translation metadata and badge alignment.

### Mobile Grid Philosophy
- **Standard Screens (<600px):** Single-column stacked fluid layout with `1rem` outer canvas margin (`margin`). Cards span the entire width minus margins. Translation input and output cards occupy stacked vertical segments with an inline swap action.
- **Tablet & Foldables (600px–1024px):** Dual-pane split canvas with `1.5rem` outer margin (`margin-tablet`) and `1.5rem` gutter (`gutter-tablet`). Source language editor sits on the left pane; real-time offline translation engine output renders simultaneously on the right pane.
- **Vertical Hierarchy:** Navigation Top App Bar sits pinned with `space-md` inner padding. Floating Quick Swap language toggles use a fixed `48px` minimum touch target, centered between translation containers.

## Elevation & Depth

Visual hierarchy adheres strictly to Material 3 tonal elevation logic combined with subtle diffused ambient contact shadows.

### Surface Tiers
- **Tier 0 (Base Canvas):** `#FAFDFB` — Foundation layer, non-elevated.
- **Tier 1 (Filled Input Card):** `#F2F6F4` — Inset source text entry card; zero box shadow, defined entirely by chromatic contrast with the base canvas.
- **Tier 2 (Elevated Translation Card):** `#ECF1EF` with ambient tinted shadow:
  `box-shadow: 0px 4px 16px -2px rgba(0, 77, 64, 0.08), 0px 1px 4px 0px rgba(0, 77, 64, 0.04);`
- **Tier 3 (Floating Action & Drawers):** `#E3EAE7` with elevated contact shadow:
  `box-shadow: 0px 8px 24px -4px rgba(0, 77, 64, 0.12), 0px 2px 6px 0px rgba(0, 77, 64, 0.06);`

### Glassmorphism Overlays
App bars and pinned bottom execution decks use subtle backdrop filtering on high-scroll surfaces: `background: rgba(250, 253, 251, 0.88)` with `backdrop-filter: blur(12px)` to prevent sharp text bleed while maintaining fluid spatial hierarchy.

## Shapes

The design system implements a rounded M3 aesthetic where standard cards, dialogs, and bottom sheets leverage generous radii (16px–24px), contrasted with full-radius pill silhouettes (9999px) for interactive pills and badges.

- **Standard Cards (`rounded-lg` / 16px):** Used for translation output modules, dictionary definitions, and offline pack list elements.
- **Primary Viewport Containers (`rounded-xl` / 24px):** Used for active language selection sheets, modal dialogs, and text conversion blocks.
- **Tactile Pills (`rounded-full` / 9999px):** Universal for offline status indicators, language switchers, action buttons, and segmented controls.
- **Icon Buttons (`rounded-full` / 9999px):** Circular 48x48px bounding boxes with a 40x40px visible active surface.

## Components

### Buttons & Language Selectors
- **Primary Filled Button:** High-prominence action (e.g., "Translate Now", "Download Language Pack"). Background `#00796B`, foreground `#FFFFFF`, height `48px`, border radius `9999px`. Subtle scale press feedback (`scale: 0.98`) and ink-ripple overlay (`rgba(255, 255, 255, 0.16)`).
- **Tonal Button:** Secondary actions. Background `#ECF1EF`, text `#004D40`.
- **Language Selector Bar:** Centered pill strip bridging Source and Target languages. Dual sub-pills (`#ECF1EF`) flanking a circular tactile swap button (`#00796B` with white icon) that spins 180 degrees on tap.

### Offline Status Badges & Chips
- **Offline Downloaded Pill:** Height `24px`, horizontal padding `10px`, background `#E0F2F1`, text `#004D40`, border `1px solid #B2DFDB`. Displays a crisp mini checkmark or download cloud icon (14px).
- **Download Pending/Progress Pill:** Background `#F2F6F4`, border `1px solid #BFC9C6`, holding a miniature 12px circular progress ring rendered in `#00796B`.

### Translation Cards (Input & Output)
- **Source Input Card:** Filled container (`#F2F6F4`), border radius `20px`, padding `16px`. Houses clear-all button, instant character counter, and audio input triggers. No borders in resting state; gains a `2px solid #00796B` focus ring when actively typed into.
- **Translated Result Card:** Elevated container (`#ECF1EF`), border radius `24px`, padding `20px`. Contains copy-to-clipboard, text-to-speech speaker button, full-screen expansion toggle, and inline phonetic/romanization subtitle text (`#3F4947`).

### Navigation Drawer & Top App Bar
- **M3 Top App Bar:** Height `64px`, background canvas-toned with dynamic tinting on scroll. Houses trailing icon buttons: "Offline Dictionary Management" badge and "Settings".
- **Modal Navigation Drawer:** Rounded right corners (`28px`), width `320px`, surface `#F2F6F4`. Displays current offline storage allocation meter (e.g., "1.4 GB / 8.0 GB Used"), followed by grouped language pack rows with instant swipe-to-delete or update actions.

### Lists & Form Elements
- **Offline Pack Row Item:** Minimum height `56px`, padding `12px 16px`, subtle bottom divider (`1px solid #ECF1EF`). Title in `title-md`, secondary package file size (`body-sm`), accompanied by a right-aligned download state icon button.
- **Checkboxes & Switches:** M3 track switches using primary teal (`#00796B`) for active thumb/track fills and `#BFC9C6` for inactive outlines.