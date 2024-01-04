local get_package_root = function()
	local package_json_path = vim.fn.findfile("package.json", vim.fn.expand("%:p:h") .. ";")
	--get full path
	return vim.fn.fnamemodify(package_json_path, ":p:h") .. "/"
end

local function get_git_repo_name()
	local url = vim.fn.system("git remote get-url origin")

	-- split url by / and get the last element
	local split_url = vim.split(url, "/")
	local repo_name = split_url[#split_url]:gsub("%s+", "")

	return repo_name
end

-- convert windows path to unix path
local function convert_windows_path(path)
	local converted_path = path:gsub("\\", "/")
	return converted_path
end

return {
	get_package_root = get_package_root,
	get_git_repo_name = get_git_repo_name,
	convert_windows_path = convert_windows_path,
}
