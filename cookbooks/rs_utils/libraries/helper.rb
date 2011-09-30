# Copyright (c) 2011 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module RightScale
  module Utils
    module Helper
      NAMESPACE_REGEX   = '[a-z](?:[a-z0-9_]*)'
      PREDICATE_REGEX = '[a-zA-Z0-9%_\+\.-](?:[a-zA-Z0-9%_\+\.-]*)'

      # Determines if a tag matches a given wildcard expression or prefix.
      #
      # === Parameters
      # kind(String):: Wildcard expression or prefix
      # kind(String):: Tag
      #
      # === Return
      # kind(Boolean):: True if the tag matches the wildcard expression or prefix, false otherwise
      def self.matches_tag_wildcard?(wildcard, tag)
        if wildcard =~ /^(#{NAMESPACE_REGEX}):$/
          wildcard = "#{$1}:*"
        elsif wildcard =~ /^(#{NAMESPACE_REGEX}):(#{PREDICATE_REGEX})=?$/
          wildcard = "#{$1}:#{$2}=*"
        end

        File.fnmatch?(wildcard, tag)
      end

      # Filters a server collection to only include servers with all of the supplied tags.
      #
      # === Parameters
      # kind(Chef::Node::Attribute):: Dictionary of server collections
      # kind(String):: Name of the server collection to filter
      # kind(Array):: List of tags or tag wildcards to filter by
      #
      # === Return
      # kind(Hash):: A filtered server collection
      def self.filter_tags(collection, name, tags)
        collection[name].reject do |key, values|
          reject = false

          tags.each do |tag|
            break reject = true if values.select {|value| File.fnmatch?(tag, value)}.empty?
          end

          reject
        end.to_hash
      end

      # Filters a server collection to only include servers with all of the supplied tags modifying the given server collection.
      #
      # === Parameters
      # kind(Chef::Node::Attribute):: Dictionary of server collections
      # kind(String):: Name of the server collection to filter
      # kind(Array):: List of tags or tag wildcards to filter by
      #
      # === Return
      # kind(Hash):: A filtered server collection
      def self.filter_tags!(collection, name, tags)
        collection[name] = filter_tags(collection, name, tags)
      end

      # Get the value portion of a tag with a given prefix from a list of tags.
      #
      # === Parameters
      # kind(String):: Prefix of tag to retrieve
      # kind(Array):: List of tags to search
      # kind(String):: Optional Regexp portion to validate the value
      #
      # === Return
      # kind(String):: The value portion of a tag if found, nil if not found or value is invalid
      def self.get_tag_value(prefix, tags, capture = '.*')
        if tags.detect {|tag| tag =~ /^#{Regexp.escape(prefix)}=(#{capture})$/}
          $1
        end
      end
    end
  end
end
