-- Workspace defaults

for i = 1, 4 do
    hl.workspace_rule({ workspace = tostring(i), monitor = MONITOR1, persistent = true })
end
