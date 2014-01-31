#!/usr/bin/env ruby

# == Synopsis
#   This will grab a user's keys from GitHub and save them in their user dir.
#
# == Examples
#   This command does blah blah blah.
#     github_keys github
#
#   Other examples:
#     github_keys github -u username
#     github_keys github --verbose
#
# == Usage
#   github_keys username [options]
#
#   For help use: github_keys -h
#
# == Options
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#   -q, --quiet         Output as little as possible, overrides verbose
#   -V, --verbose       Verbose output
#   -u, --user          Selects the specific user folder to add the keys to.
#
# == Author
#   Ian Carrico github@iancarrico.com
#
# == Copyright
#   Copyright (c) 2013 Ian Carrico. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse'
#require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'fileutils'
require 'net/http'
require 'json'


class App
  VERSION = '0.0.1'

  attr_reader :options

  def initialize(arguments, stdin)
    @arguments = arguments
    @stdin = stdin

    # Set defaults
    @options = OpenStruct.new
    @options.verbose = false
    @options.quiet = false
    @options.username = ENV['USER']
  end

  # Parse options, check arguments, then process the command
  def run

    if parsed_options? && arguments_valid?

      puts "Start at #{DateTime.now}\
\
" if @options.verbose

      output_options if @options.verbose # [Optional]

      process_arguments
      process_command

      puts "\
Finished at #{DateTime.now}" if @options.verbose

    else
      output_usage
    end

  end

  protected

    def parsed_options?

      # Specify options
      opts = OptionParser.new
      opts.on('-v', '--version')    { output_version ; exit 0 }
      opts.on('-h', '--help')       { output_help }
      opts.on('-V', '--verbose')    { @options.verbose = true }
      opts.on('-q', '--quiet')      { @options.quiet = true }
      opts.on('-u', '--user', String) do |u|
        @options.username = u
      end

      opts.parse!(@arguments) rescue return false

      process_options
      true
    end

    # Performs post-parse processing on options
    def process_options
      @options.verbose = false if @options.quiet

      unless @options.username.is_a?(String)
        puts "Error: Username is not a string."
        exit 1;
      end

      @options.home_dir = Dir.home(@options.username)

      unless File.directory?(@options.home_dir)
        puts "Home directory doesn't exist! /home/#{@options.home_dir}"
        exit 1;
      end;

    end

    def output_options
      puts "Options:\
"

      @options.marshal_dump.each do |name, val|
        puts "  #{name} = #{val}"
      end
    end

    # True if required arguments were provided
    def arguments_valid?
      true if @arguments.first.is_a?(String)
    end

    # Setup the arguments
    def process_arguments

      # TO DO - place in local vars, etc
    end

    def output_help
      output_version
#      RDoc::usage() #exits app
    end

    def output_usage
#      RDoc::usage('usage') # gets usage from comments above
    end

    def output_version
      puts "#{File.basename(__FILE__)} version #{VERSION}"
    end

    def process_command
      unless File.directory?(File.join(@options.home_dir, ".ssh"))
        Dir.mkdir(File.join(@options.home_dir, ".ssh"), 700);
      end

      Dir.chdir(File.join(@options.home_dir, ".ssh")) do

        File.open("authorized_keys", 'a') {|f|

          keys = github_query


          f.write(keys)
        }

      end

      #process_standard_input # [Optional]
    end

    def github_query
      url = "https://api.github.com/users/#{@arguments.first}/keys"
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      result = JSON.parse(data)

      if result['message']
        puts result['message']
        exit 1
      end

      keys = "";

      puts result

      result.each do |key|
        keys += key['key'] + "\n"
      end

      return keys
    end

    def process_standard_input
      input = @stdin.read
      # TO DO - process input

      # [Optional]
      # @stdin.each do |line|
      #  # TO DO - process each line
      #end
    end
end


# Create and run the application
app = App.new(ARGV, STDIN)
app.run
