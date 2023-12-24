return {
    "rmagatti/auto-session",
    commit = "3eb26b949e1b90798e84926848551046e2eb0721",
    config = function()
        require("auto-session").setup({
            log_level = "error",
            auto_session_suppress_dirs = { "~/", "~/Downloads" },
        })
    end,
}
