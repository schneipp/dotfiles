-- anarchy-rdp: serve every virtual monitor over RDP from session start.
-- Installed by installer-headless-rdp.sh; custom.lua loads it when present.
-- anarchy-rdp holds a lock, so a second start (a reload, a manual run) is a no-op.
hl.on("hyprland.start", function()
    -- Full path: a session started by greetd need not have ~/.local/bin on PATH.
    hl.exec_cmd(os.getenv("HOME") .. "/.local/bin/anarchy-rdp run")
end)
