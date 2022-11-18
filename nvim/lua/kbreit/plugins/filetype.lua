local filetype_setup, filetype = pcall(require, "filetype")
if not filetype_setup then
	return
end

filetype.setup({
  overrides = {
    extensions = {
      tf = "terraform",
      tfvars = "terraform",
      tfstate = "json",
    }
  }
})

