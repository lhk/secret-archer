exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
  server:
    path: 'server.coffee'
    port: 3333
    base: '/'
    watched: ['public', 'express']
    ignored: /(^[.#]|(?:~)$)/
    source: /.*\.coffee$/
    coffeelint:
      enabled: on
      pattern: /.*\.coffee$/
      options:
        indentation:
          value: 4
          level: "error"


