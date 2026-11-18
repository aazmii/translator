---
name: Teal Meridian Dark
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#383939'
  surface-container-lowest: '#0d0f0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#282a2a'
  surface-container-highest: '#333535'
  on-surface: '#e2e2e2'
  on-surface-variant: '#bcc9cb'
  inverse-surface: '#e2e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#869395'
  outline-variant: '#3d494b'
  surface-tint: '#56d7e9'
  primary: '#6fecfe'
  on-primary: '#00363c'
  primary-container: '#4dd0e1'
  on-primary-container: '#00565f'
  inverse-primary: '#006973'
  secondary: '#66d9cc'
  on-secondary: '#003732'
  secondary-container: '#1ea296'
  on-secondary-container: '#00302b'
  tertiary: '#9de8e1'
  on-tertiary: '#003734'
  tertiary-container: '#81ccc5'
  on-tertiary-container: '#005752'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#93f1ff'
  primary-fixed-dim: '#56d7e9'
  on-primary-fixed: '#001f23'
  on-primary-fixed-variant: '#004f57'
  secondary-fixed: '#84f5e8'
  secondary-fixed-dim: '#66d9cc'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#a4f0e9'
  tertiary-fixed-dim: '#89d4cd'
  on-tertiary-fixed: '#00201e'
  on-tertiary-fixed-variant: '#00504b'
  background: '#121414'
  on-background: '#e2e2e2'
  surface-variant: '#333535'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.015em
  headline-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 26px
    fontWeight: '600'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  title-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  title-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 22px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '600'
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
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes a high-precision, utilitarian, yet refined dark-mode atmosphere tailored for the Go Translator mobile application. It balances Material 3's tonal surface hierarchy with a distinctive, focused field-tool aesthetic. 

The personality is fast, silent, and reliable. The target audience encompasses cross-border travelers, remote polyglot operators, field teams, and daily conversationalists who demand immediate comprehension without interface distraction. The UI evokes clinical calm, computational accuracy, and effortless visibility in both pitch-black transit hubs and dim meeting environments.

Visually, the system marries Modern Material minimalism with tactical clarity: rich charcoal surfaces anchor the viewport, layered tonal planes define context without visual clutter, and piercing teal highlights direct action with purposeful restraint.

## Colors

The palette is engineered specifically for deep-dark ergonomics, using calibrated charcoal neutrals and layered teal luminescence to maintain battery preservation and glanceable hierarchy.

- **Primary (`#4dd0e1`):** Electric Cyan-Teal. Serves as the primary focal point, active translation target, audio waveform highlights, and interactive accents.
- **Secondary (`#26a69a`):** Deep Jade Teal. Applied to secondary controls, active pill states, toggles, and contextual action confirmations.
- **Tertiary (`#80cbc4`):** Soft Pale Teal. Utilized for supplementary indicators, phonetic guides, tags, and subtle feedback signals.
- **Neutral Base (`#121414`):** Deep Obsidian Charcoal. The root app background providing deep optical contrast without true-black harshness.
- **Surface Elevation Hierarchy:**
  - `surface-container-low` (`#191c1c`): Recessed canvas zones, navigation rails, and bottom sheets in rest state.
  - `surface-container` (`#202424`): Primary card surfaces, dictionary tiles, and resting input frames.
  - `surface-container-high` (`#262b2b`): Elevated conversational message bubbles, floating action trays, and active input overlays.
  - `surface-container-highest` (`#2d3232`): Selected chips, search bars, and focused state elevations.
- **Border / Outline:** Ghost-borders rendered via `#2d3232` (resting) and `#4dd0e1` with 32% alpha (focused).

## Typography

The type system blends the computational, modern edge of **Space Grotesk** for primary anchors with the high legibility of **Inter** for translated copy and user interface controls.

- **Translation Playback & Outputs:** `body-lg` and `headline-md` are optimized for high reading velocity. When output text is dense, default to `body-lg` with a high-contrast `#E0E3E3` tone to eliminate eye strain against dark surfaces.
- **Language Identifiers & Metadata:** Formatted with `label-sm` or `label-md` using medium-to-bold weights and slight tracking to ensure readability at miniature mobile sizes.
- **Phonetic / Transliteration Text:** Employs `body-sm` set to `#80cbc4` to immediately distinguish native scripts from Romanized guides.

## Layout & Spacing

Layouts adhere to an 8pt rhythmic grid tailored for rapid touch manipulation and thumbs-first usage on modern handheld devices.

