
local lush        = require("lush")
local hsl         = lush.hsl

-- Colors
local pitch_black = hsl(0, 0, 0)
local sea_foam    = hsl(208, 100, 80)
local gold = hsl(51, 100, 50)

---@diagnostic disable: undefined-global
local theme       = lush(function()
    return {
        -- (You might want to disable line wrapping here via `setlocal nowrap`.)
        --
        -- Each element in the table should match this format:
        --
        --   <HighlightGroupName> { bg = <hsl>|<string>,
        --                          fg = <hsl>|<string>,
        --                          sp = <hsl>|<string>,
        --                          gui = <string>,
        --                          ... },
        --
        -- Any vim highlight group name is valid, and any unrecognized key is
        -- removed.

        -- Every theme needs a "Normal" group, so let's define that first. You can
        -- see we already have a definition prepared, so just remove uncomment the
        -- line directly after this one.
        Normal { bg = pitch_black, fg = gold }, -- Goodbye gray, hello blue!

        -- You should immediately see your background and text color change to the
        -- colors we setup before. That's all there is to writing basic highlight groups
        -- with Lush!
        --
        -- But we can do more. Lush can use previous groups to define new ones, as
        -- well as access properties of those groups.
        --
        -- For example, let's set our CursorLine to be slightly lighter than our
        -- normal background. (If disabled: `setlocal cursorline`).
        -- We can do this by setting the background property (bg) to the Normal
        -- groups background, lightened by a few points.
        -- CursorLine { bg = Normal.bg.lighten(10) }, -- lighten() can also be called via li()
        -- Also note that (aft er you move your cursor away from the line) the text
        -- "CursorLine" is highlighted to match the definition, so you can always
        -- see how parts of your theme will look.

        -- We can swap colors around too, let's make our visual selection ("v mode")
        -- the inverse of Normal.
        -- Visual { fg = Normal.bg, bg = Normal.fg }, -- Try pressing v and selecting some text

        -- We can adjust our comments to look like desaturate normal text
        -- Comment { fg = Normal.bg.de(25).li(25).ro(-10) },

        -- Besides directly using group properties, we can define two relationships
        -- between groups, "link" and "inherit".
        --
        -- Link is natively supported by Neovim (see `:h hl-link`), both groups
        -- will appear the same, and changes to the "root" will effect the other.
        --
        -- Inherit groups behave similarly to link, but the parent group properties
        -- are copied to the child, and then any changed properties override the
        -- parent.

        -- For example, let's "link" CursorColumn to CursorLine.
        -- (If disabled: `setlocal cursorcolumn`)
        -- CursorColumn { CursorLine }, -- CursorColumn is linked to CursorLine

        -- Or we can make LineNr inherit from Comment, but we'll adjust the gui
        -- property (`setlocal number`)

        -- LineNr { Comment, gui = "italic" },
        -- Try writing your own above and below line number groups, and
        -- experiment with the different operations listed at the start of this
        -- file.
        -- LineNrBelow { LineNr },
        -- LineNrAbove { LineNr },
        -- CursorLineNr { LineNr, fg = CursorLine.bg.mix(Normal.fg, 50) },

        -- Finally you can also use highlight groups to define "base" colors, if
        -- you dont want to use regular Lua variables. They will behave in the same
        -- way. Note that these groups *will* be defined as a vim-highlight-group,
        -- so try not to pick names that might end up being used by something else.
        --
        -- CamelCase is by tradition but you don't have to use it.
        -- search_base  { bg = hsl(52, 52, 52), fg = hsl(52, 10, 10) },
        -- Search       { search_base },
        -- IncSearch    { bg = search_base.bg.ro(-20), fg = search_base.fg.da(90) },
    }
end)

-- Return our parsed theme for use and that's the basics of using Lush!
-- The parsed theme can be used as a neovim theme, or extended further via Lush,
-- or used elsewhere such as in other lua runtimes.
return theme
