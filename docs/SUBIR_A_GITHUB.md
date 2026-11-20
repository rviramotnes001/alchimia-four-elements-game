# Subir el proyecto a GitHub y trabajar desde Windows y Mac

## Parte 1: Crear el repositorio en GitHub (una sola vez)
1. Entra a **github.com** e inicia sesión (o crea una cuenta gratis).
2. Arriba a la derecha pulsa **+** → **New repository**.
3. Nombre: `alchimia-four-elements` (sin espacios).
4. Elige **Private** (solo tú lo ves).
5. **No marques** "Add a README", ni `.gitignore`, ni licencia (ya tenemos los nuestros).
6. Pulsa **Create repository**. Deja abierta la página: te muestra una dirección tipo `https://github.com/TU_USUARIO/alchimia-four-elements.git`. Cópiala.

## Parte 2: Subir el proyecto desde el Windows (una sola vez)
Abre una terminal **dentro de la carpeta del proyecto** (en el explorador: clic derecho en la carpeta → "Abrir en Terminal"). Ejecuta uno por uno:

```bash
git init -b main
git add .
git commit -m "Primer commit: prototipo de Alchimia"
git remote add origin https://github.com/TU_USUARIO/alchimia-four-elements.git
git push -u origin main
```
- Cambia `TU_USUARIO` por tu usuario real de GitHub.
- Si es la primera vez que usas Git en este equipo, pide antes tu nombre y correo:
  ```bash
  git config --global user.name "Tu Nombre"
  git config --global user.email "tu_correo@ejemplo.com"
  ```
- Al hacer `git push` se abre una ventana para iniciar sesión en GitHub. Acéptala.

## Parte 3: Descargar el proyecto en el Mac (una sola vez)
1. Instala **Git** (en Terminal escribe `git --version`; si no está, el Mac ofrece instalarlo) y **Godot 4.7.2** (godotengine.org, versión estándar).
2. En Terminal, ve a donde quieras guardar el juego (por ejemplo `cd ~/Documents`) y ejecuta:
   ```bash
   git clone https://github.com/TU_USUARIO/alchimia-four-elements.git
   ```
3. Abre Godot → **Import** → elige el archivo `project.godot` de esa carpeta → **F5** para jugar.
   La primera vez Godot tarda un poco en importar las imágenes.

## Parte 4: Rutina diaria (los dos equipos)
**Al empezar a trabajar** (siempre, para traer lo último):
```bash
git pull
```
**Al terminar de trabajar** (para guardar y subir lo que hiciste):
```bash
git add .
git commit -m "Describe brevemente qué hiciste"
git push
```

### Reglas para no tener problemas
- **Nunca trabajes en los dos equipos al mismo tiempo sin hacer `git pull` antes.**
- Termina cada sesión con `git push`. Si te olvidas, lo que hiciste se queda en ese equipo.
- Si Git dice "conflict" (conflicto), no borres nada: pídeme ayuda y lo resolvemos.
- Cierra Godot antes de hacer `git pull`, para que no se pisen archivos.

## Con Claude
Cuando abras un chat nuevo de Claude en la carpeta del proyecto, lee automáticamente `CLAUDE.md`, que contiene el estado actual. Puedes pedirle que haga el `commit` y el `push` por ti.
