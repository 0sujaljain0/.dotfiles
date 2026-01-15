require("sujalcodes3.custom.set")
require("sujalcodes3.custom.remap")
require("sujalcodes3.lazy_init")

-- Setup path editor plugin (for moving/renaming files)

-- Setup buffer switch plugin (for switching which file you're editing)
require("sujalcodes3.buffer_switch").setup()

ColorMyPencils()


vim.filetype.add({
    extension = {
        gotmpl = 'helm',
    },
    pattern = {
        -- Files in a 'templates' directory are likely Helm templates
        [".*/templates/.*%.yaml"] = "helm",
        [".*/templates/.*%.tpl"] = "helm",
        ["helmfile.*%.yaml"] = "helm",
    },
})
