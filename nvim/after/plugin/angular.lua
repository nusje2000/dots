vim.keymap.set("n", "<leader>ng", function()
    local api = require("nvim-tree.api")
    local node = api.tree.get_node_under_cursor()

    if not node or not node.absolute_path then
        vim.notify("No directory selected in nvim-tree.", vim.log.levels.ERROR)
        return
    end

    local base_dir = node.absolute_path
    if not vim.fn.isdirectory(base_dir) then
        vim.notify("Selected node is not a directory.", vim.log.levels.ERROR)
        return
    end

    local component_name = vim.fn.input("Enter Angular component name: " .. base_dir .. "/")

    if component_name ~= "" then
        local component_dir = base_dir .. "/" .. component_name

        local component_file = component_dir .. "/" .. component_name .. ".component.ts"
        local html_file = component_dir .. "/" .. component_name .. ".component.html"
        local css_file = component_dir .. "/" .. component_name .. ".component.scss"

        -- Create the component directory
        vim.fn.mkdir(component_dir, "p")

        -- Write the component TypeScript file
        local component_ts_content = [[
import { Component } from '@angular/core';

@Component({
  selector: ']] .. component_name .. [[',
  templateUrl: './]] .. component_name .. [[.component.html',
  styleUrls: ['./]] .. component_name .. [[.component.scss']
})
export class ]] .. component_name:gsub("(%-)(%l)", function(_, letter) return letter:upper() end):gsub("^%l", string.upper) .. [[Component {
}
]]
        vim.fn.writefile(vim.split(component_ts_content, "\n"), component_file)

        -- Write the HTML file
        vim.fn.writefile({ "<p>" .. component_name .. " works!</p>" }, html_file)

        -- Write the CSS file
        vim.fn.writefile({}, css_file)

        vim.notify("Angular component '" .. component_name .. "' created successfully.", vim.log.levels.INFO)
    else
        print("Component name cannot be empty.")
    end
end)
