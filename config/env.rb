require "base64"

ENV["admin"] = Base64.encode64("admin:hunter2").chomp
