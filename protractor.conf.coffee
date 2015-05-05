exports.config =
  capabilities:
    'browserName': 'chrome'

  baseUrl: 'http://localhost:10000'

  chromeDriver: './node_modules/chromedriver/bin/chromedriver'
  seleniumServerJar: './node_modules/selenium-standalone-jar/bin/selenium-server-standalone-2.45.0.jar'

  framework: 'jasmine'

  jasmineNodeOpts:
    defaultTimeoutInterval: 30000
