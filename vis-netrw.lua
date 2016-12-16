vis.netrw = {}

local res = vis:map(vis.modes.NORMAL, "-", function()
    -- make sure file is not modified before totally destroying it
    if vis.win.file.modified and not vis.win.netrw then
        vis:info("Can't open netrw: file changed")
        return
    end
    
    -- get path from window's netrwpath or file's path
    local path = vis.win.netrwpath or vis.win.file.path
    
    -- use pwd to get directory to open
    if path == nil then
        -- full path because pwd is usually shell builtin
        local pwd = io.popen("/bin/pwd")
        if pwd == nil then
            -- if it doesn't work, just use home
            if path == nil then
                path = os.getenv("HOME")
            end
        end
        path = pwd:read("*a")
        path = string.sub(path, 1, string.len(path) - 1)
        pwd:close()
    end
    
    -- error if no path exists
    if path == nil then
        vis:info("Can't open netrw: path unknown")
        return
    end

    -- use enter for opening files/directories
    vis:command("unmap-window normal <Enter>")
    
    -- map enter to actually do that
    vis.win:map(vis.modes.NORMAL, "<Enter>", function()
        -- get enter selection
        local selection = vis.win.file.lines[vis.win.cursor.line]

        -- check if it's a directory
        if string.match(selection, "/$") then
            -- get directory path, chop off trailing forward slash
            path = path .. "/" .. string.sub(selection, 1, string.len(selection) - 1)
            
            -- delete the whole file: totally destroying it
            vis.win.file:delete(0, vis.win.file.size)
            
            -- use ls to get list of stuff in directory
            local lsfile = io.popen("ls -p --group-directories-first '" .. path .. "'")
            for filename in lsfile:lines() do
                -- put it all in the file
                vis.win.file:insert(vis.win.file.size, filename .. "\n")
            end
            lsfile:close()
            
            -- set random variables for future reference
            vis.win.netrw = true
            vis.win.netrwpath = path
            vis.win:draw()
        else
            vis:open(path .. "/" .. selection)
        end
    end)

    -- check if it's already a netrw window
    if vis.win.netrw then
        path = path .. "/.."
    end
    
    -- totally destroy the file
    vis.win.file:delete(0, vis.win.file.size)
    
    -- put directory contents into file
    local lsfile = io.popen("ls -p --group-directories-first '" .. path .. "'")
    for filename in lsfile:lines() do
        vis.win.file:insert(vis.win.file.size, filename .. "\n")
    end
    lsfile:close()

    -- doesn't work, get an annoying message when you try to close it
    vis.win.file.modified = false
    
    -- set random variables for future reference
    vis.win.netrw = true
    vis.win.netrwpath = path
    
    -- actually draw the window
    vis.win:draw()
end, "Open netrw")
