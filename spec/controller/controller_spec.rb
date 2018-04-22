# coding: utf-8
# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', '/spec_helper'))

describe "Stealth::Controller" do

  class MrRobotsController < Stealth::Controller
    def my_action
      [:success, :my_action]
    end

    def my_action2
      [:success, :my_action2]
    end

    def my_action3
      [:success, :my_action3]
    end
  end

  class MrTronsController < Stealth::Controller
    def other_action

    end

    def other_action2

    end

    def other_action3

    end
  end

  class MrRobotFlow
    include Stealth::Flow

    flow do
      state :my_action
      state :my_action2
      state :my_action3
    end
  end

  class MrTronFlow
    include Stealth::Flow

    flow do
      state :other_action
      state :other_action2
      state :other_action3
    end
  end

  let(:facebook_message) { SampleMessage.new(service: 'facebook') }
  let(:controller) { MrTronsController.new(service_message: facebook_message.message_with_text) }

  describe "step_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.step_to
      }.to raise_error(ArgumentError)
    end

    it "should call the flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action)
      controller.step_to flow: "mr_robot"
    end

    it "should call a controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrTronsController).to receive(:other_action3)

      allow(controller.current_session).to receive(:flow_string).and_return("mr_tron")
      allow(controller.current_session).to receive(:state_string).and_return("other_action")

      controller.step_to state: "other_action3"
    end

    it "should call a controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)
      controller.step_to flow: "mr_robot", state: "my_action3"
    end

    it "should call a controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)

      allow(controller.current_session).to receive(:flow_string).and_return("mr_robot")
      allow(controller.current_session).to receive(:state_string).and_return("my_action3")

      controller.step_to session: controller.current_session
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to receive(:my_action3)
      controller.step_to flow: :mr_robot, state: :my_action3
    end
  end

  describe "update_session_to" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.update_session_to
      }.to raise_error(ArgumentError)
    end

    it "should update session to flow's first state's controller action when only a flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action)

      controller.update_session_to flow: "mr_robot"
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action')
    end

    it "should update session to controller's corresponding action when only a state is provided" do
      expect_any_instance_of(MrTronsController).to_not receive(:other_action3)

      allow(controller.current_session).to receive(:flow_string).and_return("mr_tron")
      allow(controller.current_session).to receive(:state_string).and_return("other_action")

      controller.update_session_to state: "other_action3"
      expect(controller.current_session.flow_string).to eq('mr_tron')
      expect(controller.current_session.state_string).to eq('other_action3')
    end

    it "should update session to controller's corresponding action when a state and flow is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: "mr_robot", state: "my_action3"
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end

    it "should update session to controller's corresponding action when a session is provided" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      session = Stealth::Session.new(user_id: controller.current_user_id)
      session.set(flow: 'mr_robot', state: 'my_action3')

      controller.update_session_to session: session
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end

    it "should accept flow and string specified as symbols" do
      expect_any_instance_of(MrRobotsController).to_not receive(:my_action3)

      controller.update_session_to flow: :mr_robot, state: :my_action3
      expect(controller.current_session.flow_string).to eq('mr_robot')
      expect(controller.current_session.state_string).to eq('my_action3')
    end
  end

  describe "step_to_in" do
    it "should raise an ArgumentError if a session, flow, or state is not specified" do
      expect {
        controller.step_to_in
      }.to raise_error(ArgumentError)
    end
  end

end
