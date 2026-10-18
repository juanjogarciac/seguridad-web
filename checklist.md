# Checklist de seguridad

Marca cada punto. Si un punto no aplica al proyecto, indícalo con «N/A» y el motivo.

## Autenticación y sesiones
- [ ] Contraseñas con argon2id o bcrypt (coste ≥ 12); nunca MD5, SHA1 ni cifrado reversible
- [ ] Rate limiting en login, registro, recuperación y verificación de códigos
- [ ] Bloqueo temporal tras intentos fallidos repetidos
- [ ] Mensajes de error genéricos («credenciales incorrectas»)
- [ ] Cookies de sesión con `HttpOnly`, `Secure` y `SameSite=Lax` o `Strict`
- [ ] JWT: algoritmo fijado en el servidor, sin aceptar `none`, expiración corta y refresh token rotatorio
- [ ] MFA en paneles de administración

## Autorización
- [ ] Todos los endpoints verifican autenticación
- [ ] Cada acceso a un recurso comprueba que pertenece al usuario o a su organización (sin IDOR)
- [ ] Permisos por rol comprobados en el servidor, nunca solo en el frontend
- [ ] El tenant se obtiene del token, nunca de un parámetro controlado por el cliente
- [ ] Operaciones que cambian estado protegidas contra CSRF

## Entrada de datos
- [ ] Validación de tipo, longitud, formato y rango en el servidor
- [ ] Límites de tamaño en body, subidas y listas
- [ ] Ninguna consulta SQL, comando o ruta construida por concatenación
- [ ] `ORDER BY` y nombres de columna con listas blancas
- [ ] Rutas de archivo normalizadas y comprobadas contra el directorio permitido
- [ ] URLs solicitadas por el servidor filtradas (lista blanca y rangos internos bloqueados)
- [ ] Subidas: tipo real comprobado, nombre generado, fuera del directorio web
- [ ] Exportaciones CSV: celdas que empiezan por `=`, `+`, `-` o `@` escapadas

## Salida y navegador
- [ ] Sin `innerHTML`, `v-html` ni `dangerouslySetInnerHTML` con datos externos
- [ ] HTML de usuario sanitizado con una librería probada
- [ ] Content-Security-Policy definida, sin `unsafe-inline` si es posible
- [ ] `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY` o `frame-ancestors 'none'`
- [ ] `Referrer-Policy` y `Permissions-Policy` configuradas
- [ ] CORS limitado a dominios concretos; sin `*` con datos privados

## Errores, logs y configuración
- [ ] Errores al cliente genéricos, con ID de incidencia opcional
- [ ] Sin stack traces, nombres de tablas ni rutas internas en respuestas
- [ ] Logs de accesos y operaciones críticas, sin contraseñas, tokens ni datos personales
- [ ] `NODE_ENV=production` o equivalente, debug desactivado
- [ ] Páginas de error por defecto del framework desactivadas

## Secretos
- [ ] `gitleaks detect --source . -v` sin hallazgos, incluido el historial
- [ ] `.env`, `.env.*`, `*.pem` y `*.key` en `.gitignore`
- [ ] `.env.example` con nombres de variables y sin valores reales
- [ ] Credenciales de producción solo en el proveedor de despliegue o en un gestor de secretos
- [ ] Ningún secreto que haya aparecido en un commit, log o conversación sin rotar

## Base de datos
- [ ] Usuario de la aplicación con permisos mínimos (sin DDL)
- [ ] Desarrollo y producción en bases de datos separadas
- [ ] Copia de seguridad antes de migraciones o borrados
- [ ] Cada migración con script de rollback, probado en staging
- [ ] Row Level Security o filtro de tenant si es multi-tenant
- [ ] TLS en la conexión a la base de datos
- [ ] Datos de prueba sin datos reales; IDs no secuenciales cuando sea posible

## Webhooks e integraciones
- [ ] Firma del webhook verificada antes de procesar
- [ ] Protección contra repetición (timestamp y/o ID de evento)
- [ ] Procesamiento idempotente
- [ ] Credenciales de test en desarrollo; scopes mínimos en tokens
- [ ] Timeouts y reintentos con backoff en llamadas salientes

## Dependencias y cadena de suministro
- [ ] `npm audit` o `pip-audit` sin vulnerabilidades críticas ni altas sin resolver
- [ ] Lockfile commiteado; `npm ci` en CI/CD
- [ ] Paquetes nuevos comprobados (mantenimiento, autor, descargas, licencia)
- [ ] Scripts `preinstall` y `postinstall` de dependencias nuevas revisados
- [ ] Dependabot o Renovate activo

## HTTPS y servidor
- [ ] HTTPS con certificado válido y redirección desde HTTP
- [ ] `Strict-Transport-Security` con `max-age` razonable
- [ ] Rate limiting global en la API; límites más estrictos en endpoints costosos (IA, email, SMS, exportaciones)

## Agentes y entorno de desarrollo
- [ ] `CLAUDE.md` del proyecto con reglas de seguridad
- [ ] `.claude/settings.json` con deny rules y hook activos
- [ ] Ningún MCP ni herramienta conectada a producción
- [ ] Claude Code actualizado (`claude update`)
- [ ] Contenido externo (PDF, CSV, respuestas de API) tratado como dato, no como instrucción

## Revisión final
- [ ] `/security-review` ejecutado y hallazgos revisados (si está disponible)
- [ ] `semgrep --config auto .` sin hallazgos altos (si está disponible)
- [ ] Flujos de autenticación, pagos y permisos revisados a mano
- [ ] Pruebas básicas con OWASP ZAP en staging (para apps expuestas)
- [ ] Lista de pendientes documentada con severidad y responsable
