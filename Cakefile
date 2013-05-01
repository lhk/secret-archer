# import spawn
{spawn,exec} = require('child_process')
http = require('http')
fs = require('fs')

depFolder = "lib/"

controlBuild = (err, stdout, stderr)->
  if stdout isnt ""
    console.log stdout
  if stderr isnt ""
    console.log stderr
  if err isnt null
    console.log "Failed with error code #{err.code}:"
    console.log ''
    console.log stderr
    # The build doesn't continue.
    process.exit 1
  else
    console.log 'Successful.'

# need the trailing slash after the destinationFolder's name.
downloadFile = (uri, fileName, destinationFolder)->
  console.log "Attempting to fetch #{uri}..."
  # need to use a callback here as exec is asynchronous. We need to wait for it to finish.
  exec "wget -N #{uri}", (a,b,c)->
    fs.mkdir destinationFolder, (error)->
      if error? && error.code isnt 'EEXIST'
        console.log error
      else
        exec "mv #{fileName} #{destinationFolder}", (a,b,c)-> controlBuild(a,b,c)
  
task 'client', 'Build client-source (*.coffee) to *.js',->
  console.log "Building..."
  exec 'coffee --compile --output lib/client/ scripts/client/', (err, stdout,stderr)-> controlBuild(err, stdout, stderr)
  console.log "Generating source maps..."
  exec 'coffee --map --output lib/client/ scripts/client/', (err,stdout,stderr)->controlBuild(err, stdout, stderr)

task 'help', 'Read me!',->
  console.log "This cakefile defines various targets. To see them, type `cake` without arguments."
  console.log "Be sure to have run cake init before building any other target from this cakefile."
  console.log "When the project's dependencies have changed, you are fine running `cake init` again."

task 'init', 'Fetches all dependencies', ->
  console.log "Installing node dependencies..."
  npm = spawn 'npm' , ['install'], { stdio: 'inherit' }
  console.log "Fetching residual dependencies..."
  downloadFile "http://code.jquery.com/jquery-1.9.1.min.js", "jquery-1.9.1.min.js", depFolder
  downloadFile "http://code.createjs.com/easeljs-0.6.0.min.js", "easeljs-0.6.0.min.js", depFolder

task 'clean', 'Tidies the repository', ->
  spawn 'rm' , ['-r', '-d', 'lib/', 'node_modules/'], {stdio: 'inherit'}

task 'start_server', 'Starts the game\'s server', ->
  spawn 'coffee', ['scripts/server/server.coffee'], {stdio: 'inherit'}
