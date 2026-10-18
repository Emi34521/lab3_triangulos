# lab3_triangulos

Requiere Zig 0.16.0. La dependencia `raylib_zig` está fijada en
`build.zig.zon` a la revisión `bd161c82d4cc42d9ea7986d0c6a86daaae79e430`,
compatible con esa versión de Zig.

Desde la raíz del proyecto:

```powershell
zig version
zig build
zig build run
```

Para ejecutar las pruebas existentes:

```powershell
zig build test
```

La primera compilación necesita internet para descargar las dependencias.
Zig administra la carpeta `zig-pkg/`; no hace falta editarla ni subirla a Git.

No vuelvas a ejecutar `zig fetch --save ...#devel` para este proyecto:
esa rama avanza con las versiones de desarrollo de Zig y la revisión que
causó los errores requiere Zig 0.17.0. Los errores sobre `findProgram`,
`Build.root` y `serializeConfigurationExiting` se debían a esa incompatibilidad.
