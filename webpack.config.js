// load the reusable legacy webpack config from materia-widget-dev
const widgetWebpack = require('materia-widget-development-kit/webpack-widget')
const entries = widgetWebpack.getDefaultEntries()

delete entries['creator.js']
delete entries['creator.css']

let options = {
	entries: entries,
}

module.exports = require('materia-widget-development-kit/webpack-widget').getLegacyWidgetBuildConfig(options)
