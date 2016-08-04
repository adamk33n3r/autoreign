fs = require 'fs'
path = require 'path'
configamajig = require 'configamajig'

homeDir = process.env[if process.platform is 'win32' then 'USERPROFILE' else 'HOME']

defaultConfig = path.join __dirname, 'config.json'
userConfigDir = path.join homeDir, '.autoreign'
userConfig = path.join userConfigDir, 'config.json'

try
  # Check if user config exists
  fs.accessSync userConfig, fs.F_OK
catch
  try
    # Check if config dir exists
    fs.accessSync userConfigDir, fs.F_OK
  catch
    fs.mkdirSync userConfigDir
  # Copy default config to users
  fs.writeFileSync userConfig, fs.readFileSync defaultConfig

settingsArray = [defaultConfig, userConfig]

module.exports = configamajig settingsArray
