require("sujalcodes3.custom.set")
require("sujalcodes3.custom.remap")
require("sujalcodes3.lazy_init")

-- Setup path editor plugin (for moving/renaming files)

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
