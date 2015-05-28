scripts_dir = string.sub(debug.getinfo(1).source,2,string.len(debug.getinfo(1).source)-(string.len(argv[0])+1));
dofile(scripts_dir.."/resources/functions/config.lua");
dofile(config());
dofile(scripts_dir.."/resources/functions/file_exists.lua");
dofile(scripts_dir.."/resources/functions/trim.lua");
dofile(scripts_dir.."/resources/functions/mkdir.lua");

--get the argv values
	script_name = argv[0];

--options all, last, non_moderator, member_id
	meeting_uuid = argv[1];
	domain_name = argv[2];

--prepare the api object
	api = freeswitch.API();


cmd = "conference "..meeting_uuid.."-"..domain_name.." xml_list";                                        
freeswitch.consoleLog("INFO","" .. cmd .. "\n");
result = trim(api:executeString(cmd));

if (string.sub(result, -9) == "not found") then
	conference_exists = false;
else
	conference_exists = true;
end


if (conference_exists) then
	result = string.match(result,[[<conference (.-)>]],1);
	conference_session_uuid = string.match(result,[[uuid="(.-)"]],1);
	freeswitch.consoleLog("INFO","[start-recording] conference_session_uuid: " .. conference_session_uuid .. "\n");

	start_epoch = os.time();

	--set the recording variable
	 if (domain_count > 1) then
		recordings_dir = recordings_dir.."/"..domain_name;
	end
	recordings_dir = recordings_dir.."/archive/"..os.date("%Y", start_epoch).."/"..os.date("%b", start_epoch).."/"..os.date("%d", start_epoch);
	mkdir(recordings_dir);
	recording = recordings_dir.."/"..conference_session_uuid;

	--send a command to record the conference
	if (not file_exists(recording..".wav")) then
		cmd = "conference "..meeting_uuid.."-"..domain_name.." record "..recording..".wav";
		freeswitch.consoleLog("notice", "[start-recording] cmd: " .. cmd .. "\n");
		response = api:executeString(cmd);
	end
end

