# Ejemplos: patrón inseguro → versión segura

Cada bloque muestra el error más frecuente en código generado con IA y su corrección. Los ejemplos son ilustrativos; adáptalos al framework del proyecto.

## 1. SQL por concatenación

```js
// ❌ Vulnerable
const q = "SELECT * FROM clientes WHERE email = '" + email + "'";
const { rows } = await db.query(q);

// ✅ Parametrizada
const { rows } = await db.query('SELECT * FROM clientes WHERE email = $1', [email]);
```

```python
# ❌ Vulnerable
cursor.execute(f"SELECT * FROM clientes WHERE email = '{email}'")

# ✅ Parametrizada
cursor.execute("SELECT * FROM clientes WHERE email = %s", (email,))
```

Para `ORDER BY` o nombres de columna, usa una lista blanca:

```js
const COLUMNAS = { nombre: 'nombre', fecha: 'created_at' };
const columna = COLUMNAS[req.query.ordenar] ?? 'created_at';
```

## 2. IDOR: acceso a recursos ajenos

```js
// ❌ Solo comprueba que el usuario está logueado
app.get('/api/contactos/:id', requireAuth, async (req, res) => {
  const { rows } = await db.query('SELECT * FROM contactos WHERE id = $1', [req.params.id]);
  res.json(rows[0]);
});

// ✅ Comprueba la propiedad en la misma consulta
app.get('/api/contactos/:id', requireAuth, async (req, res) => {
  const { rows } = await db.query(
    'SELECT id, nombre, email FROM contactos WHERE id = $1 AND org_id = $2',
    [req.params.id, req.user.orgId]
  );
  if (rows.length === 0) return res.status(404).json({ error: 'No encontrado' });
  res.json(rows[0]);
});
```

## 3. Permisos solo en el frontend

```js
// ❌ El botón se oculta, pero el endpoint acepta la petición
// <button hidden={!user.isAdmin}>Borrar</button>
app.delete('/api/usuarios/:id', requireAuth, deleteUser);

// ✅ El servidor decide
app.delete('/api/usuarios/:id', requireAuth, requireRole('admin'), deleteUser);
```

## 4. Secretos en el código

```js
// ❌ Nunca
const stripe = require('stripe')('sk_live_...');

// ✅ Desde el entorno, con fallo explícito si falta
const key = process.env.STRIPE_SECRET_KEY;
if (!key) throw new Error('Falta STRIPE_SECRET_KEY');
const stripe = require('stripe')(key);
```

## 5. Ejecución de código y comandos

```js
// ❌ Ejecución dinámica y shell con datos del usuario
eval(req.body.expresion);
exec(`convert ${req.body.archivo} salida.png`);

// ✅ Sin eval; argumentos separados
execFile('convert', [rutaValidada, 'salida.png']);
```

```python
# ❌
subprocess.run(f"convert {archivo} salida.png", shell=True)

# ✅
subprocess.run(["convert", archivo_validado, "salida.png"], check=True)
```

## 6. Rutas y path traversal

```js
// ❌ Permite ../../etc/passwd
res.sendFile(path.join(__dirname, 'uploads', req.params.nombre));

// ✅ Normaliza y comprueba el prefijo
const base = path.resolve(__dirname, 'uploads');
const ruta = path.resolve(base, req.params.nombre);
if (!ruta.startsWith(base + path.sep)) return res.status(400).end();
res.sendFile(ruta);
```

## 7. HTML inyectado (XSS)

```jsx
// ❌
<div dangerouslySetInnerHTML={{ __html: comentario.texto }} />

// ✅ Texto escapado por defecto
<div>{comentario.texto}</div>

// Si necesitas HTML enriquecido, sanitízalo antes
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(comentario.html) }} />
```

## 8. Contraseñas

```js
// ❌
const hash = crypto.createHash('md5').update(password).digest('hex');

// ✅ argon2id (preferido)
const argon2 = require('argon2');
const hash = await argon2.hash(password);
const ok = await argon2.verify(hash, password);
```

