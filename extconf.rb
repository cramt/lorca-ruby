# frozen_string_literal: true

require_relative './build'

dummy_make_content = "make:\n" \
                     "\t:\n" \
                     "install:\n" \
                     "\t:\n" \
                     "clean:\n" \
                     "\t:\n"
File.write('Makefile', dummy_make_content)