- **Mobile Viewports (Under 600px):** Single-column fluid composition anchored by a 16px (`1rem`) lateral canvas margin. Structural modules stack vertically: Input Bay (top half) followed by Translation Target Bay (bottom half), or sequential conversational dialogue streams.
- **Conversational Split Screen:** For face-to-face simultaneous translation, the viewport divides along the horizontal meridian with mirrored inputs, utilizing `space-md` gaps between split dialogue panels.
- **Component Padding Scale:** 
  - `space-xs` (4px): Inline icon spacing, badge paddings.
  - `space-sm` (8px): Chip padding, list row internal vertical gaps.
  - `space-md` (16px): Standard container internal padding, text field insets.
  - `space-lg` (24px): Card module separation and sheet headers.
  - `space-xl` (32px): Primary section terminal offsets and floating trigger clearance.

## Elevation & Depth

Visual hierarchy does not rely on heavy drop shadows, which muddy dark interfaces. Instead, the design system utilizes Material 3's tonal surface layering supplemented by precise, low-contrast ghost borders.

- **Surface Tonal Stacking:** Depth is achieved by stepping colors up from `#121414` (canvas), `#191c1c` (low background), `#202424` (surface container cards), to `#262b2b` and `#2d3232` (elevated panels, dialogues, and floating trays).
- **Ghost Borders:** Cards, inputs, and bottom sheets feature a 1px structural stroke using `#2d3232` or `#353b3b` (15% white tint equivalent) to preserve edge definition against adjoining dark zones.
- **Luminescent Accent Glows:** Active voice-listening states and floating execution buttons apply an ambient, colored drop shadow: `0px 8px 24px rgba(77, 208, 225, 0.18)`—providing a focused, night-vision-friendly halo without washing out screen contrast.

## Shapes

The shape architecture relies on balanced, softened geometry (`roundedness: 2`). This keeps elements friendly for mobile touch targets while retaining an intentional, technical posture.

- **Micro Controls & Chips:** Feature 8px (`0.5rem`) corner radii for swift optical grouping.
- **Cards & Input Pods (`rounded-lg`):** Feature 16px (`1rem`) corner radii, reinforcing clear module encapsulation.
- **Dialogue Sheets & Modal Trays (`rounded-xl`):** Feature 24px (`1.5rem`) top-corner radii to cleanly frame overlay contexts.
- **Microphone & Quick-Action Hubs:** Complete circles (`9999px`) to immediately communicate their persistent interactive nature.

## Components

### Buttons
- **Primary (Translate/Action):** Solid fill using `#4dd0e1` with `#121414` label text in `label-lg` bold. Hover/active shifts to `#80cbc4`. Corner radius 8px (`space-sm` * 2) or fully circular for audio triggers.
- **Secondary (Swap Language, Clear):** Surface fill `#262b2b` with a 1px border of `#2d3232` and text in `#4dd0e1`.
- **Floating Dictation Button:** Circular 64px button anchored centrally; gradient fill transitioning from `#00897b` to `#4dd0e1`, with ambient glow elevation during active audio capture.

### Chips (Language Switchers & Modes)
- **Resting:** Filled with `#202424` and bordered with `#2d3232`. Text in `#E0E3E3` using `label-md`.
- **Selected / Active:** Background `#26a69a` at 20% opacity, bordered with `#4dd0e1`, with text in `#4dd0e1` and leading icons rendered in `#80cbc4`.

### Input Fields & Translation Bays
- **Source Box:** Container `#202424` with top borderless blend or delicate 1px `#2d3232` bounding line. Internal padding set to `space-md`. High-contrast placeholder text in `#707979`.
- **Active Focus:** 1px stroke transitions to `#4dd0e1` with zero interior color shift to preserve readability.

### Cards (History, Phrasebook, Result)
- **Base Style:** `#202424` or elevated `#262b2b` background, 16px border radius, enclosed in a 1px `#2d3232` outline.
- **Result Output:** Elevated card featuring primary translated text in `#FFFFFF` (`body-lg`), companion transliteration in `#80cbc4` (`body-sm`), and a secondary tool shelf (copy, text-to-speech, favorite) at the card footer using low-key iconography in `#A0A8A8`.

### Lists & History Records
- **Dividers:** Borderless separation through `space-xs` margin gaps over alternate surface colors, or hairline `#1f2323` rules.
- **List Items:** Flat `#191c1c` transitioning to `#202424` upon touch feedback, keeping interactions subtle and free of jarring light flashes.

### Checkboxes, Radios, & Switches
- **Toggles:** Track in `#202424` with a `#2d3232` stroke; active thumb and track fill illuminated in `#26a69a` and `#4dd0e1`.

### Translation-Specific Elements
- **Audio Waveform Meter:** Rendered in real-time using `#4dd0e1` bars pulsing above an elevated `#262b2b` docked control sheet.
- **Language Pair Selector Bar:** Docked at the top or bottom thumb zone, displaying source and target languages inside conjoined `#262b2b` pill modules linked by an interactive `#26a69a` reverse arrow.