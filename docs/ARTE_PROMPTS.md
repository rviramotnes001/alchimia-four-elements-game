# Alchimia — Guía de arte para cutscenes (prompts para Google Flow)

> Objetivo: que **todas las imágenes fijas de las cutscenes se vean como del mismo libro de cuentos**, con personajes siempre reconocibles.
> Los prompts están en **inglés** porque los generadores de imagen suelen responder mejor así.
> Las descripciones de personajes salen de tus sprites reales (`arte/original/Characters` y `Player`).

---

## Cómo trabajar para mantener la consistencia

1. **Empieza con una sola imagen de prueba** (la escena 1) y ajusta el "estilo maestro" hasta que te guste. Después no lo cambies.
2. **Genera primero una "hoja de personaje" de cada uno** (Erek, Chris, Claytor, Gólem): una imagen de cuerpo completo, fondo liso, vista frontal. Guarda las que más se parezcan a tus sprites.
3. **En cada escena nueva:** pega siempre el **bloque de estilo** + el **bloque de cada personaje que salga**, sin cambiarles palabras. Si Flow permite subir **imágenes de referencia**, adjunta la hoja del personaje además del texto.
4. **Mismo formato siempre:** 16:9 (1920×1080 o similar).
5. **Guarda las imágenes** en `arte/cutscenes/` con nombres como `cs01_apertura_01.png`.
6. **Revisa siempre:** color del pelo, capa y ropa de Erek; corona y capa roja de Chris; barba y bastón de Claytor.

> Nota: Google Flow cambia con frecuencia. Si no ofrece referencias de imagen, la regla de oro es **repetir exactamente los mismos bloques de texto** en cada prompt.

---

## BLOQUE DE ESTILO (pegar siempre al inicio)

```
Warm storybook illustration, hand-painted digital art, soft painterly shading, gentle rim light,
rich saturated but cozy color palette, fantasy kingdom, cinematic 16:9 composition, clean readable
silhouettes, slightly stylized proportions, no text, no watermark, no logo.
```

**Variante si prefieres arte pixelado** (más cercano al juego):
```
High-resolution pixel art scene, detailed, warm saturated palette, cinematic 16:9 composition,
fantasy kingdom, dithering-free smooth gradients, no text, no watermark, no logo.
```
*(Elige una de las dos y úsala siempre.)*

---

## BLOQUES DE PERSONAJES (pegar siempre que aparezca el personaje)

### Erek (príncipe, protagonista)
```
EREK: a young prince, slender, around 18 years old, messy golden-blond hair with an orange tint,
kind and slightly worried expression, green eyes, wearing a deep red tunic with golden cuffs,
brown trousers and boots, and a long dark teal-green cloak with a high collar.
Carries a steel sword on his belt and a small wooden bow on his back.
```

### Rey Chris (padre de Erek)
```
KING CHRIS: an elderly king with short silver-gray hair and a trimmed gray beard, kind green eyes,
a golden crown with a red band and small colorful gems (green, red, blue, purple, pink),
a bright red scarf-collar and long red cape, a dark navy tunic with a golden cross emblem
on the chest and golden cuffs and boots. Warm, wise and gentle expression.
```

### Claytor (antagonista, hermano de Chris)
```
CLAYTOR: a sorcerer, elderly, long wild sage-green hair and a long sage-green beard,
pointed ears, narrow sharp eyes, wearing dark navy-purple robes with golden cuffs and a brown belt,
carrying a wooden staff with a large glowing red gem on top. Menacing but also tired and lonely.
He has a faint family resemblance to King Chris (same face shape).
```

### Gólem de Agua (jefe)
```
WATER GOLEM: a massive crystalline golem made of glowing blue ice-like crystal and water-stone,
sharp crystal shards on the shoulders, back and forearms, a single bright white eye,
chunky arms and legs, dark teal gaps between the plates, covered with faint flowing water.
```

### Mandrágora (enemigo del bosque, opcional)
```
MANDRAKE: a small forest creature with a bark-like body, root legs and a leafy green crown,
slightly mutated by water magic, with glowing damp moss and tiny crystals on its roots.
```

---

## LOS 4 ELEMENTOS (bloques fijos: pegar siempre que aparezcan)

Los elementos salen en el juego y en las cutscenes. Están basados en **tus 4 íconos reales** (`arte/original/Elements/`: `water_element.png`, `earth_element.png`, `fire_element.png`, `air_element.png`). Cada uno tiene **colores y forma fijos**. **No cambies los colores entre imágenes.**

> Si Flow permite imágenes de referencia, **sube también tu ícono** de cada elemento como referencia (son de 32×32, así que amplíalos antes).

| Elemento | Colores | Forma | Zona |
|---|---|---|---|
| **Agua** | Turquesa/menta claro + azul, con blanco | Cristal turquesa de puntas, sobre una base en forma de ola azul | Bosque Cristalino |
| **Tierra** | Naranja/terracota + magenta/vino | Corona de picos de roca, el central más alto | Cuevas |
| **Fuego** | Rojo + amarillo | Llama clásica con núcleo amarillo claro | Volcán |
| **Aire** | Verde azulado (teal) + blanco | Cristal en espiral rodeado por una forma como de llama o gota, sobre una base blanca | Castillo de Claytor |

### Elemento Agua
```
WATER ELEMENT: a glowing turquoise-mint crystal with sharp pointed facets and white highlights,
resting on a swooping blue wave-shaped base with white foam edges; small water droplets and ribbons
of clear water floating around it. Cool, calm and pure feeling.
```

### Elemento Tierra
```
EARTH ELEMENT: a crown of jagged rock spikes in glowing terracotta orange and coral, with deep magenta
and burgundy shadows and darker brick-red base, the tallest spike in the center, small floating pebbles
and warm dust around it. Solid, heavy and ancient feeling.
```

