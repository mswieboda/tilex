require "uing"
require "stumpy_png"
require "./tilex/**" # This glob-loads everything in the folder

Tilex::App.new.run
