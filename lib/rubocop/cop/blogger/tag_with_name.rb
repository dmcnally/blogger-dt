# frozen_string_literal: true

module RuboCop
  module Cop
    module Blogger
      class TagWithName < Base
        MSG = "Use `Tag.with_name(name)` instead of direct Tag creation."

        RESTRICT_ON_SEND = %i[new create create! find_or_create_by find_or_create_by!].freeze

        def on_send(node)
          return unless tag_receiver?(node)

          add_offense(node)
        end

        private

        def tag_receiver?(node)
          receiver = node.receiver
          receiver&.const_type? && receiver.const_name == "Tag"
        end
      end
    end
  end
end
