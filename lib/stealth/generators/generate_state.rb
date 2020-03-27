# coding: utf-8
# frozen_string_literal: true

require 'thor/group'

module Stealth
  module Generators
    class GenerateState < Thor::Group
      include Thor::Actions

      argument :generator
      argument :name
      argument :flow_name
      argument :type

      def self.source_root
        File.dirname(__FILE__) + "/generate/flow"
      end

      def edit_flow_map
        inject_into_file "config/flow_map.rb", after: "flow :#{flow_name} do\n" do
          "\t\tstate :#{type}_#{flow_name}_#{name}_1\n"
        end
      end

      def edit_controller
        inject_into_file "bot/controllers/#{flow_name.pluralize}_controller.rb",
        after: "BotController\n" do
          "\n  def #{type}_#{flow_name}_#{name}_1\n    #{controller_method_content}\n  end\n"
        end
      end

      def create_replies
        if type == 'say' || type == 'ask'
          template("replies/ask_example.tt", "bot/replies/#{flow_name.pluralize}/#{type}_#{flow_name}_#{name}_1.yml")
        end
      end

      private

      def controller_method_content
        case type
        when 'say'
          "send_replies\n    step_to state:"
        when 'ask'
          "send_replies\n    update_session_to state:"
        when 'get'
          "case current_message.payload\n    when 'example'\n    else\n    end"
        end
      end
    end
  end
end
