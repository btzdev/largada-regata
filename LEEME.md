# Largada de Regata — Guía de uso y despliegue

## Archivos
- `index.html` — la app completa (mapa, capturas GPS, cálculos)
- `manifest.json`, `sw.js` — la hacen instalable y con app-shell offline
- `icon-192.png`, `icon-512.png` — íconos

## Publicar (necesario para GPS + mapa reales)
Igual que la vez anterior: subí los 5 archivos a **GitHub Pages**, **Netlify Drop** (https://app.netlify.com/drop) o **Vercel**. Cualquiera te da una URL con HTTPS en minutos, requisito para que el GPS funcione en el celular.

## Cómo se usa en el agua

1. **Marcar la línea de largada**: parado sobre (o al lado de) la comisión, tocá "Marcar Comisión". Andá hasta la boya y tocá "Marcar Boya". Vas a ver la línea verde en el mapa y su largo en metros.

2. **Medir la deriva**: con el barco quieto (sin motor, sin vela trabajando — a la deriva pura), tocá "Marcar Punto 1". Esperá al menos 30-60 segundos (cuanto más tiempo, más precisa la medición) y tocá "Marcar Punto 2". La app calcula:
   - Velocidad total de la deriva (nudos)
   - Rumbo de la deriva
   - El componente de esa velocidad que es **perpendicular a la línea de largada** (lo único que importa para el cálculo — el componente paralelo a la línea no te acerca ni aleja de ella)
   - Si la corriente te acerca o te aleja de la línea

3. **Cuenta regresiva**: ingresá los minutos que faltan para la largada (según el reloj oficial de la regata) y tocá "Iniciar". Va a aparecer:
   - Un cronómetro grande en cuenta regresiva
   - Una **línea punteada naranja en el mapa**, paralela a la línea de largada, que representa: *"si estás parado sobre esta línea ahora mismo y solo te dejás llevar por la corriente, vas a llegar exactamente a la línea de largada cuando se cumpla el tiempo restante."*
   - A medida que corre el reloj, esa línea se va acercando a la línea real, hasta coincidir con ella exactamente en el momento de la largada.

4. Usála como referencia visual: si tu posición actual está del lado de "afuera" de la línea naranja, vas a llegar tarde (te falta terreno); si estás del lado de "adentro", vas a llegar antes de tiempo y quizás tengas que hacer tiempo (círculo, ochos, etc).

## Capas náuticas adicionales (nuevas)

Se agregaron dos capas opcionales, activables con los botones "⚓ Boyas (OpenSeaMap)" y "📏 Alturas del río (INA)":

- **OpenSeaMap**: capa mundial y gratuita de boyas, faros y marcas náuticas, mantenida por la comunidad. En ríos interiores como el Paraná la cobertura puede ser parcial — depende de que algún navegante haya cargado esas boyas.
- **INA (Instituto Nacional del Agua)**: usa la API pública `alerta.ina.gob.ar` para mostrar estaciones de medición con la **altura hidrométrica** más reciente (nivel del río en metros), no la cartografía de canal ni las boyas de navegación oficiales.

**Advertencia técnica sobre la capa INA**: es una API pública real y documentada, pero al escribir esto no pude probarla en vivo desde un navegador real (mi entorno de desarrollo no tiene acceso a ese dominio). El código incluido:
- Intenta adivinar los nombres de los campos de la respuesta (id de estación, nombre, valor, fecha) probando varias alternativas comunes.
- Si el servidor no permite pedidos directos desde el navegador (política CORS) o el formato de los datos difiere de lo esperado, la app va a mostrar un aviso claro en el mapa en lugar de fallar en silencio, con un link directo al sitio oficial del INA como respaldo.
- Es muy probable que necesite un pequeño ajuste una vez la pruebes en el agua con conexión real — si me contás qué mensaje de error aparece (o qué datos trae la respuesta), te ajusto el código enseguida.

**No incluidas (por ahora)**: las cartas náuticas oficiales del Servicio de Hidrografía Naval (batimetría, profundidades, boyas oficiales del canal navegable) no tienen un servicio público gratuito — se venden como cartas raster/impresas. Si en algún momento comprás alguna, se puede georreferenciar y agregar como capa propia (proceso de conversión a "tiles" que puedo armar si llegás a esa instancia).

## Notas importantes
- El cálculo de deriva asume que **no estás propulsando el barco** entre el Punto 1 y el Punto 2 (ni motor ni vela generando fuerza) — solo el efecto de viento+corriente sobre el casco. Si en el momento de la largada estás navegando activamente, tu velocidad real ya no es la de deriva, sino la que decidas vos: la línea naranja es una referencia de *dónde estarías si no hicieras nada*, útil para calibrar el ojo antes de la salida.
- Si el reloj oficial de la comisión difiere del tuyo, podés detener la cuenta regresiva y volver a ingresar los minutos correctos en cualquier momento para resincronizar.
- Los puntos marcados se guardan en el celular (localStorage), así que si se cierra la pestaña por error no se pierden — al volver a abrir la app siguen ahí. Para una regata nueva, usá los botones "Reiniciar línea" y "Reiniciar deriva".
- Si no tenés señal de datos en el momento de la carrera, los tiles del mapa (las imágenes de fondo) no van a poder descargarse si no los cargaste antes con conexión — los cálculos de deriva y línea paralela funcionan igual sin mapa visual, pero para verlos dibujados necesitás haber tenido internet al menos una vez en esa zona con el zoom que vayas a usar.
