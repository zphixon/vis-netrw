vis.netrw = {}

local res = vis:map(vis.modes.NORMAL, "-", function()
    -- make sure file is not modified before totally destroying it
    if vis.win.file.modified and not vis.win.netrw then
        vis:info("Can't open netrw: file changed")
        return
    end
    
    local path = vis.win.netrwpath or vis.win.file.path
    
    if path == nil then
        local pwd = io.popen("/bin/pwd")
        path = pwd:read("*a")
        path = string.sub(path, 1, string.len(path) - 1)
        pwd:close()
    end
    
    if path == nil then
        path = os.getenv("HOME")
    end
    
    if path == nil then
        vis:info("Can't open netrw: path unknown")
        return
    end

    vis:command("unmap-window normal <Enter>")
    
    vis.win:map(vis.modes.NORMAL, "<Enter>", function()
        local selection = vis.win.file.lines[vis.win.cursor.line]
        if string.match(selection, "/$") then
            path = path .. "/" .. string.sub(selection, 1, string.len(selection) - 1)
            
            vis.win.file:delete(0, vis.win.file.size)
            local lsfile = io.popen("ls -p --group-directories-first '" .. path .. "'")
            for filename in lsfile:lines() do
                vis.win.file:insert(vis.win.file.size, filename .. "\n")
            end
            lsfile:close()
            
            vis.win:draw()
        else
            vis:open(path .. "/" .. selection)
        end
    end)

    if vis.win.netrw then
        path = path .. "/.."
    end
    vis:info(path)
    
    vis.win.file:delete(0, vis.win.file.size)
    
    local lsfile = io.popen("ls -p --group-directories-first '" .. path .. "'")
    for filename in lsfile:lines() do
        vis.win.file:insert(vis.win.file.size, filename .. "\n")
    end
    lsfile:close()

    vis.win.file.modified = false
    
    vis.win.netrw = true
    vis.win.netrwpath = path
    vis.win:draw()

end, "Open netrw")
