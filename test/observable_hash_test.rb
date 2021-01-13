# frozen_string_literal: true

require_relative './test_helper'
require 'lorca'

module Lorca
  class ObservableHashTest < Minitest::Test
    include Lorca::Utilities

    def test_that_observable_hash_is_hashlike
      hash = ObservableHash.new({
                                  'a' => 2
                                })
      assert_equal 2, hash['a']
    end

    def test_that_listen_fires
      hash = ObservableHash.new({
                                  'a' => 2
                                })
      o = nil
      k = nil
      v = nil
      hash.listen do |object, key, value|
        o = object
        k = key
        v = value
      end
      hash['a'] = 3
      assert_equal 3, v
      assert_equal 'a', k
      assert_equal hash, o
    end

    def test_that_nested_hashes_fire
      hash = ObservableHash.new({
                                  'a' => {
                                    'a' => 2
                                  }
                                })
      o = nil
      k = nil
      v = nil
      hash.listen do |object, key, value|
        o = object
        k = key
        v = value
      end
      hash['a']['a'] = 3
      assert_equal 3, v
      assert_equal 'a', k
      assert_equal hash['a'], o
    end
  end
end
