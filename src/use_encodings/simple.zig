pub const Monster = struct {
    x: u32,
    y: u32,
    extra: union(enum) {
        bee: Bee,
        human: Human,
    },
    const Bee = struct {
        color: Color,
        const Color = enum { yellow, black, red };
    };

    const Human = struct {
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
        has_braces: bool,
    };
};
