#HTTP Server
A vanilla Ruby server written to meet HTTP 1.1 specs (currently in-process)

## Start the Server
Once you have the project files, start the server with `bin/start_server` for a server instance on port 5000.

## Acceptance Tests
This was built using [Cob Spec](https://github.com/8thlight/cob_spec), “a suite of tests used to validate a web server to ensure it adheres to HTTP specifications.”

To configure on your local machine, you need to follow the config instructions in the Cob Spec README.

* For this project, the `SERVER_START_COMMAND` needs to be set the path to the project executable file in the bin, e.g.
```
/User/path/to/http_server_ruby/bin/start_server`
```

* The `PUBLIC_DIR` is included in the project, so the path must be set to the local project public directory, e.g.
```
/User/path/to/http_server_ruby/public
```

## Unit Tests
At this point, you need to run `rspec spec` to run the specs on the server methods