```python
# ✅ bcrypt con coste 12
import bcrypt
hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
ok = bcrypt.checkpw(password.encode(), hash)
```

## 9. Errores que revelan información

```js
// ❌ Expone la consulta y el stack
app.use((err, req, res, next) => res.status(500).json({ error: err.message, stack: err.stack }));

// ✅ Respuesta genérica; detalle solo en logs
app.use((err, req, res, next) => {
  const id = crypto.randomUUID();
  logger.error({ id, err }); // sin datos personales
  res.status(500).json({ error: 'Error interno', id });
});
```

## 10. Cookies de sesión

```js
// ❌
res.cookie('sesion', token);

// ✅
res.cookie('sesion', token, {
  httpOnly: true,
  secure: true,
  sameSite: 'lax',
  maxAge: 15 * 60 * 1000,
});
```

## 11. Login que revela si existe el email

```js
// ❌
if (!usuario) return res.status(404).json({ error: 'El email no existe' });
if (!ok) return res.status(401).json({ error: 'Contraseña incorrecta' });

// ✅ Mismo mensaje y tiempo de respuesta similar
if (!usuario || !(await verificar(usuario, password))) {
  return res.status(401).json({ error: 'Credenciales incorrectas' });
}
```

## 12. Webhooks sin firma

```js
// ❌ Acepta cualquier petición
app.post('/webhooks/pagos', express.json(), (req, res) => procesar(req.body));

// ✅ Verifica firma sobre el cuerpo crudo, responde rápido y es idempotente
app.post('/webhooks/pagos', express.raw({ type: 'application/json' }), async (req, res) => {
  const firma = req.headers['x-firma'];
  if (!verificarFirma(req.body, firma, process.env.WEBHOOK_SECRET)) return res.status(401).end();
  const evento = JSON.parse(req.body);
  if (await yaProcesado(evento.id)) return res.status(200).end();
  await colaEventos.add(evento);
  res.status(200).end();
});
```

## 13. CORS abierto

```js
// ❌
app.use(cors({ origin: '*', credentials: true }));

// ✅ Lista explícita
app.use(cors({ origin: ['https://app.midominio.com'], credentials: true }));
```

## 14. CSV: inyección de fórmulas al exportar

```python
# ❌ Una celda "=HYPERLINK(...)" se ejecuta al abrir el CSV
csv_writer.writerow([nombre, email])

# ✅ Neutraliza fórmulas
def celda_segura(valor: str) -> str:
    return "'" + valor if valor[:1] in ("=", "+", "-", "@") else valor
csv_writer.writerow([celda_segura(nombre), celda_segura(email)])
```

## 15. Subida de archivos

```js
// ❌ Confía en el nombre y en el MIME declarado
fs.writeFileSync(path.join('public', req.file.originalname), req.file.buffer);

// ✅ Límite de tamaño, nombre generado y fuera del directorio web
const { fileTypeFromBuffer } = await import('file-type');
const tipo = await fileTypeFromBuffer(req.file.buffer);
if (!tipo || !['image/png', 'image/jpeg'].includes(tipo.mime)) return res.status(415).end();
const nombre = `${crypto.randomUUID()}.${tipo.ext}`;
fs.writeFileSync(path.join(DIR_PRIVADO, nombre), req.file.buffer);
```

## 16. Limitar intentos

```js
// ✅ Límite específico para login
const loginLimiter = rateLimit({ windowMs: 15 * 60 * 1000, max: 10, standardHeaders: true });
app.post('/api/login', loginLimiter, loginHandler);
```

## 17. Peticiones del servidor a URLs del usuario (SSRF)

```js
// ❌ El usuario puede apuntar a 169.254.169.254 o a servicios internos
const r = await fetch(req.body.url);

// ✅ Lista blanca de dominios y bloqueo de rangos internos
const url = new URL(req.body.url);
if (!DOMINIOS_PERMITIDOS.includes(url.hostname)) return res.status(400).end();
const r = await fetch(url, { redirect: 'error', signal: AbortSignal.timeout(5000) });
```
