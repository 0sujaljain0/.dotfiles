require("sujalcodes3.custom.set")
require("sujalcodes3.custom.remap")
require("sujalcodes3.lazy_init")

-- Setup path editor plugin (for moving/renaming files)

ColorMyPencils()

-- Dynamically locate and prepend NVM's default node binary to PATH for Neovim subprocesses
local nvm_default_node = vim.fn.expand("$HOME/.nvm/versions/node/")
if vim.fn.isdirectory(nvm_default_node) == 1 then
  local default_dir = vim.fn.glob(nvm_default_node .. "v*/bin", false, true)
  if #default_dir > 0 then
    -- Prepend the latest/default node bin directory to PATH
    vim.env.PATH = default_dir[#default_dir] .. ":" .. vim.env.PATH
  end
end


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