### Elemento Fuego
```
FIRE ELEMENT: a bright classic flame in saturated red and golden yellow with a pale-yellow glowing core,
tongues of fire curling upward, small floating embers and sparks around it. Warm, intense and powerful feeling.
```

### Elemento Aire
```
AIR ELEMENT: a glowing teal-green crystal shaped like a spiral swirl, enclosed by a flame-like teal
outline with white inner highlights, resting on a white base; thin ribbons of wind and tiny glowing
particles circling it. Light, free and fast feeling.
```

### Los 4 elementos juntos
```
THE FOUR ELEMENTS together: four floating glowing elemental emblems in a row: a turquoise crystal on a blue
wave (water), a crown of orange and magenta rock spikes (earth), a red and yellow flame (fire), and a teal
spiral crystal (air). Each keeps its own colors and glow. Magical, harmonious balance.
```

### Monumentos del reino (cada elemento en su pedestal)
```
ELEMENT MONUMENTS: four ancient shrines in a stone plaza, each holding one elemental emblem:
a turquoise crystal on a blue wave, a crown of orange-magenta rock spikes, a red-yellow flame, and a teal
spiral crystal. Each shrine is lit by its own element colors (turquoise-blue, orange-magenta, red-yellow, teal),
with grey stone with glowing runes, grass and flowers growing at the base.
```

### Esencias (los coleccionables)
```
ESSENCES: small glowing crystal shards, each tinted in the colors of its element
(turquoise water, orange earth, red-yellow fire, teal air), floating softly and giving off a gentle glow,
a few sparkles around them.
```
> Nota: tus esencias actuales en `arte/original/Collectibles/Essence` son azul, verde, rojo y amarillo, que **no coinciden** con los íconos de los elementos (por ejemplo, la tierra es naranja y el aire es teal). Más adelante conviene recolorearlas para que coincidan.

### Reino de Alchimia (ambiente)
```
KINGDOM OF ALCHIMIA: a bright, peaceful fantasy kingdom with a warm stone castle with red banners,
green hills, a clear river, cozy villages, flowers, and the four elemental monuments
(water, earth, fire, air) in the central plaza, each glowing with its own color.
```

---

## CUTSCENES DEL CAPÍTULO 1 (prompts de escena)

> Pega: **BLOQUE DE ESTILO** + **bloques de los personajes que aparecen** + el texto de escena.

### CS01 — Apertura: el reino feliz
1. **Escena 1.a (reino de día):**
```
Wide establishing shot of the peaceful kingdom of Alchimia at golden hour: villagers, animals by the river,
children playing, the castle on a hill, four glowing elemental monuments in the plaza. Warm, joyful mood.
```
2. **Escena 1.b (los elementos):**
```
Close view of the four elemental monuments side by side, each holding its element, softly glowing and keeping
the kingdom alive: a turquoise water crystal on a blue wave, a crown of orange-magenta earth rock spikes,
a red-yellow fire flame and a teal air spiral crystal. (Add the 4 ELEMENTS block.)
```
3. **Escena 1.c (llega la noche y Claytor):**
```
Night. A dark silhouette of CLAYTOR with his glowing red-gem staff walks into the plaza followed by hooded
followers. The kingdom is quiet. The four monuments glow. Tense, ominous mood, deep blue night with warm light.
```
4. **Escena 1.d (el robo):**
```
CLAYTOR raising his staff, stealing the four elements, a huge burst of colored energy (turquoise-blue, orange-magenta,
red-yellow, teal) exploding outward and scattering across the sky; KING CHRIS and EREK running in the
background, too late.
```
5. **Escena 1.e (los elementos se dispersan):**
```
Wide shot of three streaks of light flying away in different directions across the kingdom:
turquoise-blue toward the forest, orange-magenta toward the caves, red-yellow toward a distant volcano, while CLAYTOR
keeps only the teal AIR spiral crystal in his hand, smiling darkly.
```

### CS02 — Erek y Chris: la despedida
```
Inside the castle at dawn. KING CHRIS, wounded, sits in a chair with a bandaged shoulder, speaking gently.
EREK stands in front of him looking nervous but determined, holding the hilt of his sword.
Warm light coming through a stained glass window. Emotional, tender mood.
```

### CS03 — El Altar de la Chispa
```
EREK kneels before an ancient mossy stone altar in a forest clearing, a small floating turquoise spark of water magic
(a tiny version of the WATER ELEMENT) rising from it and illuminating his surprised face. Glowing crystals, soft god rays through the trees, magical mood.
```

### CS04 — Antes del jefe
```
EREK at the edge of a crystal lake, a gigantic WATER GOLEM rising slowly from the water in the background,
water pouring from its shoulders, the turquoise WATER ELEMENT glowing in its chest. Epic, tense mood, small hero vs giant.
```

### CS05 — Tras el jefe: Erek recupera el Agua
```
EREK standing in front of the defeated, crumbling WATER GOLEM; the turquoise WATER ELEMENT floating
toward him, flowers and green returning to the forest around, the water turning clear again. Hopeful, triumphant mood.
```

### CS06 — Regreso al castillo
```
EREK returning to the castle at sunset, KING CHRIS greeting him from a balcony with a proud smile,
a faint turquoise glow from the recovered WATER ELEMENT returning to the castle fountain, a path leading toward distant dark caves on the horizon.
```

---

## Pendiente de decidir
- Estilo final: **pintado tipo libro de cuentos** o **pixel art de alta resolución**.
- Cantidad de imágenes por cutscene (las de arriba son una guía mínima; puedes usar menos).
- Si quieres un **estilo de marco o viñeta** (bordes de libro antiguo) para todas las escenas.
