require 'spec_helper'

describe "RubyStoredScript" do

  let(:network){ new_network.tap(&:login) }
  let(:request){ network.new_action_request }

  describe :echo do
    let(:argh){ {"foo" => {"bar" => "baz"} } }
    before do
      request.execute("RubyStoredScript", "echo", argh)
      request.send_request
    end
    it do
      request.outputs.length.should == 1
      request.outputs.first["result"].should == {"echo" => argh}
    end
  end

end
