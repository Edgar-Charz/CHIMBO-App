# Design pictures

Drop the real pictures here **with exactly these names** and rebuild the app. No code change is
needed: until a file exists, the app shows an icon placeholder in its place. Paths are listed in
`lib/core/assets/app_images.dart`.

Every picture fills its frame with *cover* (no stretching; the edges are cropped to fit), so keep
the important part near the centre and leave some margin around it.

| File | Where it shows | Size (px) | Framing |
|---|---|---|---|
| `brand/logo_mark.png` | Splash (120 × 120 frame, shown whole), later headers | ≥ 512 px on the long side, transparent background | The "C + cart" mark only — the CHIMBO wordmark and tagline are drawn by the app. Current file: cut from CHIMBO.pdf p.1 (255 × 175 source, saved 2× = 456 × 306) — replace with the original logo file when available |
| `onboarding/products.png` | Slide 1 "Bidhaa za Biashara Yako" | 1080 × 1350 (4:5 portrait) | Jewelry + cosmetics, centred |
| `onboarding/wholesale.png` | Slide 2 "Bei za Jumla Zinazokulipa" | 1080 × 1350 (4:5 portrait) | Keep the products in the **top half** — the price card covers the bottom half and the "OKOA ZAIDI" seal sits top-right |
| `onboarding/delivery.png` | Slide 3 "Agiza kwa Urahisi. Pokea Haraka." | 1080 × 1350 (4:5 portrait) | Shop, box and delivery van, centred |
| `auth/welcome.png` | Registration step 1 "Karibu CHIMBO" | 1600 × 1000 (16:10 landscape) | Shop owner with phone, centred |
| `auth/verify.png` | Registration step 2 "Thibitisha Namba" | 1600 × 1000 (16:10 landscape) | Shield + phone with tick, centred |
| `home/cosmetics.png` | Home: Cosmetics card | 800 × 560 (10:7) | Cosmetics display, centred; no text |
| `home/jewelry.png` | Home: Jewelry card | 800 × 560 (10:7) | Jewelry display, centred; no text |
| `home/wholesale_banner.png` | Home: "Bei za Jumla" banner (right side) | 600 × 480 (5:4) | Boxes of products, centred |
| `orders/success.png` | "Oda Imepokelewa!" | 1600 × 1000 (16:10) | CHIMBO box full of products, centred |
| `auth/business.png` | Registration step 3 "Tuambie Kuhusu Biashara Yako" | 1600 × 1000 (16:10 landscape) | Shop front, box, jewelry, centred |

Format: PNG or WebP, under ~150 KB each (blueprint §6.5). Text inside pictures is avoided — all
words are drawn by the app so they can be translated.
