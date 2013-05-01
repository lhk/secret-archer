# import spawn
{spawn,exec} = require('child_process')

controlBuild = (err, stdout, stderr)->
  if stdout isnt ""
    console.log stdout
  if err isnt null
    console.log "Build failed with error code #{err.code}:"
    console.log ''
    console.log stderr
    # The build doesn't continue.
    process.exit 1
  else
    console.log 'Successful.'

task 'client', 'Build client-source (*.coffee) to *.js',->
  console.log 'Building...'
  exec 'coffee --compile --output lib/client/ scripts/client/', (err, stdout,stderr)-> controlBuild(err, stdout, stderr)
  console.log 'Generating source maps...'
  exec 'coffee --map --output lib/client/ scripts/client/', (err,stdout,stderr)->controlBuild(err, stdout, stderr)    

task 'help', 'Read me!',->
  console.log "This cakefile defines various targets. To see them, type `cake` without arguments."
  console.log "Be sure to have run cake update_deps before building any other target from this cakefile."
  console.log "When the project's dependencies have changed, you are fine running `cake update_deps` again."