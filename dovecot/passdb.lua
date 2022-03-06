local socket = require("socket")

function auth_password_verify(req, pass)
	local s = socket.tcp4()
	if not s then
		return dovecot.auth.PASSDB_RESULT_INTERNAL_FAILURE, ""
	end

	s:settimeout(3)
	if not s:connect("authd", "1234") then
		return dovecot.auth.PASSDB_RESULT_INTERNAL_FAILURE, ""
	end

	s:send(req.user .. "\n" .. pass .. "\n")

	local result
	if s:receive() == "OK" then
		result = dovecot.auth.PASSDB_RESULT_OK
	else
		result = dovecot.auth.PASSDB_RESULT_PASSWORD_MISMATCH
	end
	s:close()

	return result, ""
end

function script_init()
	return 0
end

function script_deinit()
end
