pub const Monster = struct {
    tag: Tag,
    common: Common,

    pub const Tag = enum {
        bee_yellow,
        bee_black,
        bee_red,

        human_naked,
        human_braces_naked,
        human_clothed,
        human_braces_clothed,
    };

    pub const Common = struct {
        x: u32,
        y: u32,
        extra_index: u32,
    };

    pub const HumanClothed = struct {
        hat: u32,
        shoes: u32,
        shirt: u32,
        pants: u32,
    };
};
