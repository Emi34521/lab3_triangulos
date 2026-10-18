const rl = @import("raylib");
const Framebuffer = @import("framebuffer.zig").Framebuffer;
const Triangle = @import("triangle.zig").Triangle;

const width = 1300;
const height = 900;

// vectores para hacer lo del RGB
const rojo: rl.Vector3 = .{ .x = 1, .y = 0, .z = 0 };
const verde: rl.Vector3 = .{ .x = 0, .y = 1, .z = 0 };
const azul: rl.Vector3 = .{ .x = 0, .y = 0, .z = 1 };

fn v(x: f32, y: f32) rl.Vector2 {
    return .{ .x = x, .y = y };
}

pub fn main() !void {
    var framebuffer = Framebuffer.init(width, height, .black, .white);

    // lo típico de raylib para crear la pantalla. El límite de fps lo dejé igual que el proyecto.
    rl.initWindow(width, height, "LMAO");
    rl.setTraceLogLevel(.warning);
    defer rl.closeWindow();
    rl.setTargetFPS(30);

    // básicamente una arreglo para los diferentes tipos de triángulos y mostrar que no importa la forma ni la  orientación
    // igual se hará la interpolación con los colores.
    const triangulos = [_]Triangle{
        // Equilátero
        Triangle.init(v(200, 100), v(50, 360), v(350, 360), rojo, verde, azul),
        // Muy alargado
        Triangle.init(v(450, 100), v(950, 140), v(470, 180), rojo, verde, azul),
        // Rectángulo
        Triangle.init(v(1000, 100), v(1000, 350), v(1250, 350), rojo, verde, azul),
        // Mismo tipo que el equilátero pero con los vértices en sentido contrario
        Triangle.init(v(350, 800), v(50, 800), v(200, 540), rojo, verde, azul),
        // Cuadrado: dos triángulos que comparten la diagonal (500,450)-(800,750)
        Triangle.init(v(500, 450), v(800, 450), v(800, 750), rojo, verde, azul),
        Triangle.init(v(500, 450), v(800, 750), v(500, 750), rojo, azul, verde),
        // Escaleno
        Triangle.init(v(900, 500), v(1250, 600), v(1050, 820), rojo, verde, azul),
    };

    // muestra la pantalla
    while (!rl.windowShouldClose()) {
        framebuffer.clear();

        for (triangulos) |t| {
            try t.draw(&framebuffer);
        }

        try framebuffer.swap_buffers();
    }
}
