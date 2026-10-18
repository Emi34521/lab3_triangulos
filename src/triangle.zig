const rl = @import("raylib");
const std = @import("std");
const Framebuffer = @import("framebuffer.zig").Framebuffer;

// Si el área total es menor a este valor, el triángulo es degenerado (puntos colineales) y no se dibuja
const epsilon: f32 = 1e-6;
// Pequeño margen para no dejar píxeles sin pintar justo en los bordes
const margen: f32 = 1e-4;

pub const Triangle = struct {
    puntos: struct {
        A: rl.Vector2,
        B: rl.Vector2,
        C: rl.Vector2,
    },
    // Color de cada vértice como RGB con valores entre 0 y 1
    colores: struct {
        A: rl.Vector3,
        B: rl.Vector3,
        C: rl.Vector3,
    },

    // Pesos baricéntricos: a pesa al vértice A, b al B y c al C deben sumar 1.
    pub const Pesos = struct {
        a: f32,
        b: f32,
        c: f32,
    };

    pub fn init(
        a: rl.Vector2,
        b: rl.Vector2,
        c: rl.Vector2,
        color_a: rl.Vector3,
        color_b: rl.Vector3,
        color_c: rl.Vector3,
    ) Triangle {
        return .{
            .puntos = .{ .A = a, .B = b, .C = c },
            .colores = .{ .A = color_a, .B = color_b, .C = color_c },
        };
    }

    // Área del triángulo PQR multiplicada por 2 y con signo
    // El signo depende de si los puntos van en sentido horario o antihorario.
    // Como los pesos son un cociente entre dos de estas áreas, el signo se cancela
    // y no importa en qué orden se den los vértices.
    // Básicamente forma 2 vectores. El PQ y el PR y luego se saca el determinante para
    // conseguir 2(área) pero conservando el signo. esto será importante para determinar
    // el peso y si está dentro del triángulo o no.

    fn area2(p: rl.Vector2, q: rl.Vector2, r: rl.Vector2) f32 {
        return (q.x - p.x) * (r.y - p.y) - (q.y - p.y) * (r.x - p.x);
    }

    // Devuelve los pesos baricéntricos de P, o null si P está fuera del triángulo
    pub fn pesos(self: Triangle, p: rl.Vector2) ?Pesos {
        const A = self.puntos.A;
        const B = self.puntos.B;
        const C = self.puntos.C;

        // el primero lo hice manualmente, pero sigue la misma lógica. Hacer 2 vectores y obtener el determiante para
        // conseguir el área.
        const total = (B.x - A.x) * (C.y - A.y) - (B.y - A.y) * (C.x - A.x);
        if (@abs(total) < epsilon) return null;

        // El peso de un vértice es el área del sub triángulo opuesto a ese vértice
        const w: Pesos = .{
            .a = area2(p, B, C) / total, // BPC
            .b = area2(A, p, C) / total, // APC
            .c = area2(A, B, p) / total, // ABP
        };

        // Si algún peso es negativo P está fuera del triángulo retorna null
        if (w.a < -margen or w.b < -margen or w.c < -margen) return null;
        return w;
    }

    // Interpola los colores de los vértices con los pesos y lo convierte a rl.Color con la
    // función reutilizada del raycast.
    pub fn colorEn(self: Triangle, w: Pesos) rl.Color {
        const c = self.colores;
        const color_pesos: rl.Vector3 = .{
            .x = (w.a * c.A.x + w.b * c.B.x + w.c * c.C.x),
            .y = (w.a * c.A.y + w.b * c.B.y + w.c * c.C.y),
            .z = (w.a * c.A.z + w.b * c.B.z + w.c * c.C.z),
        };
        return V3ToColor(color_pesos);
    }

    // reutilicé la función del raytracer, como ya no es necesario el raytracer, únicamente tomé esa función.
    pub fn V3ToColor(color: rl.Vector3) rl.Color {
        const r: u8 = @intFromFloat(@max(0, @min(255, color.x * 255)));
        const g: u8 = @intFromFloat(@max(0, @min(255, color.y * 255)));
        const b: u8 = @intFromFloat(@max(0, @min(255, color.z * 255)));
        return .{ .r = r, .g = g, .b = b, .a = 0xff };
    }

    // esta parta ya dibuja el triángulo en la pantalla y toma el puntero de framebuffer.
    pub fn draw(self: Triangle, fb: *Framebuffer) !void {
        const A = self.puntos.A;
        const B = self.puntos.B;
        const C = self.puntos.C;

        const x_max: f32 = @floatFromInt(fb.width - 1);
        const y_max: f32 = @floatFromInt(fb.height - 1);

        // Caja delimitadora del triángulo, recortada a la pantalla.
        // Es necesario porque set_pixel da error si x o y se salen del framebuffer.
        const min_x: i32 = @intFromFloat(std.math.clamp(@floor(@min(A.x, B.x, C.x)), 0, x_max));
        const max_x: i32 = @intFromFloat(std.math.clamp(@ceil(@max(A.x, B.x, C.x)), 0, x_max));
        const min_y: i32 = @intFromFloat(std.math.clamp(@floor(@min(A.y, B.y, C.y)), 0, y_max));
        const max_y: i32 = @intFromFloat(std.math.clamp(@ceil(@max(A.y, B.y, C.y)), 0, y_max));

        // luego recorre todo para dibujar los pixeles coon ayuda del framebuffer.
        var y = min_y;
        while (y <= max_y) : (y += 1) {
            var x = min_x;
            while (x <= max_x) : (x += 1) {
                // Se evalúa en el centro del píxel
                const p: rl.Vector2 = .{
                    .x = @as(f32, @floatFromInt(x)) + 0.5,
                    .y = @as(f32, @floatFromInt(y)) + 0.5,
                };
                if (self.pesos(p)) |w| {
                    try fb.set_pixel(x, y, self.colorEn(w));
                }
            }
        }
    }
};
