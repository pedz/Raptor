# -*- coding: utf-8 -*-

# Simple rake file to format the javascript documentation using JSDoc

JSDocDir = "/Users/pedzan/Source/OpenSource/jsdoc_toolkit-2.4.0/jsdoc-toolkit"
# relative to public/javascripts
JSFiles = [ "ar.js" ]

namespace :doc do
  desc "Format javascript documentation into doc/javascript"
  task :javascript do
    files = JSFiles.map{ |f| "public/javascripts/#{f}"}.join(" ")
    cmd = [ "java -jar #{JSDocDir}/jsrun.jar #{JSDocDir}/app/run.js",
            "-Djsdoc.dir=#{JSDocDir}",
            "-d=doc/javascript",
            "-t=#{JSDocDir}/templates/jsdoc",
            files ].join(" ")
    sh cmd
  end
end
