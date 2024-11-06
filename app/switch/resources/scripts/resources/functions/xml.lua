local xml = {}

function xml:new(o)
    o = o or {}
    setmetatable(o, self);
    self.__index = self;
    self.xml = {};
    return o;
end

function xml:append(data)
    table.insert(self.xml, data);
end

function xml:build()
    return table.concat(self.xml, "\n");
end

function xml.sanitize(s)
    --create the database object
        local Database = require "resources.functions.database";
        dbh = Database.new('system');

    --create the settings object
        local Settings = require "resources.functions.lazy_settings";
        local settings = Settings.new(dbh, domain_name, domain_uuid);

    --get the allow_dangerous_commands variable
        local allow_dangerous_commands = tostring(settings:get('switch', 'allow_dangerous_commands', 'boolean')):lower() == 'true' or false;

    local result = string.gsub(s, "[\"><'$]", {
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&apos;"
    })

    if (not allow_dangerous_commands) then
        result = string.gsub(result, '%$', '');
    end

    return result;
end

return xml;
