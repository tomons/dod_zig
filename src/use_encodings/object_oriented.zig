pub const Monster = struct {
    tag: Tag,
    x: u32,
    y: u32,

    const Tag = enum {
        bee,
        human,
    };

    pub const Bee = struct { //16
        base: Monster, // 12
        color: Color, // 4
        const Color = enum { yellow, black, red };
    };

    pub const Human = struct { // 32
        base: Monster,
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
        has_braces: bool,
    };
};
