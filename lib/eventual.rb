# encoding: UTF-8
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rubygems'
require 'treetop'
require 'date'

require "eventual/syntax_nodes"


Range.send(:alias_method, :cover?, :include?) unless Range.methods.include? :include?

autoload :EsDatesParser, 'eventual/es'

module Eventual
  # Parses dates specified in natural language and returns an Eventual::Node object
  #     Eventual.parse( 'del 5 al 7 de junio del 2009' ).to_a
  #     => [#<DateTime: 4909975/2,0,2299161>, #<DateTime: 4909977/2,0,2299161>, #<DateTime: 4909979/2,0,2299161
  #
  # Options:
  # +:lang+: 
  #   Defaults to 'Es', the language to be used for parsing, currently only spanish is supported, please contribute.
  # +:default_year+: 
  #   The default year to be used in case year is not specified in the text, defaults to current year
  # +:default_event_span+: 
  #   The duration in minutes an event has, defaults to 60
  # 
  def self.parse text, opts = {}
    lang    = opts.delete(:lang) || 'Es'
    year    = opts.delete(:default_year)
    
    raise ArgumentError, "Expected option `:default_year` to be an integer"        if year && !(Integer === year)
    
    parser = const_get("#{ lang.to_s[0..1].capitalize }DatesParser") rescue raise( NotImplementedError.new("Parsing has not yet been implemented for the language '#{lang}'"))

    node   = parser.new.parse text.gsub('sab', 'sáb').gsub('mie', 'mié').downcase

    node.year      = year if year
    node
  end
end
